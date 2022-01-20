import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../design/design_token.dart';
import '../localizations/framework.dart';
import '../localizations/rtl.dart';
import '../themes/dark.dart';
import '../themes/light.dart';
import '../transitions/fade_in.dart';
import '../transitions/fade_in_up.dart';
import '../transitions/slide.dart';
import 'global_navigator.dart';
import 'theme_provider.dart';

class RhythmApp extends StatefulWidget {
  const RhythmApp({
    Key? key,
    this.home,
    this.routes = const {},
    this.initialRoute,
    this.navigatorObservers = const [],
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
    this.useInheritedMediaQuery = false,
    this.theme,
    this.darkTheme,
  })  : backButtonDispatcher = null,
        super(key: key);

  /// {@macro flutter.widgets.widgetsApp.home}
  final Widget? home;

  /// The application's top-level routing table.
  ///
  /// When a named route is pushed with [Navigator.pushNamed], the route name is
  /// looked up in this map. If the name is present, the associated
  /// [widgets.WidgetBuilder] is used to construct a [PageRoute] that
  /// performs an appropriate transition, including [Hero] animations, to the
  /// new route.
  ///
  /// {@macro flutter.widgets.widgetsApp.routes}
  final Map<String, RouteBuilder> routes;

  final String? initialRoute;

  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  final List<NavigatorObserver>? navigatorObservers;

  /// {@macro flutter.widgets.widgetsApp.backButtonDispatcher}
  final BackButtonDispatcher? backButtonDispatcher;

  /// {@macro flutter.widgets.widgetsApp.builder}
  final TransitionBuilder? builder;

  /// {@macro flutter.widgets.widgetsApp.title}
  ///
  /// This value is passed unmodified to [WidgetsApp.title].
  final String title;

  /// {@macro flutter.widgets.widgetsApp.onGenerateTitle}
  ///
  /// This value is passed unmodified to [WidgetsApp.onGenerateTitle].
  final GenerateAppTitle? onGenerateTitle;

  /// {@macro flutter.widgets.widgetsApp.color}
  final Color? color;

  /// {@macro flutter.widgets.widgetsApp.locale}
  final Locale? locale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// {@macro flutter.widgets.widgetsApp.localeListResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// {@macro flutter.widgets.LocaleResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  ///
  /// It is passed along unmodified to the [WidgetsApp] built by this widget.
  final Iterable<Locale> supportedLocales;

  /// Turns on a performance overlay.
  ///
  /// See also:
  ///
  ///  * <https://flutter.dev/debugging/#performanceoverlay>
  final bool showPerformanceOverlay;

  /// Turns on checkerboarding of raster cache images.
  final bool checkerboardRasterCacheImages;

  /// Turns on checkerboarding of layers rendered to offscreen bitmaps.
  final bool checkerboardOffscreenLayers;

  /// Turns on an overlay that shows the accessibility information
  /// reported by the framework.
  final bool showSemanticsDebugger;

  /// {@macro flutter.widgets.widgetsApp.debugShowCheckedModeBanner}
  final bool debugShowCheckedModeBanner;

  /// {@macro flutter.widgets.widgetsApp.shortcuts}
  /// {@tool snippet}
  /// This example shows how to add a single shortcut for
  /// [LogicalKeyboardKey.select] to the default shortcuts without needing to
  /// add your own [Shortcuts] widget.
  ///
  /// Alternatively, you could insert a [Shortcuts] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     shortcuts: <ShortcutActivator, Intent>{
  ///       ... WidgetsApp.defaultShortcuts,
  ///       const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.shortcuts.seeAlso}
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// {@macro flutter.widgets.widgetsApp.actions}
  /// {@tool snippet}
  /// This example shows how to add a single action handling an
  /// [ActivateAction] to the default actions without needing to
  /// add your own [Actions] widget.
  ///
  /// Alternatively, you could insert a [Actions] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     actions: <Type, Action<Intent>>{
  ///       ... WidgetsApp.defaultActions,
  ///       ActivateAction: CallbackAction<Intent>(
  ///         onInvoke: (Intent intent) {
  ///           // Do something here...
  ///           return null;
  ///         },
  ///       ),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget? child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.actions.seeAlso}
  final Map<Type, Action<Intent>>? actions;

  /// {@macro flutter.widgets.widgetsApp.restorationScopeId}
  final String? restorationScopeId;

  /// {@macro flutter.material.materialApp.scrollBehavior}
  ///
  /// When null, defaults to [ScrollBehavior].
  ///
  /// See also:
  ///
  ///  * [ScrollConfiguration], which controls how [Scrollable] widgets behave
  ///    in a subtree.
  final ScrollBehavior? scrollBehavior;

  /// {@macro flutter.widgets.widgetsApp.useInheritedMediaQuery}
  final bool useInheritedMediaQuery;

  final DesignToken? theme;
  final DesignToken? darkTheme;

  @override
  State<RhythmApp> createState() => _RhythmAppState();
}

class _RhythmAppState extends State<RhythmApp> {
  late HeroController _heroController;
  late List<LocalizationsDelegate> _localizationsDelegates;

  SingletonFlutterWindow get _window => WidgetsBinding.instance!.window;
  MediaQueryData get _mediaQuery => MediaQueryData.fromWindow(window);

  DesignToken get _theme {
    final brightness = _mediaQuery.platformBrightness;

    if (brightness == Brightness.dark) {
      return widget.darkTheme ?? DarkTheme();
    }

    return widget.theme ?? LightTheme();
  }

  @override
  void initState() {
    super.initState();

    _heroController = HeroController();

    _localizationsDelegates = [
      FrameworkLocalizations.delegate,
      RtlLocalizations.delegate,
      ...widget.localizationsDelegates ?? []
    ];

    _window.onPlatformBrightnessChanged = () {
      setState(() {
        // Re-render all widgets if brightness changed
      });
    };

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {}
      if (msg == AppLifecycleState.inactive.toString()) {}
    });
  }

  Widget _inspectorSelectButtonBuilder(
    BuildContext context,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: const Text('Inspect'),
    );
  }

  WidgetsApp _buildWidgetApp(BuildContext context) {
    return WidgetsApp(
      key: GlobalObjectKey(this),
      navigatorKey: GlobalNavigator.navigatorKey,
      navigatorObservers: widget.navigatorObservers!,
      home: widget.home,
      initialRoute: widget.initialRoute,
      onGenerateRoute: (settings) {
        final args = settings.arguments;
        final params = args is PushRouteOptions ? args.params : args;
        final transitionStyle = args is PushRouteOptions
            ? args.transitionStyle
            : RouteTransitionStyle.slide;

        final routeName = settings.name;

        if (!widget.routes.containsKey(routeName)) {
          throw Exception('route [$routeName] is undefined');
        }

        switch (transitionStyle) {
          case RouteTransitionStyle.fadeIn:
            return FadeInRoute(
              builder: (context) => widget.routes[routeName!]!(params),
              settings: settings,
            );
          case RouteTransitionStyle.fadeInUp:
            return FadeInUpRoute(
              builder: (context) => widget.routes[routeName!]!(params),
              settings: settings,
            );
          case RouteTransitionStyle.slide:
          default:
            return SlidePageRoute(
              builder: (context) => widget.routes[routeName!]!(params),
              settings: settings,
            );
        }
      },
      builder: widget.builder,
      title: widget.title,
      onGenerateTitle: widget.onGenerateTitle,
      textStyle: _theme.textStyle,
      color: widget.color ?? _theme.primaryColor,
      locale: widget.locale,
      localizationsDelegates: _localizationsDelegates,
      localeResolutionCallback: widget.localeResolutionCallback,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      supportedLocales: widget.supportedLocales,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
      showSemanticsDebugger: widget.showSemanticsDebugger,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      inspectorSelectButtonBuilder: _inspectorSelectButtonBuilder,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
      restorationScopeId: widget.restorationScopeId,
      useInheritedMediaQuery: widget.useInheritedMediaQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget builder = ScrollConfiguration(
      behavior: widget.scrollBehavior ?? const _ScrollBehavior(),
      child: ThemeProvider(
        designToken: _theme,
        child: HeroControllerScope(
          controller: _heroController,
          child: Builder(builder: _buildWidgetApp),
        ),
      ),
    );

    if (!_mediaQuery.accessibleNavigation) {
      builder = ExcludeSemantics(child: builder);
    }

    return builder;
  }
}

class _ScrollBehavior extends ScrollBehavior {
  const _ScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
