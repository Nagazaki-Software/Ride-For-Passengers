import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';

import '/auth/base_auth_user_provider.dart';

import '/backend/push_notifications/push_notifications_handler.dart'
    show PushNotificationsHandler;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? Home5Widget() : GetStarted00Widget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
              appStateNotifier.loggedIn ? Home5Widget() : GetStarted00Widget(),
        ),
        FFRoute(
          name: GetStarted00Widget.routeName,
          path: GetStarted00Widget.routePath,
          builder: (context, params) => GetStarted00Widget(),
        ),
        FFRoute(
          name: ContinueAs1Widget.routeName,
          path: ContinueAs1Widget.routePath,
          builder: (context, params) => ContinueAs1Widget(),
        ),
        FFRoute(
          name: CreateProfile2Widget.routeName,
          path: CreateProfile2Widget.routePath,
          builder: (context, params) => CreateProfile2Widget(
            quickyPlataform: params.getParam(
              'quickyPlataform',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: VerifyAccount3Widget.routeName,
          path: VerifyAccount3Widget.routePath,
          builder: (context, params) => VerifyAccount3Widget(
            plataform: params.getParam(
              'plataform',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: Home5Widget.routeName,
          path: Home5Widget.routePath,
          builder: (context, params) => Home5Widget(),
        ),
        FFRoute(
          name: ChoosePass4Widget.routeName,
          path: ChoosePass4Widget.routePath,
          builder: (context, params) => ChoosePass4Widget(),
        ),
        FFRoute(
          name: RideShare6Widget.routeName,
          path: RideShare6Widget.routePath,
          builder: (context, params) => RideShare6Widget(
            value: params.getParam(
              'value',
              ParamType.double,
            ),
            latlngOrigem: params.getParam(
              'latlngOrigem',
              ParamType.LatLng,
            ),
            latlngDestino: params.getParam(
              'latlngDestino',
              ParamType.LatLng,
            ),
            estilo: params.getParam(
              'estilo',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: PaymentRide7Widget.routeName,
          path: PaymentRide7Widget.routePath,
          builder: (context, params) => PaymentRide7Widget(
            estilo: params.getParam(
              'estilo',
              ParamType.String,
            ),
            latlngAtual: params.getParam(
              'latlngAtual',
              ParamType.LatLng,
            ),
            latlngWhereTo: params.getParam(
              'latlngWhereTo',
              ParamType.LatLng,
            ),
            value: params.getParam(
              'value',
              ParamType.double,
            ),
          ),
        ),
        FFRoute(
          name: FindingDrive8Widget.routeName,
          path: FindingDrive8Widget.routePath,
          builder: (context, params) => FindingDrive8Widget(
            rideOrder: params.getParam(
              'rideOrder',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['rideOrders'],
            ),
          ),
        ),
        FFRoute(
          name: PickingYou9Widget.routeName,
          path: PickingYou9Widget.routePath,
          builder: (context, params) => PickingYou9Widget(
            order: params.getParam(
              'order',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['rideOrders'],
            ),
          ),
        ),
        FFRoute(
          name: Login0Widget.routeName,
          path: Login0Widget.routePath,
          builder: (context, params) => Login0Widget(),
        ),
        FFRoute(
          name: RideProgress10Widget.routeName,
          path: RideProgress10Widget.routePath,
          builder: (context, params) => RideProgress10Widget(),
        ),
        FFRoute(
          name: RideProgressCopy11Widget.routeName,
          path: RideProgressCopy11Widget.routePath,
          builder: (context, params) => RideProgressCopy11Widget(),
        ),
        FFRoute(
          name: HowDriveDo12Widget.routeName,
          path: HowDriveDo12Widget.routePath,
          builder: (context, params) => HowDriveDo12Widget(),
        ),
        FFRoute(
          name: Rewards13Widget.routeName,
          path: Rewards13Widget.routePath,
          builder: (context, params) => Rewards13Widget(),
        ),
        FFRoute(
          name: ScheduleRiderWidget.routeName,
          path: ScheduleRiderWidget.routePath,
          builder: (context, params) => ScheduleRiderWidget(),
        ),
        FFRoute(
          name: Profile15Widget.routeName,
          path: Profile15Widget.routePath,
          builder: (context, params) => Profile15Widget(),
        ),
        FFRoute(
          name: PaymentMothods16Widget.routeName,
          path: PaymentMothods16Widget.routePath,
          builder: (context, params) => PaymentMothods16Widget(),
        ),
        FFRoute(
          name: Rewards17Widget.routeName,
          path: Rewards17Widget.routePath,
          builder: (context, params) => Rewards17Widget(),
        ),
        FFRoute(
          name: Activity18Widget.routeName,
          path: Activity18Widget.routePath,
          builder: (context, params) => Activity18Widget(),
        ),
        FFRoute(
          name: Preferences19Widget.routeName,
          path: Preferences19Widget.routePath,
          builder: (context, params) => Preferences19Widget(),
        ),
        FFRoute(
          name: Activity20Widget.routeName,
          path: Activity20Widget.routePath,
          builder: (context, params) => Activity20Widget(),
        ),
        FFRoute(
          name: SafetyToolkit21Widget.routeName,
          path: SafetyToolkit21Widget.routePath,
          builder: (context, params) => SafetyToolkit21Widget(),
        ),
        FFRoute(
          name: Support22Widget.routeName,
          path: Support22Widget.routePath,
          builder: (context, params) => Support22Widget(),
        ),
        FFRoute(
          name: Legal23Widget.routeName,
          path: Legal23Widget.routePath,
          builder: (context, params) => Legal23Widget(),
        ),
        FFRoute(
          name: MyPass24Widget.routeName,
          path: MyPass24Widget.routePath,
          builder: (context, params) => MyPass24Widget(),
        ),
        FFRoute(
          name: CreateProfile2CopyWidget.routeName,
          path: CreateProfile2CopyWidget.routePath,
          builder: (context, params) => CreateProfile2CopyWidget(
            quickyPlataform: params.getParam(
              'quickyPlataform',
              ParamType.String,
            ),
          ),
        ),
        FFRoute(
          name: ViewDetalhesWidget.routeName,
          path: ViewDetalhesWidget.routePath,
          builder: (context, params) => ViewDetalhesWidget(
            order: params.getParam(
              'order',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['rideOrders'],
            ),
          ),
        ),
        FFRoute(
          name: Support22CopyWidget.routeName,
          path: Support22CopyWidget.routePath,
          builder: (context, params) => Support22CopyWidget(),
        ),
        FFRoute(
          name: Notification27Widget.routeName,
          path: Notification27Widget.routePath,
          builder: (context, params) => Notification27Widget(),
        ),
        FFRoute(
          name: HelpWidget.routeName,
          path: HelpWidget.routePath,
          builder: (context, params) => HelpWidget(),
        ),
        FFRoute(
          name: CustomerSupport26Widget.routeName,
          path: CustomerSupport26Widget.routePath,
          builder: (context, params) => CustomerSupport26Widget(),
        ),
        FFRoute(
          name: FrequentlyAskedQuestions25Widget.routeName,
          path: FrequentlyAskedQuestions25Widget.routePath,
          builder: (context, params) => FrequentlyAskedQuestions25Widget(),
        ),
        FFRoute(
          name: Reportaproblem28Widget.routeName,
          path: Reportaproblem28Widget.routePath,
          builder: (context, params) => Reportaproblem28Widget(),
        ),
        FFRoute(
          name: ChatSupportWidget.routeName,
          path: ChatSupportWidget.routePath,
          builder: (context, params) => ChatSupportWidget(
            chat: params.getParam(
              'chat',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['chat'],
            ),
          ),
        ),
        FFRoute(
          name: PrivacyPolicy29Widget.routeName,
          path: PrivacyPolicy29Widget.routePath,
          builder: (context, params) => PrivacyPolicy29Widget(),
        ),
        FFRoute(
          name: TermsofService30Widget.routeName,
          path: TermsofService30Widget.routePath,
          builder: (context, params) => TermsofService30Widget(),
        ),
        FFRoute(
          name: Licenses31Widget.routeName,
          path: Licenses31Widget.routePath,
          builder: (context, params) => Licenses31Widget(),
        ),
        FFRoute(
          name: Receipts33Widget.routeName,
          path: Receipts33Widget.routePath,
          builder: (context, params) => Receipts33Widget(),
        ),
        FFRoute(
          name: DriverReviews32Widget.routeName,
          path: DriverReviews32Widget.routePath,
          builder: (context, params) => DriverReviews32Widget(
            user: params.getParam(
              'user',
              ParamType.DocumentReference,
              isList: false,
              collectionNamePath: ['users'],
            ),
          ),
        ),
        FFRoute(
          name: PrivacyPolicy29CopyWidget.routeName,
          path: PrivacyPolicy29CopyWidget.routePath,
          builder: (context, params) => PrivacyPolicy29CopyWidget(),
        )
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/getStarted00';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Container(
                  color: FlutterFlowTheme.of(context).primaryText,
                  child: Image.asset(
                    'assets/images/ChatGPT_Image_19_de_ago._de_2025,_10_05_00.png',
                    fit: BoxFit.contain,
                  ),
                )
              : PushNotificationsHandler(child: page);

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
