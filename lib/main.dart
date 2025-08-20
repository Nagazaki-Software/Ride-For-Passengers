import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';

import 'package:flutter/scheduler.dart' show SchedulerBinding;



// IMPORTANTE: traz as suas custom actions (start/stop location)
import '/custom_code/actions/index.dart'; // startLocationStreamSimple / stopLocationStreamSimple

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  runApp(
    ChangeNotifierProvider(
      create: (context) => appState,
      child: _AppBootstrap(child: MyApp()),
    ),
  );
}

/// Envolve o app e gerencia o ciclo de vida para ligar/desligar o stream.
/// - Liga ao iniciar (primeiro frame)
/// - Pausa quando o app vai para background
/// - Retoma quando volta para foreground
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap({required this.child});
  final Widget child;

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap>
    with WidgetsBindingObserver {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Garante que chamamos o start depois que o primeiro frame montar o contexto.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await _startLocationSafe();
    });
  }

  Future<void> _startLocationSafe() async {
    if (_started) return;
    _started = true;

    try {
      // Inicia o stream em foreground (app estilo Uber = sempre ligado ao abrir)
      await startLocationStreamSimple(context);
    } catch (e) {
      // Se algo falhar, não derruba o app; logue se quiser
      // debugPrint('startLocationStreamSimple error: $e');
      _started = false; // permite tentar novamente se precisar
    }
  }

  Future<void> _stopLocationSafe() async {
    try {
      await stopLocationStreamSimple(context);
    } catch (_) {}
    _started = false;
  }

  /// Observa mudanças de estado do app para pausar/retomar localização em tempo real.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Foreground = resumed; Background = paused/detached/inactive (web pode variar)
    if (state == AppLifecycleState.resumed) {
      // Voltou ao foreground → retoma se não estiver ativo
      _startLocationSafe();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // Saiu do foreground → para para economizar e seguir "foreground-only"
      _stopLocationSafe();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLocationSafe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Envolve o app para termos um contexto válido nas actions
    return widget.child;
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = rideForPassengersFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(milliseconds: 1000),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();

    super.dispose();
  }

  void setLocale(String language) {
    safeSetState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ride For Passengers',
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
