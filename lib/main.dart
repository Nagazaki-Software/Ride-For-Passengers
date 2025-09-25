import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import 'backend/push_notifications/push_notifications_util.dart';
import 'notifications/ride_step_notifications2.dart';
import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'custom_code/widgets/map_warmup_permanent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  try {
    await initFirebase().timeout(const Duration(seconds: 8));
  } catch (e, st) {
    debugPrint('initFirebase error/timeout: $e');
    debugPrint('$st');
  }

  // Initialize cross‑platform local notifications and iOS foreground options
  try {
    await RideStepNotifications.init().timeout(const Duration(seconds: 5));
  } catch (e, st) {
    debugPrint('RideStepNotifications.init error/timeout: $e');
    debugPrint('$st');
  }

  try {
    await FFLocalizations.initialize().timeout(const Duration(seconds: 5));
  } catch (e, st) {
    debugPrint('FFLocalizations.initialize error/timeout: $e');
    debugPrint('$st');
  }

  final appState = FFAppState(); // Initialize FFAppState
  try {
    await appState.initializePersistedState().timeout(const Duration(seconds: 5));
  } catch (e, st) {
    debugPrint('initializePersistedState error/timeout: $e');
    debugPrint('$st');
  }

  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
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
  final fcmTokenSub = fcmTokenUserStream.listen((_) {});

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
      Duration(milliseconds: 3500),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();
    fcmTokenSub.cancel();
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
              return Color(4280558628);
            }
            if (states.contains(WidgetState.hovered)) {
              return Color(4280558628);
            }
            return Color(4280558628);
          }),
        ),
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
      builder: (context, child) {
        // Keep a permanent native map warm and icons prefetched, app-wide.
        return Stack(
          children: [
            if (child != null) child,
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: SafeArea(
                  // Keep it mounted across all routes
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: SizedBox(
                      width: 2,
                      height: 2,
                      child: Opacity(
                        opacity: 0.0,
                        child: _GlobalWarmupHolder(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Separate widget to avoid rebuilding warmup unnecessarily.
class _GlobalWarmupHolder extends StatelessWidget {
  const _GlobalWarmupHolder();
  @override
  Widget build(BuildContext context) {
    // Permanent warmup overlay (native only) + icon prefetch inside it.
    return const MapWarmupPermanent();
  }
}
