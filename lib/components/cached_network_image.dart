import 'dart:async' show Future, StreamController, Timer;
import 'dart:typed_data';
import 'dart:ui' as ui show Codec, FrameInfo;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide FadeInImage;
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../app/theme_provider.dart';

/// Slows down animations by this factor to help in development.
double get timeDilation => _timeDilation;
double _timeDilation = 1.0;

/// MultiImageStreamCompleter needs version ^1.18.0-8.0.pre
/// Released to dev at 24/04/2020
class MultiImageStreamCompleter extends ImageStreamCompleter {
  MultiImageStreamCompleter({
    required Stream<ui.Codec> codec,
    required double scale,
    Stream<ImageChunkEvent>? chunkEvents,
    InformationCollector? informationCollector,
  })  : _informationCollector = informationCollector,
        _scale = scale {
    codec.listen((event) {
      if (_timer != null) {
        _nextImageCodec = event;
      } else {
        _handleCodecReady(event);
      }
    }, onError: (dynamic error, StackTrace stack) {
      reportError(
        context: ErrorDescription('resolving an image codec'),
        exception: error,
        stack: stack,
        informationCollector: informationCollector,
        silent: true,
      );
    });
    if (chunkEvents != null) {
      chunkEvents.listen(
        reportImageChunkEvent,
        onError: (dynamic error, StackTrace stack) {
          reportError(
            context: ErrorDescription('loading an image'),
            exception: error,
            stack: stack,
            informationCollector: informationCollector,
            silent: true,
          );
        },
      );
    }
  }

  ui.Codec? _codec;
  ui.Codec? _nextImageCodec;
  final double _scale;
  final InformationCollector? _informationCollector;
  ui.FrameInfo? _nextFrame;
  // When the current was first shown.
  Duration? _shownTimestamp;
  // The requested duration for the current frame;
  Duration? _frameDuration;
  // How many frames have been emitted so far.
  int _framesEmitted = 0;
  Timer? _timer;

  // Used to guard against registering multiple _handleAppFrame callbacks for the same frame.
  bool _frameCallbackScheduled = false;

  void _switchToNewCodec() {
    _framesEmitted = 0;
    _timer = null;
    _handleCodecReady(_nextImageCodec!);
    _nextImageCodec = null;
  }

  void _handleCodecReady(ui.Codec codec) {
    _codec = codec;

    if (hasListeners) {
      _decodeNextFrameAndSchedule();
    }
  }

  void _handleAppFrame(Duration timestamp) {
    _frameCallbackScheduled = false;

    if (!hasListeners) {
      return;
    }

    if (_isFirstFrame() || _hasFrameDurationPassed(timestamp)) {
      _emitFrame(ImageInfo(image: _nextFrame!.image, scale: _scale));

      _shownTimestamp = timestamp;
      _frameDuration = _nextFrame!.duration;
      _nextFrame = null;

      if (_framesEmitted % _codec!.frameCount == 0 && _nextImageCodec != null) {
        _switchToNewCodec();
      } else {
        final completedCycles = _framesEmitted ~/ _codec!.frameCount;

        if (_codec!.repetitionCount == -1 ||
            completedCycles <= _codec!.repetitionCount) {
          _decodeNextFrameAndSchedule();
        }
      }

      return;
    }

    final delay = _frameDuration! - (timestamp - _shownTimestamp!);
    _timer = Timer(delay * timeDilation, _scheduleAppFrame);
  }

  bool _isFirstFrame() {
    return _frameDuration == null;
  }

  bool _hasFrameDurationPassed(Duration timestamp) {
    assert(_shownTimestamp != null);
    return timestamp - _shownTimestamp! >= _frameDuration!;
  }

  Future<void> _decodeNextFrameAndSchedule() async {
    try {
      _nextFrame = await _codec!.getNextFrame();
    } catch (exception, stack) {
      reportError(
        context: ErrorDescription('resolving an image frame'),
        exception: exception,
        stack: stack,
        informationCollector: _informationCollector,
        silent: true,
      );
      return;
    }

    if (_codec!.frameCount == 1) {
      // This is not an animated image, just return it and don't schedule more
      // frames.
      _emitFrame(ImageInfo(image: _nextFrame!.image, scale: _scale));
      return;
    }

    _scheduleAppFrame();
  }

  void _scheduleAppFrame() {
    if (_frameCallbackScheduled) {
      return;
    }

    _frameCallbackScheduled = true;
    SchedulerBinding.instance!.scheduleFrameCallback(_handleAppFrame);
  }

  void _emitFrame(ImageInfo imageInfo) {
    setImage(imageInfo);
    _framesEmitted += 1;
  }

  @override
  void addListener(ImageStreamListener listener) {
    if (!hasListeners && _codec != null) {
      _decodeNextFrameAndSchedule();
    }

    super.addListener(listener);
  }

  @override
  void removeListener(ImageStreamListener listener) {
    super.removeListener(listener);

    if (!hasListeners) {
      _timer?.cancel();
      _timer = null;
    }
  }
}

typedef ErrorListener = void Function();

class CachedNetworkImageProvider
    extends ImageProvider<CachedNetworkImageProvider> {
  /// Creates an ImageProvider which loads an image from the [url], using the [scale].
  /// When the image fails to load [errorListener] is called.
  const CachedNetworkImageProvider(
    this.url, {
    this.scale = 1.0,
    this.errorListener,
    this.headers = const {},
    this.cacheManager,
  });

  final BaseCacheManager? cacheManager;

  /// Web url of the image to load
  final String url;

  /// Scale of the image
  final double scale;

  /// Listener to be called when images fails to load.
  final ErrorListener? errorListener;

  // Set headers for the image provider, for example for authentication
  final Map<String, String> headers;

  @override
  Future<CachedNetworkImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<CachedNetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(
    CachedNetworkImageProvider key,
    DecoderCallback decode,
  ) {
    final chunkEvents = StreamController<ImageChunkEvent>();

    return MultiImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>(
          'Image provider: $this \n Image key: $key',
          this,
          style: DiagnosticsTreeStyle.errorProperty,
        );
      },
    );
  }

  Future<Uint8List> getImageBytes() async {
    final mngr = cacheManager ?? DefaultCacheManager();
    final file = await mngr.getSingleFile(url, headers: headers);

    return file.readAsBytes();
  }

  Stream<ui.Codec> _loadAsync(
    CachedNetworkImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderCallback decode,
  ) async* {
    assert(key == this);
    try {
      final mngr = cacheManager ?? DefaultCacheManager();

      await for (final result in mngr.getFileStream(
        key.url,
        withProgress: true,
        headers: headers,
      )) {
        if (result is DownloadProgress) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: result.downloaded,
            expectedTotalBytes: result.totalSize,
          ));
        }

        if (result is FileInfo) {
          final file = result.file;
          final bytes = await file.readAsBytes();
          final decoded = await decode(bytes);
          yield decoded;
        }
      }
    } catch (e) {
      errorListener?.call();
      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  bool operator ==(other) {
    if (other is CachedNetworkImageProvider) {
      return url == other.url && scale == other.scale;
    }

    return false;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}

class CachedNetworkImage extends StatelessWidget {
  const CachedNetworkImage({
    Key? key,
    this.url,
    this.width,
    this.height,
    this.size,
    this.shape = BoxShape.rectangle,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.backgroundColor,
    this.color,
    this.colorBlendMode,
  }) : super(key: key);

  final String? url;
  final double? width;
  final double? height;
  final double? size;
  final BoxShape shape;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? color;
  final BlendMode? colorBlendMode;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);

    if (url == null) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.imageBackgroundColor,
          shape: shape,
          borderRadius: borderRadius,
        ),
        width: width ?? size,
        height: height ?? size,
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.imageBackgroundColor,
        shape: shape,
        borderRadius: borderRadius,
      ),
      width: width ?? size,
      height: height ?? size,
      child: Image(
        image: CachedNetworkImageProvider(url!),
        width: width ?? size,
        height: height ?? size,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
      ),
    );
  }
}
