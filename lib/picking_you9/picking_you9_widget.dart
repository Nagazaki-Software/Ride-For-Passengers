import '/backend/backend.dart';
import '/components/emergency_widget.dart';
import '/components/schedule_picku_up_widget.dart';
import '/components/tip_driver_widget.dart';
import '/components/why_cancel_this_ride_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import '/notifications/ride_step_notifications2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'picking_you9_model.dart';
export 'picking_you9_model.dart';

class PickingYou9Widget extends StatefulWidget {
  const PickingYou9Widget({super.key, required this.order});

  final DocumentReference? order;

  static String routeName = 'PickingYou9';
  static String routePath = '/pickingYou9';

  @override
  State<PickingYou9Widget> createState() => _PickingYou9WidgetState();
}

class _PickingYou9WidgetState extends State<PickingYou9Widget>
    with TickerProviderStateMixin {
  late PickingYou9Model _model;
  String? _lastNotifKey;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;
  var hasImageTriggered = false;
  var hasContainerTriggered1 = false;
  var hasContainerTriggered2 = false;
  var hasContainerTriggered3 = false;
  var hasContainerTriggered4 = false;
  var hasContainerTriggered5 = false;
  var hasContainerTriggered6 = false;
  var hasContainerTriggered7 = false;
  final animationsMap = <String, AnimationInfo>{};

  // --- Auto-advance guards (proximity + dwell) ---
  DateTime? _nearPickupSince;
  DateTime? _nearDestinationSince;
  // Tunable thresholds (meters/seconds)
  static const int _pickupEnterMeters = 70; // when driver gets close to user
  static const int _destEnterMeters = 80; // when driver gets close to destination
  static const int _dwellSeconds = 8; // must remain inside for this long

  double _haversineMeters(LatLng a, LatLng b) {
    const double R = 6371000.0; // Earth radius (m)
    final double dLat = (b.latitude - a.latitude) * (pi / 180.0);
    final double dLon = (b.longitude - a.longitude) * (pi / 180.0);
    final double la1 = a.latitude * (pi / 180.0);
    final double la2 = b.latitude * (pi / 180.0);
    final double h =
        sin(dLat / 2) * sin(dLat / 2) + cos(la1) * cos(la2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(h), sqrt(1.0 - h));
    return R * c;
  }

  void _maybeAutoAdvance(RideOrdersRecord order, UsersRecord driver) {
    try {
      final String mode = FFAppState().pickingPage;
      final LatLng? driverLoc = driver.location ?? FFAppState().latlngAtual ?? currentUserLocationValue;
      if (driverLoc == null) return;

      // Coordinates from order
      final LatLng? pickup = order.latlngAtual; // pickup/user point at request time
      final LatLng? dest = order.latlng; // destination of the ride

      final DateTime now = DateTime.now();

      if (mode == 'pickingyou' && pickup != null) {
        final double d = _haversineMeters(driverLoc, pickup);
        if (d <= _pickupEnterMeters) {
          _nearPickupSince ??= now;
          if (now.difference(_nearPickupSince!).inSeconds >= _dwellSeconds) {
            // Advance to 'progress' once, with notify
            if (FFAppState().pickingPage != 'progress') {
              FFAppState().update(() => FFAppState().pickingPage = 'progress');
              // Reflect on notifications
              RideStepNotifications.showInProgress();
            }
          }
        } else {
          _nearPickupSince = null; // reset if we left the proximity
        }
      }

      if (mode == 'progress' && dest != null) {
        final double d = _haversineMeters(driverLoc, dest);
        if (d <= _destEnterMeters) {
          _nearDestinationSince ??= now;
          if (now.difference(_nearDestinationSince!).inSeconds >= _dwellSeconds) {
            if (FFAppState().pickingPage != 'finish') {
              FFAppState().update(() => FFAppState().pickingPage = 'finish');
              RideStepNotifications.showFinished();
            }
          }
        } else {
          _nearDestinationSince = null;
        }
      }
    } catch (_) {
      // best-effort; do not crash UI
    }
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r"\s+")).where((s) => s.isNotEmpty);
    return parts.take(2).map((s) => s[0].toUpperCase()).join();
  }

  Future<void> _notifyForCurrentStep(
    RideOrdersRecord order,
    UsersRecord driver,
  ) async {
    final mode = FFAppState().pickingPage;
    final rideId = (order.id.isNotEmpty ? order.id : order.reference.id);
    final price = order.rideValue;
    final title = 'Ride #$rideId  \$${price.toStringAsFixed(0)}';

    // Helpers to safely choose coordinates
    LatLng _coalesce(LatLng? a, LatLng? b, LatLng? c) => a ?? b ?? c ??
        const LatLng(0.0, 0.0);

    final userNow = FFAppState().latlngAtual ?? currentUserLocationValue;
    final driverLoc = driver.location ?? userNow;
    final origemPicking = _coalesce(driverLoc, order.latlngAtual, userNow);
    final destinoPicking = _coalesce(order.latlngAtual, userNow, driverLoc);
    final origemProgress = _coalesce(driverLoc, order.latlngAtual, userNow);
    final destinoProgress = _coalesce(order.latlng, order.latlngAtual, userNow);
    final origemFinish = _coalesce(order.latlngAtual, userNow, driverLoc);
    final destinoFinish = _coalesce(order.latlng, order.latlngAtual, userNow);

    String key = '$mode|$rideId';
    if (_lastNotifKey == key) return; // avoid spamming
    _lastNotifKey = key;

    if (mode == 'pickingyou') {
      final eta = functions.estimativeTime(origemPicking, destinoPicking);
      final body = 'Picking you • ETA $eta';
      await RideStepNotifications.showRidePickingDetail(
        title: title,
        body: body,
      );
    } else if (mode == 'progress') {
      final eta = functions.estimativeTime(origemProgress, destinoProgress);
      final body = 'In progress • ETA $eta';
      await RideStepNotifications.showRideInProgressDetail(
        title: title,
        body: body,
      );
    } else if (mode == 'finish') {
      final eta = functions.estimativeTime(origemFinish, destinoFinish);
      final body = 'Avaliate ride • Time $eta';
      await RideStepNotifications.showRideFinishedDetail(
        title: title,
        body: body,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PickingYou9Model());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'PickingYou9'});
    getCurrentUserLocation(
      defaultLocation: LatLng(0.0, 0.0),
      cached: true,
    ).then((loc) => safeSetState(() => currentUserLocationValue = loc));
    animationsMap.addAll({
      'imageOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1,
            end: 0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1,
            end: 0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1,
            end: 0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1,
            end: 0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1,
            end: 0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1,
            end: 0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1,
            end: 0,
          ),
        ],
      ),
      'containerOnActionTriggerAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1,
            end: 0,
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where(
        (anim) =>
            anim.trigger == AnimationTrigger.onActionTrigger ||
            !anim.applyInitialState,
      ),
      this,
    );
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: SpinKitDoubleBounce(
              color: FlutterFlowTheme.of(context).accent1,
              size: 50,
            ),
          ),
        ),
      );
    }

    if (widget.order == null) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).tertiary,
        body: Center(
          child: Text(
            'Pedido não encontrado',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ),
      );
    }

    return StreamBuilder<RideOrdersRecord>(
      stream: RideOrdersRecord.getDocument(widget!.order!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: FlutterFlowTheme.of(context).tertiary,
            body: Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: SpinKitDoubleBounce(
                  color: FlutterFlowTheme.of(context).accent1,
                  size: 50,
                ),
              ),
            ),
          );
        }

        final pickingYou9RideOrdersRecord = snapshot.data!;

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).tertiary,
            body: Stack(
              children: [
                Stack(
                  children: [
                    StreamBuilder<UsersRecord>(
                      stream: UsersRecord.getDocument(
                        pickingYou9RideOrdersRecord.driver!,
                      ),
                      builder: (context, snapshot) {
                        // Customize what your widget looks like when it's loading.
                        if (!snapshot.hasData) {
                          return Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: SpinKitDoubleBounce(
                                color: FlutterFlowTheme.of(context).accent1,
                                size: 50,
                              ),
                            ),
                          );
                        }

                        final pickingYouMapUsersRecord = snapshot.data!;
                        // Trigger step-based local notification from this page with ride id/value and ETA
                        _notifyForCurrentStep(
                          pickingYou9RideOrdersRecord,
                          pickingYouMapUsersRecord,
                        );
                        // Evaluate guarded auto-advance between pickingyou -> progress -> finish
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _maybeAutoAdvance(
                            pickingYou9RideOrdersRecord,
                            pickingYouMapUsersRecord,
                          );
                        });

                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: custom_widgets.PickingYouMap(
                            width: double.infinity,
                            height: double.infinity,
                            latlngOrigemPickingYou:
                                (pickingYouMapUsersRecord.location ?? currentUserLocationValue!),
                            latlngDestinoPickingYou:
                                (pickingYou9RideOrdersRecord.latlngAtual ?? pickingYouMapUsersRecord.location ?? currentUserLocationValue!),
                            latlngOrigemProgress:
                                (pickingYouMapUsersRecord.location ?? currentUserLocationValue!),
                            latlngDestinoProgress:
                                (pickingYou9RideOrdersRecord.latlng ?? pickingYou9RideOrdersRecord.latlngAtual ?? pickingYouMapUsersRecord.location ?? currentUserLocationValue!),
                            latlngOrigemFinish:
                                (pickingYou9RideOrdersRecord.latlngAtual ?? pickingYouMapUsersRecord.location ?? currentUserLocationValue!),
                            latlngDestinationFinish:
                                (pickingYou9RideOrdersRecord.latlng ?? pickingYou9RideOrdersRecord.latlngAtual ?? pickingYouMapUsersRecord.location ?? currentUserLocationValue!),
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 187.7,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xB517181D), Color(0x0717181D)],
                              stops: [0, 1],
                              begin: AlignmentDirectional(0, -1),
                              end: AlignmentDirectional(0, 1),
                            ),
                          ),
                          child: Stack(
                            children: [
                              if (FFAppState().pickingPage == 'pickingyou')
                                FutureBuilder<UsersRecord>(
                                  future: UsersRecord.getDocumentOnce(
                                    pickingYou9RideOrdersRecord.user!,
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: SpinKitDoubleBounce(
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).accent1,
                                            size: 50,
                                          ),
                                        ),
                                      );
                                    }

                                    final columnPickingYouUsersRecord =
                                        snapshot.data!;

                                    return Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  17,
                                                  20,
                                                  17,
                                                  0,
                                                ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                GradientText(
                                                  columnPickingYouUsersRecord
                                                      .displayName,
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).primaryBackground,
                                                        fontSize: 20,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                  colors: [
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).secondary,
                                                    FlutterFlowTheme.of(
                                                      context,
                                                    ).accent1,
                                                    Color(0xFFF2E0B3),
                                                  ],
                                                  gradientDirection:
                                                      GradientDirection.btt,
                                                  gradientType:
                                                      GradientType.linear,
                                                ),
                                                Text(
                                                  FFLocalizations.of(
                                                    context,
                                                  ).getText(
                                                    'jq444zfv' /* will be Pickign you up! */,
                                                  ),
                                                  style:
                                                      FlutterFlowTheme.of(
                                                        context,
                                                      ).bodyMedium.override(
                                                        font:
                                                            GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                              context,
                                                            ).alternate,
                                                        fontSize: 20,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                ),
                                              ].divide(SizedBox(width: 8)),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                18,
                                                16,
                                                18,
                                                0,
                                              ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Text(
                                                              FFLocalizations.of(
                                                                context,
                                                              ).getText(
                                                                'y1vsihrp' /* The car is Black */,
                                                              ),
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                font: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontWeight,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                ),
                                                                color:
                                                                    FlutterFlowTheme.of(
                                                                      context,
                                                                    ).alternate,
                                                                fontSize: 14,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Flexible(
                                                          child: GradientText(
                                                            columnPickingYouUsersRecord
                                                                .licences
                                                                .carName,
                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                              font: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).secondary,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                            colors: [
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).secondary,
                                                              FlutterFlowTheme.of(
                                                                context,
                                                              ).accent1,
                                                            ],
                                                            gradientDirection:
                                                                GradientDirection
                                                                    .ltr,
                                                            gradientType:
                                                                GradientType
                                                                    .linear,
                                                          ),
                                                        ),
                                                      ].divide(SizedBox(width: 8)),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Text(
                                                          FFLocalizations.of(
                                                            context,
                                                          ).getText(
                                                            '1t8w1ugq' /* see the exact photo of the car */,
                                                          ),
                                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                            font: GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                            color:
                                                                FlutterFlowTheme.of(
                                                                  context,
                                                                ).secondaryText,
                                                            fontSize: 10,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FlutterFlowTheme.of(
                                                                      context,
                                                                    )
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 82,
                                                height: 62,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).primaryText,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 1,
                                                      color: Color(0x33000000),
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  shape: BoxShape.rectangle,
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(
                                                      context,
                                                    ).alternate,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  child: Image.network(
                                                    columnPickingYouUsersRecord
                                                        .licences
                                                        .veiculoPhotos
                                                        .firstOrNull!,
                                                    width: 202,
                                                    height: 202,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(width: 12)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              if (FFAppState().pickingPage == 'progress')
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    17,
                                    20,
                                    12,
                                    0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                          0,
                                          20,
                                          0,
                                          0,
                                        ),
                                        child: Text(
                                          FFLocalizations.of(context).getText(
                                            '184e8z8s' /* Ride in Progress */,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).alternate,
                                                fontSize: 28,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 8)),
                                  ),
                                ),
                              if (FFAppState().pickingPage == 'finish')
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        17,
                                        20,
                                        12,
                                        0,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            FFLocalizations.of(context).getText(
                                              'qdvp4vi5' /* You Arrived at */,
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  color: FlutterFlowTheme.of(
                                                    context,
                                                  ).alternate,
                                                  fontSize: 28,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 8)),
                                      ),
                                    ),
                                    GradientText(
                                      '${pickingYou9RideOrdersRecord.nomeOrigem} #${pickingYou9RideOrdersRecord.id}',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).secondary,
                                            fontSize: 18,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                      colors: [
                                        FlutterFlowTheme.of(context).secondary,
                                        FlutterFlowTheme.of(context).accent1,
                                        Color(0xFFF9E9BE),
                                      ],
                                      gradientDirection: GradientDirection.btt,
                                      gradientType: GradientType.linear,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Align(
                          alignment: AlignmentDirectional(0, 1),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: MediaQuery.sizeOf(context).width * 10,
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0x7A414141),
                                      Color(0xAF17181D),
                                    ],
                                    stops: [0, 0.4],
                                    begin: AlignmentDirectional(0, -1),
                                    end: AlignmentDirectional(0, 1),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0),
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0x7A414141),
                                            Color(0xAF17181D),
                                          ],
                                          stops: [0, 0.4],
                                          begin: AlignmentDirectional(0, -1),
                                          end: AlignmentDirectional(0, 1),
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(0),
                                          bottomRight: Radius.circular(0),
                                          topLeft: Radius.circular(24),
                                          topRight: Radius.circular(24),
                                        ),
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        child: Stack(
                                          children: [
                                            if (FFAppState().pickingPage ==
                                                'progress')
                                              Padding(
                                                padding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                      12,
                                                      24,
                                                      12,
                                                      0,
                                                    ),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF1E1E20),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 4,
                                                        color: Color(
                                                          0x6C17181D,
                                                        ),
                                                        offset: Offset(2, -4),
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional.fromSTEB(
                                                          0,
                                                          10,
                                                          0,
                                                          0,
                                                        ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                10,
                                                              ),
                                                          child: Container(
                                                            width: 127.5,
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).tertiary,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      10,
                                                                  color:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).tertiary,
                                                                  offset:
                                                                      Offset(
                                                                        0,
                                                                        -2,
                                                                      ),
                                                                ),
                                                              ],
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    8,
                                                                  ),
                                                              child: FutureBuilder<UsersRecord>(
                                                                future: UsersRecord.getDocumentOnce(
                                                                  pickingYou9RideOrdersRecord
                                                                      .driver!,
                                                                ),
                                                                builder:
                                                                    (
                                                                      context,
                                                                      snapshot,
                                                                    ) {
                                                                      // Customize what your widget looks like when it's loading.
                                                                      if (!snapshot
                                                                          .hasData) {
                                                                        return Center(
                                                                          child: SizedBox(
                                                                            width:
                                                                                50,
                                                                            height:
                                                                                50,
                                                                            child: SpinKitDoubleBounce(
                                                                              color: FlutterFlowTheme.of(
                                                                                context,
                                                                              ).accent1,
                                                                              size: 50,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }

                                                                      final columnUsersRecord =
                                                                          snapshot
                                                                              .data!;

                                                                      return Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children:
                                                                            [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                children: [
                                                                                  Text(
                                                                                    FFLocalizations.of(
                                                                                      context,
                                                                                    ).getText(
                                                                                      '2fe69r0j' /* Price: */,
                                                                                    ),
                                                                                    style:
                                                                                        FlutterFlowTheme.of(
                                                                                          context,
                                                                                        ).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FlutterFlowTheme.of(
                                                                                              context,
                                                                                            ).bodyMedium.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(
                                                                                              context,
                                                                                            ).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).secondaryText,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).bodyMedium.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).bodyMedium.fontStyle,
                                                                                        ),
                                                                                  ),
                                                                                  GradientText(
                                                                                    formatNumber(
                                                                                      pickingYou9RideOrdersRecord.rideValue,
                                                                                      formatType: FormatType.decimal,
                                                                                      decimalType: DecimalType.periodDecimal,
                                                                                      currency: '\$ ',
                                                                                    ),
                                                                                    style:
                                                                                        FlutterFlowTheme.of(
                                                                                          context,
                                                                                        ).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(
                                                                                              context,
                                                                                            ).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).primaryBackground,
                                                                                          fontSize: 14,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).bodyMedium.fontStyle,
                                                                                        ),
                                                                                    colors: [
                                                                                      FlutterFlowTheme.of(
                                                                                        context,
                                                                                      ).secondary,
                                                                                      FlutterFlowTheme.of(
                                                                                        context,
                                                                                      ).accent1,
                                                                                    ],
                                                                                    gradientDirection: GradientDirection.ltr,
                                                                                    gradientType: GradientType.linear,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Container(
                                                                                width: 40,
                                                                                height: 40,
                                                                                clipBehavior: Clip.antiAlias,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: Image.network(
                                                                                  columnUsersRecord.photoUrl,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children:
                                                                                    [
                                                                                      Flexible(
                                                                                        child: Text(
                                                                                          functions.escolherPartesName(
                                                                                            columnUsersRecord.displayName,
                                                                                            1,
                                                                                          ),
                                                                                          style:
                                                                                              FlutterFlowTheme.of(
                                                                                                context,
                                                                                              ).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FontStyle.italic,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(
                                                                                                  context,
                                                                                                ).alternate,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FontStyle.italic,
                                                                                              ),
                                                                                        ),
                                                                                      ),
                                                                                      Flexible(
                                                                                        child: GradientText(
                                                                                          functions.escolherPartesName(
                                                                                            columnUsersRecord.displayName,
                                                                                            2,
                                                                                          ),
                                                                                          style:
                                                                                              FlutterFlowTheme.of(
                                                                                                context,
                                                                                              ).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontStyle: FontStyle.italic,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(
                                                                                                  context,
                                                                                                ).secondary,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                fontStyle: FontStyle.italic,
                                                                                              ),
                                                                                          colors: [
                                                                                            FlutterFlowTheme.of(
                                                                                              context,
                                                                                            ).secondary,
                                                                                            FlutterFlowTheme.of(
                                                                                              context,
                                                                                            ).accent1,
                                                                                          ],
                                                                                          gradientDirection: GradientDirection.ltr,
                                                                                          gradientType: GradientType.linear,
                                                                                        ),
                                                                                      ),
                                                                                    ].divide(
                                                                                      SizedBox(
                                                                                        width: 8,
                                                                                      ),
                                                                                    ),
                                                                              ),
                                                                              RatingBar.builder(
                                                                                onRatingUpdate:
                                                                                    (
                                                                                      newValue,
                                                                                    ) => safeSetState(
                                                                                      () => _model.ratingBarValue1 = newValue,
                                                                                    ),
                                                                                itemBuilder:
                                                                                    (
                                                                                      context,
                                                                                      index,
                                                                                    ) => Icon(
                                                                                      Icons.star_rounded,
                                                                                      color: FlutterFlowTheme.of(
                                                                                        context,
                                                                                      ).primaryBackground,
                                                                                    ),
                                                                                direction: Axis.horizontal,
                                                                                initialRating: _model.ratingBarValue1 ??= 3,
                                                                                unratedColor: FlutterFlowTheme.of(
                                                                                  context,
                                                                                ).primary,
                                                                                itemCount: 5,
                                                                                itemSize: 16,
                                                                                glowColor: FlutterFlowTheme.of(
                                                                                  context,
                                                                                ).primaryBackground,
                                                                              ),
                                                                            ].divide(
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                            ),
                                                                      );
                                                                    },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              FFLocalizations.of(
                                                                context,
                                                              ).getText(
                                                                'lt7cbmp9' /* Approximate time */,
                                                              ),
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                font: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontWeight,
                                                                  fontStyle:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                  context,
                                                                ).secondaryText,
                                                                fontSize: 12,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                fontStyle:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                              ),
                                                            ),
                                                            Text(
                                                              functions
                                                                  .estimativeTime(
                                                                    currentUserLocationValue!,
                                                                    pickingYou9RideOrdersRecord
                                                                        .latlng!,
                                                                  )
                                                                  .replaceAll('minutes', 'min')
                                                                  .replaceAll('minute', 'min'),
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                font: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                ),
                                                                color:
                                                                    FlutterFlowTheme.of(
                                                                      context,
                                                                    ).alternate,
                                                                fontSize: 22,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                            ),
                                                            Text(
                                                              FFLocalizations.of(
                                                                context,
                                                              ).getText(
                                                                '0s98a81g' /* Approximate ETA */,
                                                              ),
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                font: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontWeight,
                                                                  fontStyle:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontStyle,
                                                                ),
                                                                color: FlutterFlowTheme.of(
                                                                  context,
                                                                ).secondaryText,
                                                                fontSize: 12,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                fontStyle:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                              ),
                                                            ),
                                                            StreamBuilder<
                                                              UsersRecord
                                                            >(
                                                              stream: UsersRecord.getDocument(
                                                                pickingYou9RideOrdersRecord
                                                                    .driver!,
                                                              ),
                                                              builder: (context, snapshot) {
                                                                // Customize what your widget looks like when it's loading.
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Center(
                                                                    child: SizedBox(
                                                                      width: 50,
                                                                      height:
                                                                          50,
                                                                      child: SpinKitDoubleBounce(
                                                                        color: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).accent1,
                                                                        size:
                                                                            50,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }

                                                                final textUsersRecord =
                                                                    snapshot
                                                                        .data!;

                                                                return GradientText(
                                                                  functions.horariodechegada(
                                                                    textUsersRecord
                                                                        .location!,
                                                                    pickingYou9RideOrdersRecord
                                                                        .latlng!,
                                                                    getCurrentTimestamp,
                                                                  ),
                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                    font: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                      context,
                                                                    ).secondary,
                                                                    fontSize:
                                                                        18,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle:
                                                                        FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontStyle,
                                                                  ),
                                                                  colors: [
                                                                    FlutterFlowTheme.of(
                                                                      context,
                                                                    ).secondary,
                                                                    FlutterFlowTheme.of(
                                                                      context,
                                                                    ).accent1,
                                                                    Color(
                                                                      0xFFF0DBA6,
                                                                    ),
                                                                  ],
                                                                  gradientDirection:
                                                                      GradientDirection
                                                                          .btt,
                                                                  gradientType:
                                                                      GradientType
                                                                          .linear,
                                                                );
                                                              },
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children:
                                                                  [
                                                                    InkWell(
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      focusColor:
                                                                          Colors
                                                                              .transparent,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap: () async {
                                                                        logFirebaseEvent(
                                                                          'PICKING_YOU9_PAGE_Image_fb1jkezw_ON_TAP',
                                                                        );
                                                                        logFirebaseEvent(
                                                                          'Image_widget_animation',
                                                                        );
                                                                        if (animationsMap['imageOnActionTriggerAnimation'] !=
                                                                            null) {
                                                                          safeSetState(
                                                                            () =>
                                                                                hasImageTriggered = true,
                                                                          );
                                                                          SchedulerBinding.instance.addPostFrameCallback(
                                                                            (
                                                                              _,
                                                                            ) async => await animationsMap['imageOnActionTriggerAnimation']!.controller.forward(
                                                                              from: 0.0,
                                                                            ),
                                                                          );
                                                                        }
                                                                        logFirebaseEvent(
                                                                          'Image_bottom_sheet',
                                                                        );
                                                                        await showModalBottomSheet(
                                                                          isScrollControlled:
                                                                              true,
                                                                          backgroundColor:
                                                                              Colors.transparent,
                                                                          enableDrag:
                                                                              false,
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (
                                                                                context,
                                                                              ) {
                                                                                return GestureDetector(
                                                                                  onTap: () {
                                                                                    FocusScope.of(
                                                                                      context,
                                                                                    ).unfocus();
                                                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: MediaQuery.viewInsetsOf(
                                                                                      context,
                                                                                    ),
                                                                                    child: EmergencyWidget(
                                                                                      order: widget!.order!,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              },
                                                                        ).then(
                                                                          (
                                                                            value,
                                                                          ) => safeSetState(
                                                                            () {},
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              6,
                                                                            ),
                                                                        child: Image.asset(
                                                                          'assets/images/Red_Black_Minimalistic_Square_It_Software_Logo_(1).png',
                                                                          width:
                                                                              30,
                                                                          height:
                                                                              30,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ).animateOnActionTrigger(
                                                                      animationsMap['imageOnActionTriggerAnimation']!,
                                                                      hasBeenTriggered:
                                                                          hasImageTriggered,
                                                                    ),
                                                                    Container(
                                                                      width: 90,
                                                                      height:
                                                                          32.5,
                                                                      decoration: BoxDecoration(
                                                                        color: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).tertiary,
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            blurRadius:
                                                                                5,
                                                                            color: Color(
                                                                              0xC7414141,
                                                                            ),
                                                                            offset: Offset(
                                                                              0,
                                                                              -2,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: FlutterFlowTheme.of(
                                                                            context,
                                                                          ).tertiary,
                                                                        ),
                                                                      ),
                                                                      alignment:
                                                                          AlignmentDirectional(
                                                                            0,
                                                                            0,
                                                                          ),
                                                                      child: Text(
                                                                        FFLocalizations.of(
                                                                          context,
                                                                        ).getText(
                                                                          '8ln043c8' /* Add  Stop */,
                                                                        ),
                                                                        style:
                                                                            FlutterFlowTheme.of(
                                                                              context,
                                                                            ).bodyMedium.override(
                                                                              font: GoogleFonts.poppins(
                                                                                fontWeight: FlutterFlowTheme.of(
                                                                                  context,
                                                                                ).bodyMedium.fontWeight,
                                                                                fontStyle: FontStyle.italic,
                                                                              ),
                                                                              color: FlutterFlowTheme.of(
                                                                                context,
                                                                              ).alternate,
                                                                              letterSpacing: 0.0,
                                                                              fontWeight: FlutterFlowTheme.of(
                                                                                context,
                                                                              ).bodyMedium.fontWeight,
                                                                              fontStyle: FontStyle.italic,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ].divide(
                                                                    SizedBox(
                                                                      width: 6,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(height: 6)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (FFAppState().pickingPage ==
                                                'pickingyou')
                                              Padding(
                                                padding:
                                                    EdgeInsetsDirectional.fromSTEB(
                                                      12,
                                                      24,
                                                      12,
                                                      0,
                                                    ),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF1E1E20),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 4,
                                                        color: Color(
                                                          0x6C17181D,
                                                        ),
                                                        offset: Offset(2, -4),
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsetsDirectional.fromSTEB(
                                                          0,
                                                          10,
                                                          0,
                                                          0,
                                                        ),
                                                    child: StreamBuilder<UsersRecord>(
                                                      stream: UsersRecord.getDocument(
                                                        pickingYou9RideOrdersRecord
                                                            .driver!,
                                                      ),
                                                      builder: (context, snapshot) {
                                                        // Customize what your widget looks like when it's loading.
                                                        if (!snapshot.hasData) {
                                                          return Center(
                                                            child: SizedBox(
                                                              width: 50,
                                                              height: 50,
                                                              child: SpinKitDoubleBounce(
                                                                color:
                                                                    FlutterFlowTheme.of(
                                                                      context,
                                                                    ).accent1,
                                                                size: 50,
                                                              ),
                                                            ),
                                                          );
                                                        }

                                                        final rowUsersRecord =
                                                            snapshot.data!;

                                                        return Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        10,
                                                                      ),
                                                                  child: Container(
                                                                    width:
                                                                        118.3,
                                                                    height:
                                                                        141.5,
                                                                    decoration: BoxDecoration(
                                                                      color: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).tertiary,
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          blurRadius:
                                                                              10,
                                                                          color: FlutterFlowTheme.of(
                                                                            context,
                                                                          ).tertiary,
                                                                          offset: Offset(
                                                                            0,
                                                                            -2,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                    ),
                                                                    child: Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            8,
                                                                          ),
                                                                      child: Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        children:
                                                                            [
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                children: [
                                                                                  Text(
                                                                                    FFLocalizations.of(
                                                                                      context,
                                                                                    ).getText(
                                                                                      'oullosfc' /* Price: */,
                                                                                    ),
                                                                                    style:
                                                                                        FlutterFlowTheme.of(
                                                                                          context,
                                                                                        ).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FlutterFlowTheme.of(
                                                                                              context,
                                                                                            ).bodyMedium.fontWeight,
                                                                                            fontStyle: FlutterFlowTheme.of(
                                                                                              context,
                                                                                            ).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).secondaryText,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).bodyMedium.fontWeight,
                                                                                          fontStyle: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).bodyMedium.fontStyle,
                                                                                        ),
                                                                                  ),
                                                                                  GradientText(
                                                                                    '\$ ${formatNumber(pickingYou9RideOrdersRecord.rideValue, formatType: FormatType.decimal, decimalType: DecimalType.commaDecimal)}',
                                                                                    style:
                                                                                        FlutterFlowTheme.of(
                                                                                          context,
                                                                                        ).bodyMedium.override(
                                                                                          font: GoogleFonts.poppins(
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontStyle: FlutterFlowTheme.of(
                                                                                              context,
                                                                                            ).bodyMedium.fontStyle,
                                                                                          ),
                                                                                          color: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).primaryBackground,
                                                                                          fontSize: 14,
                                                                                          letterSpacing: 0.0,
                                                                                          fontWeight: FontWeight.w500,
                                                                                          fontStyle: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).bodyMedium.fontStyle,
                                                                                        ),
                                                                                    colors: [
                                                                                      FlutterFlowTheme.of(
                                                                                        context,
                                                                                      ).secondary,
                                                                                      FlutterFlowTheme.of(
                                                                                        context,
                                                                                      ).accent1,
                                                                                    ],
                                                                                    gradientDirection: GradientDirection.ltr,
                                                                                    gradientType: GradientType.linear,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Container(
                                                                                width: 40,
                                                                                height: 40,
                                                                                clipBehavior: Clip.antiAlias,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                                child: (rowUsersRecord.photoUrl != null && rowUsersRecord.photoUrl.isNotEmpty)
                                                                                    ? Image.network(
                                                                                        rowUsersRecord.photoUrl,
                                                                                        fit: BoxFit.cover,
                                                                                        errorBuilder: (context, error, stackTrace) => Center(
                                                                                          child: Text(
                                                                                            _initials(rowUsersRecord.displayName),
                                                                                            style: FlutterFlowTheme.of(context).titleSmall,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : Center(
                                                                                        child: Text(
                                                                                          _initials(rowUsersRecord.displayName),
                                                                                          style: FlutterFlowTheme.of(context).titleSmall,
                                                                                        ),
                                                                                      ),
                                                                              ),
                                                                              Row(
                                                                                mainAxisSize: MainAxisSize.max,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children:
                                                                                    [
                                                                                      Flexible(
                                                                                        child: Text(
                                                                                          FFLocalizations.of(
                                                                                            context,
                                                                                          ).getText(
                                                                                            'h082ajlx' /* Driver level: */,
                                                                                          ),
                                                                                          style:
                                                                                              FlutterFlowTheme.of(
                                                                                                context,
                                                                                              ).bodyMedium.override(
                                                                                                font: GoogleFonts.poppins(
                                                                                                  fontWeight: FontWeight.normal,
                                                                                                  fontStyle: FlutterFlowTheme.of(
                                                                                                    context,
                                                                                                  ).bodyMedium.fontStyle,
                                                                                                ),
                                                                                                color: FlutterFlowTheme.of(
                                                                                                  context,
                                                                                                ).alternate,
                                                                                                letterSpacing: 0.0,
                                                                                                fontWeight: FontWeight.normal,
                                                                                                fontStyle: FlutterFlowTheme.of(
                                                                                                  context,
                                                                                                ).bodyMedium.fontStyle,
                                                                                              ),
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                          maxLines: 1,
                                                                                        ),
                                                                                      ),
                                                                                    ].divide(
                                                                                      SizedBox(
                                                                                        width: 8,
                                                                                      ),
                                                                                    ),
                                                                              ),
                                                                              RatingBarIndicator(
                                                                                itemBuilder:
                                                                                    (
                                                                                      context,
                                                                                      index,
                                                                                    ) => Icon(
                                                                                      Icons.star_rounded,
                                                                                      color: FlutterFlowTheme.of(
                                                                                        context,
                                                                                      ).accent1,
                                                                                    ),
                                                                                direction: Axis.horizontal,
                                                                                rating: rowUsersRecord.ratings.toDouble(),
                                                                                unratedColor: FlutterFlowTheme.of(
                                                                                  context,
                                                                                ).primary,
                                                                                itemCount: 5,
                                                                                itemSize: 16,
                                                                              ),
                                                                            ].divide(
                                                                              SizedBox(
                                                                                height: 8,
                                                                              ),
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsetsDirectional.fromSTEB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0,
                                                                      ),
                                                                  child: Text(
                                                                    FFLocalizations.of(
                                                                      context,
                                                                    ).getText(
                                                                      'n7c9xyom' /* Approximate time
for pickup */,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                      font: GoogleFonts.poppins(
                                                                        fontWeight: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).secondaryText,
                                                                      fontSize:
                                                                          12,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontStyle,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsetsDirectional.fromSTEB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0,
                                                                      ),
                                                                  child: Text(
                                                                    functions
                                                                        .estimativeTime(
                                                                          rowUsersRecord
                                                                              .location!,
                                                                          currentUserLocationValue!,
                                                                        )
                                                                        .replaceAll('minutes', 'min')
                                                                        .replaceAll('minute', 'min')
                                                                        .maybeHandleOverflow(
                                                                          maxChars:
                                                                              8,
                                                                        ),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                      font: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontStyle: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).alternate,
                                                                      fontSize:
                                                                          26,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontStyle,
                                                                    ),
                                                                  ),
                                                                ),
                                                                if ((functions.tempoCancelamento(
                                                                          rowUsersRecord
                                                                              .location!,
                                                                          currentUserLocationValue!,
                                                                        ) !=
                                                                        '2 min') ||
                                                                    (functions.tempoCancelamento(
                                                                          rowUsersRecord
                                                                              .location!,
                                                                          currentUserLocationValue!,
                                                                        ) !=
                                                                        '1 min'))
                                                                  Stack(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                          0,
                                                                          -1,
                                                                        ),
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                              6,
                                                                            ),
                                                                        child:
                                                                            InkWell(
                                                                              splashColor: Colors.transparent,
                                                                              focusColor: Colors.transparent,
                                                                              hoverColor: Colors.transparent,
                                                                              highlightColor: Colors.transparent,
                                                                              onTap: () async {
                                                                                logFirebaseEvent(
                                                                                  'PICKING_YOU9_Container_24mturq8_ON_TAP',
                                                                                );
                                                                                logFirebaseEvent(
                                                                                  'Container_widget_animation',
                                                                                );
                                                                                if (animationsMap['containerOnActionTriggerAnimation1'] !=
                                                                                    null) {
                                                                                  safeSetState(
                                                                                    () => hasContainerTriggered1 = true,
                                                                                  );
                                                                                  SchedulerBinding.instance.addPostFrameCallback(
                                                                                    (
                                                                                      _,
                                                                                    ) async => await animationsMap['containerOnActionTriggerAnimation1']!.controller.forward(
                                                                                      from: 0.0,
                                                                                    ),
                                                                                  );
                                                                                }
                                                                                logFirebaseEvent(
                                                                                  'Container_bottom_sheet',
                                                                                );
                                                                                await showModalBottomSheet(
                                                                                  isScrollControlled: true,
                                                                                  backgroundColor: Colors.transparent,
                                                                                  enableDrag: false,
                                                                                  context: context,
                                                                                  builder:
                                                                                      (
                                                                                        context,
                                                                                      ) {
                                                                                        return GestureDetector(
                                                                                          onTap: () {
                                                                                            FocusScope.of(
                                                                                              context,
                                                                                            ).unfocus();
                                                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                                                          },
                                                                                          child: Padding(
                                                                                            padding: MediaQuery.viewInsetsOf(
                                                                                              context,
                                                                                            ),
                                                                                            child: WhyCancelThisRideWidget(
                                                                                              order: widget!.order!,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                ).then(
                                                                                  (
                                                                                    value,
                                                                                  ) => safeSetState(
                                                                                    () {},
                                                                                  ),
                                                                                );
                                                                              },
                                                                              child: Container(
                                                                                width:
                                                                                    MediaQuery.sizeOf(
                                                                                      context,
                                                                                    ).width *
                                                                                    0.369,
                                                                                height: 36,
                                                                                decoration: BoxDecoration(
                                                                                  color: FlutterFlowTheme.of(
                                                                                    context,
                                                                                  ).tertiary,
                                                                                  boxShadow: [
                                                                                    BoxShadow(
                                                                                      blurRadius: 5,
                                                                                      color: Color(
                                                                                        0xC7414141,
                                                                                      ),
                                                                                      offset: Offset(
                                                                                        0,
                                                                                        -2,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    8,
                                                                                  ),
                                                                                  border: Border.all(
                                                                                    color: FlutterFlowTheme.of(
                                                                                      context,
                                                                                    ).tertiary,
                                                                                  ),
                                                                                ),
                                                                                alignment: AlignmentDirectional(
                                                                                  0,
                                                                                  0,
                                                                                ),
                                                                                child: Text(
                                                                                  FFLocalizations.of(
                                                                                    context,
                                                                                  ).getText(
                                                                                    'j2gp4piq' /* Cancel Ride */,
                                                                                  ),
                                                                                  style:
                                                                                      FlutterFlowTheme.of(
                                                                                        context,
                                                                                      ).bodyMedium.override(
                                                                                        font: GoogleFonts.poppins(
                                                                                          fontWeight: FlutterFlowTheme.of(
                                                                                            context,
                                                                                          ).bodyMedium.fontWeight,
                                                                                          fontStyle: FontStyle.italic,
                                                                                        ),
                                                                                        color: FlutterFlowTheme.of(
                                                                                          context,
                                                                                        ).alternate,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FlutterFlowTheme.of(
                                                                                          context,
                                                                                        ).bodyMedium.fontWeight,
                                                                                        fontStyle: FontStyle.italic,
                                                                                      ),
                                                                                ),
                                                                              ),
                                                                            ).animateOnActionTrigger(
                                                                              animationsMap['containerOnActionTriggerAnimation1']!,
                                                                              hasBeenTriggered: hasContainerTriggered1,
                                                                            ),
                                                                      ),
                                                                      Align(
                                                                        alignment:
                                                                            AlignmentDirectional(
                                                                              1,
                                                                              -1,
                                                                            ),
                                                                        child: Padding(
                                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                                            100,
                                                                            0,
                                                                            0,
                                                                            0,
                                                                          ),
                                                                          child: Container(
                                                                            width:
                                                                                48,
                                                                            height:
                                                                                18,
                                                                            decoration: BoxDecoration(
                                                                              color: FlutterFlowTheme.of(
                                                                                context,
                                                                              ).alternate,
                                                                              borderRadius: BorderRadius.circular(
                                                                                10,
                                                                              ),
                                                                            ),
                                                                            alignment: AlignmentDirectional(
                                                                              0,
                                                                              0,
                                                                            ),
                                                                            child: Text(
                                                                              functions.tempoCancelamento(
                                                                                rowUsersRecord.location!,
                                                                                currentUserLocationValue!,
                                                                              ),
                                                                              style:
                                                                                  FlutterFlowTheme.of(
                                                                                    context,
                                                                                  ).bodyMedium.override(
                                                                                    font: GoogleFonts.poppins(
                                                                                      fontWeight: FontWeight.w500,
                                                                                      fontStyle: FlutterFlowTheme.of(
                                                                                        context,
                                                                                      ).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    color: FlutterFlowTheme.of(
                                                                                      context,
                                                                                    ).tertiary,
                                                                                    fontSize: 10,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    fontStyle: FlutterFlowTheme.of(
                                                                                      context,
                                                                                    ).bodyMedium.fontStyle,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (FFAppState().pickingPage == 'finish')
                                FutureBuilder<UsersRecord>(
                                  future: UsersRecord.getDocumentOnce(
                                    pickingYou9RideOrdersRecord.driver!,
                                  ),
                                  builder: (context, snapshot) {
                                    // Customize what your widget looks like when it's loading.
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: SpinKitDoubleBounce(
                                            color: FlutterFlowTheme.of(
                                              context,
                                            ).accent1,
                                            size: 50,
                                          ),
                                        ),
                                      );
                                    }

                                    final stackFinishUsersRecord =
                                        snapshot.data!;

                                    return Container(
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                          0.38,
                                      child: Stack(
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional(
                                              0,
                                              1,
                                            ),
                                            child: Padding(
                                              padding:
                                                  EdgeInsetsDirectional.fromSTEB(
                                                    0,
                                                    48,
                                                    0,
                                                    0,
                                                  ),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF1B1B1C),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      EdgeInsetsDirectional.fromSTEB(
                                                        0,
                                                        14,
                                                        0,
                                                        0,
                                                      ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Container(
                                                            width: 100,
                                                            height: 30,
                                                            decoration:
                                                                BoxDecoration(),
                                                          ),
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                  0,
                                                                  -1,
                                                                ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional.fromSTEB(
                                                                    16,
                                                                    0,
                                                                    0,
                                                                    0,
                                                                  ),
                                                              child: Text(
                                                                stackFinishUsersRecord
                                                                    .displayName,
                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                  font: GoogleFonts.poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle:
                                                                        FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontStyle,
                                                                  ),
                                                                  color:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).alternate,
                                                                  fontSize: 28,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontStyle,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Stack(
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                  -1,
                                                                  -1,
                                                                ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsetsDirectional.fromSTEB(
                                                                        44,
                                                                        8,
                                                                        2,
                                                                        0,
                                                                      ),
                                                                  child: Text(
                                                                    FFLocalizations.of(
                                                                      context,
                                                                    ).getText(
                                                                      'eyuyzrjp' /* (car 12) */,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                      font: GoogleFonts.poppins(
                                                                        fontWeight: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontWeight,
                                                                        fontStyle: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).secondaryText,
                                                                      fontSize:
                                                                          10,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontStyle,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsetsDirectional.fromSTEB(
                                                                  0,
                                                                  0,
                                                                  16,
                                                                  0,
                                                                ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                        0,
                                                                        1,
                                                                      ),
                                                                  child: Text(
                                                                    valueOrDefault<
                                                                      String
                                                                    >(
                                                                      functions
                                                                          .ratingMedia(
                                                                            stackFinishUsersRecord.rating.toList(),
                                                                          )
                                                                          .toString(),
                                                                      '5',
                                                                    ),
                                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                      font: GoogleFonts.poppins(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontStyle: FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontStyle,
                                                                      ),
                                                                      color: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).secondaryBackground,
                                                                      fontSize:
                                                                          32,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontStyle,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Align(
                                                                  alignment:
                                                                      AlignmentDirectional(
                                                                        0,
                                                                        1,
                                                                      ),
                                                                  child: Padding(
                                                                    padding:
                                                                        EdgeInsetsDirectional.fromSTEB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          11,
                                                                        ),
                                                                    child: RatingBarIndicator(
                                                                      itemBuilder:
                                                                          (
                                                                            context,
                                                                            index,
                                                                          ) => Icon(
                                                                            Icons.star_rounded,
                                                                            color: FlutterFlowTheme.of(
                                                                              context,
                                                                            ).secondaryBackground,
                                                                          ),
                                                                      direction:
                                                                          Axis.horizontal,
                                                                      rating: valueOrDefault<double>(
                                                                        functions.ratingMedia(
                                                                          stackFinishUsersRecord
                                                                              .rating
                                                                              .toList(),
                                                                        ),
                                                                        3.0,
                                                                      ),
                                                                      unratedColor:
                                                                          Color(
                                                                            0x90F4B000,
                                                                          ),
                                                                      itemCount:
                                                                          5,
                                                                      itemPadding:
                                                                          EdgeInsets.fromLTRB(
                                                                            6,
                                                                            0,
                                                                            0,
                                                                            0,
                                                                          ),
                                                                      itemSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Text(
                                                            FFLocalizations.of(
                                                              context,
                                                            ).getText(
                                                              'o72gwvza' /* Premium car */,
                                                            ),
                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                              font: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                fontStyle:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                              ),
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).alternate,
                                                              fontSize: 14,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                          ),
                                                          Text(
                                                            '( ${pickingYou9RideOrdersRecord.passangers} )',
                                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                              font: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                fontStyle:
                                                                    FlutterFlowTheme.of(
                                                                          context,
                                                                        )
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                              ),
                                                              color:
                                                                  FlutterFlowTheme.of(
                                                                    context,
                                                                  ).alternate,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(
                                                                        context,
                                                                      )
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(width: 6)),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional.fromSTEB(
                                                              36,
                                                              4,
                                                              36,
                                                              0,
                                                            ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional.fromSTEB(
                                                                    14,
                                                                    0,
                                                                    0,
                                                                    0,
                                                                  ),
                                                              child: Text(
                                                                '${valueOrDefault<String>(stackFinishUsersRecord.rating.length.toString(), '0')} reviews',
                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                  font: GoogleFonts.poppins(
                                                                    fontWeight:
                                                                        FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontWeight,
                                                                    fontStyle:
                                                                        FlutterFlowTheme.of(
                                                                          context,
                                                                        ).bodyMedium.fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                    context,
                                                                  ).secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontWeight,
                                                                  fontStyle:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).bodyMedium.fontStyle,
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional.fromSTEB(
                                                                    0,
                                                                    0,
                                                                    22,
                                                                    0,
                                                                  ),
                                                              child: FFButtonWidget(
                                                                onPressed: () async {
                                                                  logFirebaseEvent(
                                                                    'PICKING_YOU9_PAGE_VIEW_ALL_BTN_ON_TAP',
                                                                  );
                                                                  logFirebaseEvent(
                                                                    'Button_navigate_to',
                                                                  );

                                                                  context.pushNamed(
                                                                    DriverReviews32Widget
                                                                        .routeName,
                                                                    queryParameters: {
                                                                      'user': serializeParam(
                                                                        stackFinishUsersRecord
                                                                            .reference,
                                                                        ParamType
                                                                            .DocumentReference,
                                                                      ),
                                                                    }.withoutNulls,
                                                                    extra:
                                                                        <
                                                                          String,
                                                                          dynamic
                                                                        >{
                                                                          kTransitionInfoKey: TransitionInfo(
                                                                            hasTransition:
                                                                                true,
                                                                            transitionType:
                                                                                PageTransitionType.bottomToTop,
                                                                          ),
                                                                        },
                                                                  );
                                                                },
                                                                text:
                                                                    FFLocalizations.of(
                                                                      context,
                                                                    ).getText(
                                                                      'e5er2tlj' /* VIEW ALL */,
                                                                    ),
                                                                options: FFButtonOptions(
                                                                  height: 20,
                                                                  padding:
                                                                      EdgeInsetsDirectional.fromSTEB(
                                                                        16,
                                                                        0,
                                                                        16,
                                                                        0,
                                                                      ),
                                                                  iconPadding:
                                                                      EdgeInsetsDirectional.fromSTEB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        0,
                                                                      ),
                                                                  color:
                                                                      FlutterFlowTheme.of(
                                                                        context,
                                                                      ).tertiary,
                                                                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                                    font: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                        context,
                                                                      ).titleSmall.fontStyle,
                                                                    ),
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: 8,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontStyle:
                                                                        FlutterFlowTheme.of(
                                                                          context,
                                                                        ).titleSmall.fontStyle,
                                                                  ),
                                                                  elevation: 0,
                                                                  borderSide: BorderSide(
                                                                    color: FlutterFlowTheme.of(
                                                                      context,
                                                                    ).alternate,
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional.fromSTEB(
                                                              16,
                                                              4,
                                                              16,
                                                              0,
                                                            ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Stack(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                    0,
                                                                    -1,
                                                                  ),
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        6,
                                                                      ),
                                                                  child:
                                                                      Container(
                                                                        width:
                                                                            MediaQuery.sizeOf(
                                                                              context,
                                                                            ).width *
                                                                            0.4,
                                                                        height:
                                                                            36,
                                                                        decoration: BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              blurRadius: 5,
                                                                              color: Colors.black,
                                                                              offset: Offset(
                                                                                0,
                                                                                2,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                8,
                                                                              ),
                                                                        ),
                                                                        alignment:
                                                                            AlignmentDirectional(
                                                                              0,
                                                                              0,
                                                                            ),
                                                                      ).animateOnActionTrigger(
                                                                        animationsMap['containerOnActionTriggerAnimation2']!,
                                                                        hasBeenTriggered:
                                                                            hasContainerTriggered2,
                                                                      ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        6,
                                                                      ),
                                                                  child:
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap: () async {
                                                                          logFirebaseEvent(
                                                                            'PICKING_YOU9_ContainerShedulePickup_ON_T',
                                                                          );
                                                                          logFirebaseEvent(
                                                                            'ContainerShedulePickup_widget_animation',
                                                                          );
                                                                          if (animationsMap['containerOnActionTriggerAnimation3'] !=
                                                                              null) {
                                                                            safeSetState(
                                                                              () => hasContainerTriggered3 = true,
                                                                            );
                                                                            SchedulerBinding.instance.addPostFrameCallback(
                                                                              (
                                                                                _,
                                                                              ) async => await animationsMap['containerOnActionTriggerAnimation3']!.controller.forward(
                                                                                from: 0.0,
                                                                              ),
                                                                            );
                                                                          }
                                                                          logFirebaseEvent(
                                                                            'ContainerShedulePickup_bottom_sheet',
                                                                          );
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            enableDrag:
                                                                                false,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (
                                                                                  context,
                                                                                ) {
                                                                                  return GestureDetector(
                                                                                    onTap: () {
                                                                                      FocusScope.of(
                                                                                        context,
                                                                                      ).unfocus();
                                                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: MediaQuery.viewInsetsOf(
                                                                                        context,
                                                                                      ),
                                                                                      child: SchedulePickuUpWidget(
                                                                                        order: widget!.order!,
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                          ).then(
                                                                            (
                                                                              value,
                                                                            ) => safeSetState(
                                                                              () {},
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Container(
                                                                          width:
                                                                              MediaQuery.sizeOf(
                                                                                context,
                                                                              ).width *
                                                                              0.4,
                                                                          height:
                                                                              36,
                                                                          decoration: BoxDecoration(
                                                                            color: FlutterFlowTheme.of(
                                                                              context,
                                                                            ).tertiary,
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                blurRadius: 5,
                                                                                color: Color(
                                                                                  0xC7414141,
                                                                                ),
                                                                                offset: Offset(
                                                                                  0,
                                                                                  -2,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                            borderRadius: BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                            border: Border.all(
                                                                              color: FlutterFlowTheme.of(
                                                                                context,
                                                                              ).tertiary,
                                                                            ),
                                                                          ),
                                                                          alignment: AlignmentDirectional(
                                                                            0,
                                                                            0,
                                                                          ),
                                                                          child: Text(
                                                                            FFLocalizations.of(
                                                                              context,
                                                                            ).getText(
                                                                              'iwl7rz1y' /* Schedule Pickup */,
                                                                            ),
                                                                            style:
                                                                                FlutterFlowTheme.of(
                                                                                  context,
                                                                                ).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w500,
                                                                                    fontStyle: FontStyle.italic,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(
                                                                                    context,
                                                                                  ).alternate,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FontStyle.italic,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ).animateOnActionTrigger(
                                                                        animationsMap['containerOnActionTriggerAnimation3']!,
                                                                        hasBeenTriggered:
                                                                            hasContainerTriggered3,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            Stack(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                    0,
                                                                    -1,
                                                                  ),
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        6,
                                                                      ),
                                                                  child:
                                                                      Container(
                                                                        width:
                                                                            MediaQuery.sizeOf(
                                                                              context,
                                                                            ).width *
                                                                            0.3,
                                                                        height:
                                                                            36,
                                                                        decoration: BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              blurRadius: 5,
                                                                              color: Colors.black,
                                                                              offset: Offset(
                                                                                0,
                                                                                2,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                8,
                                                                              ),
                                                                        ),
                                                                        alignment:
                                                                            AlignmentDirectional(
                                                                              0,
                                                                              0,
                                                                            ),
                                                                      ).animateOnActionTrigger(
                                                                        animationsMap['containerOnActionTriggerAnimation4']!,
                                                                        hasBeenTriggered:
                                                                            hasContainerTriggered4,
                                                                      ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        6,
                                                                      ),
                                                                  child:
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap: () async {
                                                                          logFirebaseEvent(
                                                                            'PICKING_YOU9_PAGE_ContainerTip_ON_TAP',
                                                                          );
                                                                          logFirebaseEvent(
                                                                            'ContainerTip_widget_animation',
                                                                          );
                                                                          if (animationsMap['containerOnActionTriggerAnimation5'] !=
                                                                              null) {
                                                                            safeSetState(
                                                                              () => hasContainerTriggered5 = true,
                                                                            );
                                                                            SchedulerBinding.instance.addPostFrameCallback(
                                                                              (
                                                                                _,
                                                                              ) async => await animationsMap['containerOnActionTriggerAnimation5']!.controller.forward(
                                                                                from: 0.0,
                                                                              ),
                                                                            );
                                                                          }
                                                                          logFirebaseEvent(
                                                                            'ContainerTip_bottom_sheet',
                                                                          );
                                                                          await showModalBottomSheet(
                                                                            isScrollControlled:
                                                                                true,
                                                                            backgroundColor:
                                                                                Colors.transparent,
                                                                            enableDrag:
                                                                                false,
                                                                            context:
                                                                                context,
                                                                            builder:
                                                                                (
                                                                                  context,
                                                                                ) {
                                                                                  return GestureDetector(
                                                                                    onTap: () {
                                                                                      FocusScope.of(
                                                                                        context,
                                                                                      ).unfocus();
                                                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: MediaQuery.viewInsetsOf(
                                                                                        context,
                                                                                      ),
                                                                                      child: TipDriverWidget(),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                          ).then(
                                                                            (
                                                                              value,
                                                                            ) => safeSetState(
                                                                              () {},
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Container(
                                                                          width:
                                                                              MediaQuery.sizeOf(
                                                                                context,
                                                                              ).width *
                                                                              0.3,
                                                                          height:
                                                                              36,
                                                                          decoration: BoxDecoration(
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                blurRadius: 5,
                                                                                color: Color(
                                                                                  0xC7414141,
                                                                                ),
                                                                                offset: Offset(
                                                                                  0,
                                                                                  -2,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                            gradient: LinearGradient(
                                                                              colors: [
                                                                                FlutterFlowTheme.of(
                                                                                  context,
                                                                                ).secondary,
                                                                                FlutterFlowTheme.of(
                                                                                  context,
                                                                                ).accent1,
                                                                              ],
                                                                              stops: [
                                                                                0,
                                                                                1,
                                                                              ],
                                                                              begin: AlignmentDirectional(
                                                                                -0.34,
                                                                                1,
                                                                              ),
                                                                              end: AlignmentDirectional(
                                                                                0.34,
                                                                                -1,
                                                                              ),
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                            border: Border.all(
                                                                              color: FlutterFlowTheme.of(
                                                                                context,
                                                                              ).tertiary,
                                                                            ),
                                                                          ),
                                                                          alignment: AlignmentDirectional(
                                                                            0,
                                                                            0,
                                                                          ),
                                                                          child: Text(
                                                                            FFLocalizations.of(
                                                                              context,
                                                                            ).getText(
                                                                              'zb68ezes' /* Tip Driver */,
                                                                            ),
                                                                            style:
                                                                                FlutterFlowTheme.of(
                                                                                  context,
                                                                                ).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontStyle: FontStyle.italic,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(
                                                                                    context,
                                                                                  ).primary,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontStyle: FontStyle.italic,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ).animateOnActionTrigger(
                                                                        animationsMap['containerOnActionTriggerAnimation5']!,
                                                                        hasBeenTriggered:
                                                                            hasContainerTriggered5,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsetsDirectional.fromSTEB(
                                                              16,
                                                              0,
                                                              16,
                                                              10,
                                                            ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Stack(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                    0,
                                                                    -1,
                                                                  ),
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        6,
                                                                      ),
                                                                  child:
                                                                      Container(
                                                                        width:
                                                                            MediaQuery.sizeOf(
                                                                              context,
                                                                            ).width *
                                                                            0.8,
                                                                        height:
                                                                            40,
                                                                        decoration: BoxDecoration(
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              blurRadius: 5,
                                                                              color: Colors.black,
                                                                              offset: Offset(
                                                                                0,
                                                                                2,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                          borderRadius: BorderRadius.circular(
                                                                            16,
                                                                          ),
                                                                        ),
                                                                        alignment:
                                                                            AlignmentDirectional(
                                                                              0,
                                                                              0,
                                                                            ),
                                                                      ).animateOnActionTrigger(
                                                                        animationsMap['containerOnActionTriggerAnimation6']!,
                                                                        hasBeenTriggered:
                                                                            hasContainerTriggered6,
                                                                      ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        6,
                                                                      ),
                                                                  child:
                                                                      InkWell(
                                                                        splashColor:
                                                                            Colors.transparent,
                                                                        focusColor:
                                                                            Colors.transparent,
                                                                        hoverColor:
                                                                            Colors.transparent,
                                                                        highlightColor:
                                                                            Colors.transparent,
                                                                        onTap: () async {
                                                                          logFirebaseEvent(
                                                                            'PICKING_YOU9_PAGE_ContainerFinish_ON_TAP',
                                                                          );
                                                                          logFirebaseEvent(
                                                                            'ContainerFinish_widget_animation',
                                                                          );
                                                                          if (animationsMap['containerOnActionTriggerAnimation7'] !=
                                                                              null) {
                                                                            safeSetState(
                                                                              () => hasContainerTriggered7 = true,
                                                                            );
                                                                            SchedulerBinding.instance.addPostFrameCallback(
                                                                              (
                                                                                _,
                                                                              ) async => await animationsMap['containerOnActionTriggerAnimation7']!.controller.forward(
                                                                                from: 0.0,
                                                                              ),
                                                                            );
                                                                          }
                                                                          logFirebaseEvent(
                                                                            'ContainerFinish_action_block',
                                                                          );
                                                                          await action_blocks.avaliateDriver(
                                                                            context,
                                                                            order:
                                                                                widget!.order,
                                                                          );
                                                                        },
                                                                        child: Container(
                                                                          width:
                                                                              MediaQuery.sizeOf(
                                                                                context,
                                                                              ).width *
                                                                              0.8,
                                                                          height:
                                                                              40,
                                                                          decoration: BoxDecoration(
                                                                            color: FlutterFlowTheme.of(
                                                                              context,
                                                                            ).tertiary,
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                blurRadius: 5,
                                                                                color: Color(
                                                                                  0xC7414141,
                                                                                ),
                                                                                offset: Offset(
                                                                                  0,
                                                                                  -2,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                            borderRadius: BorderRadius.circular(
                                                                              16,
                                                                            ),
                                                                            border: Border.all(
                                                                              color: FlutterFlowTheme.of(
                                                                                context,
                                                                              ).tertiary,
                                                                            ),
                                                                          ),
                                                                          alignment: AlignmentDirectional(
                                                                            0,
                                                                            0,
                                                                          ),
                                                                          child: Text(
                                                                            FFLocalizations.of(
                                                                              context,
                                                                            ).getText(
                                                                              'nomzd5aj' /* Finish Ride */,
                                                                            ),
                                                                            style:
                                                                                FlutterFlowTheme.of(
                                                                                  context,
                                                                                ).bodyMedium.override(
                                                                                  font: GoogleFonts.poppins(
                                                                                    fontWeight: FontWeight.w500,
                                                                                    fontStyle: FontStyle.italic,
                                                                                  ),
                                                                                  color: FlutterFlowTheme.of(
                                                                                    context,
                                                                                  ).alternate,
                                                                                  fontSize: 16,
                                                                                  letterSpacing: 0.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontStyle: FontStyle.italic,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ).animateOnActionTrigger(
                                                                        animationsMap['containerOnActionTriggerAnimation7']!,
                                                                        hasBeenTriggered:
                                                                            hasContainerTriggered7,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                  12,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(
                                                  context,
                                                ).primaryBackground,
                                                boxShadow: [
                                                  BoxShadow(
                                                    blurRadius: 15,
                                                    color: Color(0x53000000),
                                                    offset: Offset(4, 4),
                                                  ),
                                                ],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Container(
                                                  width: 200,
                                                  height: 200,
                                                  clipBehavior: Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Image.network(
                                                    stackFinishUsersRecord
                                                        .photoUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
