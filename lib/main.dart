import 'dart:async';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
// LatLng do FlutterFlow
import 'package:geolocator/geolocator.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    GoRouter.optionURLReflectsImperativeAPIs = true;
    usePathUrlStrategy();

    // Global error handlers to prevent unexpected app exits
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ' + details.exceptionAsString());
      if (details.stack != null) debugPrintStack(stackTrace: details.stack);
    };
    try {
      ui.PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('PlatformDispatcher error: ' + error.toString());
        debugPrintStack(stackTrace: stack);
        return true; // mark as handled to avoid process termination
      };
    } catch (_) {}

    await initFirebase();
    await FFLocalizations.initialize();

    final appState = FFAppState();
    await appState.initializePersistedState();

    runApp(ChangeNotifierProvider(
      create: (context) => appState,
      child: MyApp(),
    ));
  }, (error, stack) {
    debugPrint('Uncaught zone error: ' + error.toString());
    debugPrintStack(stackTrace: stack);
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = FFLocalizations.getStoredLocale();
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
    userStream = rideBahamasFirebaseUserStream()
      ..listen((user) {
        _appStateNotifier.update(user);
      });
    jwtTokenStream.listen((_) {});
    Future.delayed(
      const Duration(milliseconds: 3500),
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
    FFLocalizations.storeLocale(language);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ride Bahamas',
      localizationsDelegates: const [
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
        Locale('pt'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.dragged)) {
              return const Color(0xFFFECE44);
            }
            if (states.contains(WidgetState.hovered)) {
              return const Color(0xFFFECE44);
            }
            return const Color(0xFFFECE44);
          }),
        ),
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,

      // >>> Envia a localização em tempo real para FFAppState.latlngAtual
      builder: (context, child) => LiveLocationTicker(child: child!),
    );
  }
}

/// Widget que mantém FFAppState.latlngAtual atualizado em tempo real
class LiveLocationTicker extends StatefulWidget {
  const LiveLocationTicker({super.key, required this.child});
  final Widget child;

  @override
  State<LiveLocationTicker> createState() => _LiveLocationTickerState();
}

class _LiveLocationTickerState extends State<LiveLocationTicker> {
  StreamSubscription<Position>? _sub;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    // Habilitado?
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    // Permissões
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      return;
    }

    // Posição inicial (best effort)
    try {
      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _push(p);
    } catch (_) {}

    // Stream contínua
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5, // atualiza a cada ~5m
      timeLimit: null,
    );

    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(
      _push,
      onError: (e) {
        // silencioso
      },
    );
  }

  void _push(Position p) {
    final app = context.read<FFAppState>();
    // evita (0,0)
    final isZero = (p.latitude == 0.0 && p.longitude == 0.0);
    if (isZero) return;

    app.latlngAtual = LatLng(p.latitude, p.longitude);
    app.update(() {}); // notifica watchers (ex.: Home5)
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
