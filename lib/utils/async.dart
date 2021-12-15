import 'dart:async';
import 'dart:collection';

export 'dart:async' show unawaited;

typedef PromiseCallback<T> = Function(
  Function([T?]) resolve,
  Function(Object) reject,
);

Future<void> untilCompleted(
  Function() cb, {
  Duration retryDuration = Duration.zero,
}) async {
  while (true) {
    try {
      await cb();
      break;
    } catch (error) {
      await Future.delayed(retryDuration);
    }
  }
}

Future<T> useFuture<T>(PromiseCallback<T> cb) {
  final completer = Completer<T>();

  cb(
    ([result]) => completer.complete(result),
    (error) => completer.completeError(error),
  );

  return completer.future;
}

///  Debouncer
///  Have method [debounce]
class Debouncer {
  Duration _duration;
  Duration get duration => _duration;

  set duration(Duration value) {
    assert(!duration.isNegative);
    _duration = value;
  }

  Timer? _waiter;
  bool _isReady = true;
  bool get isReady => _isReady;

  final _resultSC = StreamController<dynamic>.broadcast();
  final _stateSC = StreamController<bool>.broadcast();

  Debouncer({Duration duration = const Duration(seconds: 1)})
      : assert(!duration.isNegative),
        _duration = duration {
    _stateSC.sink.add(true);
  }

  Future<T?> debounce<T>(T? Function() func) async {
    if (_waiter?.isActive ?? false) {
      _waiter?.cancel();
      _resultSC.sink.add(null);
    }

    _isReady = false;
    _stateSC.sink.add(false);
    _waiter = Timer(_duration, () {
      _isReady = true;
      _stateSC.sink.add(true);
      _resultSC.sink.add(Function.apply(func, []));
    });

    return await _resultSC.stream.first as T?;
  }

  StreamSubscription<bool> listen(Function(bool) onData) =>
      _stateSC.stream.listen(onData);

  void dispose() {
    _resultSC.close();
    _stateSC.close();
  }
}

///  Throttler
///  Have method [throttle]
class Throttler {
  Duration _duration;
  Duration get duration => _duration;

  set duration(Duration value) {
    assert(!duration.isNegative);
    _duration = value;
  }

  bool _isReady = true;
  bool get isReady => _isReady;
  Future<void> get _waiter => Future.delayed(_duration);

  final _stateSC = StreamController<bool>.broadcast();

  Throttler({Duration duration = const Duration(seconds: 1)})
      : assert(!duration.isNegative),
        _duration = duration {
    _stateSC.sink.add(true);
  }

  T? throttle<T>(T Function() func) {
    if (!_isReady) return null;

    _stateSC.sink.add(false);
    _isReady = false;

    _waiter.then((_) {
      _isReady = true;
      _stateSC.sink.add(true);
    });

    return Function.apply(func, []) as T;
  }

  StreamSubscription<bool> listen(Function(bool) onData) =>
      _stateSC.stream.listen(onData);

  void dispose() {
    _stateSC.close();
  }
}

///  Postponer
///  Have method [postpone]
class Postponer {
  Duration _duration;
  Duration get duration => _duration;

  set duration(Duration value) {
    assert(!duration.isNegative);
    _duration = value;
  }

  final _queue = Queue<Function>();

  Timer? _timer;

  Postponer({Duration duration = const Duration(seconds: 1)})
      : assert(!duration.isNegative),
        _duration = duration;

  void postpone(Function func) {
    if (_timer == null) {
      _timer = Timer.periodic(_duration, (_) => _scan());

      Function.apply(func, []);
    } else {
      _queue.add(func);
    }
  }

  void _scan() {
    if (_queue.isEmpty) {
      _timer?.cancel();
      _timer = null;
    } else {
      final cb = _queue.removeFirst();
      Function.apply(cb, []);

      if (_queue.isEmpty) {
        _timer?.cancel();
        _timer = null;
      }
    }
  }
}
