import 'dart:async';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'flutter_flow/lat_lng.dart'; // LatLng do FlutterFlow
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // Preaquece ícones do mapa para reduzir jank e telas brancas.
  // Executa em background; não bloqueia o app start.
  unawaited(_prewarmMapAssets());

  await initFirebase();
  await FFLocalizations.initialize();

  final appState = FFAppState();
  await appState.initializePersistedState();

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}

// Faz download leve de ícones usados por marcadores do mapa e deixa no cache de disco.
Future<void> _prewarmMapAssets() async {
  try {
    const urls = [
      // destino e motoristas
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/qvt0qjxl02os/ChatGPT_Image_16_de_ago._de_2025%2C_16_36_59.png',
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/hlhwt7mbve4j/ChatGPT_Image_3_de_set._de_2025%2C_15_02_50.png',
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/ride-899y4i/assets/bgmclb0d2bsd/ChatGPT_Image_3_de_set._de_2025%2C_19_17_48.png',
    ];
    final cm = DefaultCacheManager();
    for (final u in urls) {
      try {
        final hit = await cm.getFileFromCache(u);
        if (hit == null) {
          await cm.downloadFile(u);
        }
      } catch (_) {}
    }
  } catch (_) {}
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
      builder: (context, child) => Container(
        color: const Color(0xFF0F1217),
        child: LiveLocationTicker(child: child!),
      ),
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
    _cacheCameraForNative(p.latitude, p.longitude);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// Grava rapidamente a última câmera esperada para o mapa nativo
Future<void> _cacheCameraForNative(double lat, double lng) async {
  try {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble('camera_lat', lat);
    await sp.setDouble('camera_lng', lng);
    await sp.setDouble('camera_zoom', 16.0);
    await sp.setDouble('camera_tilt', 0.0);
    await sp.setDouble('camera_bearing', 0.0);
  } catch (_) {}
}
