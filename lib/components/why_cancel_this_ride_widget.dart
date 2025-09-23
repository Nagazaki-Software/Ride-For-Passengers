import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'why_cancel_this_ride_model.dart';
export 'why_cancel_this_ride_model.dart';

/// Create a component Why do you want to cancel this ride?
class WhyCancelThisRideWidget extends StatefulWidget {
  const WhyCancelThisRideWidget({
    super.key,
    required this.order,
  });

  final DocumentReference? order;

  @override
  State<WhyCancelThisRideWidget> createState() =>
      _WhyCancelThisRideWidgetState();
}

class _WhyCancelThisRideWidgetState extends State<WhyCancelThisRideWidget>
    with TickerProviderStateMixin {
  late WhyCancelThisRideModel _model;

  var hasContainerTriggered1 = false;
  var hasContainerTriggered2 = false;
  var hasContainerTriggered3 = false;
  var hasContainerTriggered4 = false;
  var hasContainerTriggered5 = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WhyCancelThisRideModel());

    animationsMap.addAll({
      'containerOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          SaturateEffect(
            curve: Curves.linear,
            delay: 0.0.ms,
            duration: 280.0.ms,
            begin: 0.77,
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
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
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
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
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
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
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
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
            end: 2.0,
          ),
          TintEffect(
            curve: Curves.easeInOut,
            delay: 90.0.ms,
            duration: 360.0.ms,
            color: Color(0xC4BAB5B5),
            begin: 1.0,
            end: 0.0,
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 8.0,
            color: Color(0x33000000),
            offset: Offset(
              0.0,
              2.0,
            ),
            spreadRadius: 0.0,
          )
        ],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FFLocalizations.of(context).getText(
                'l88o43xh' /* Why do you want to cancel this... */,
              ),
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    logFirebaseEvent(
                        'WHY_CANCEL_THIS_RIDE_ContainerDriverLong');
                    if (_model.select == 1) {
                      logFirebaseEvent('ContainerDriverLong_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent(
                          'ContainerDriverLong_update_component_sta');
                      _model.select = null;
                      safeSetState(() {});
                    } else {
                      logFirebaseEvent('ContainerDriverLong_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent(
                          'ContainerDriverLong_update_component_sta');
                      _model.select = 1;
                      safeSetState(() {});
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: _model.select == 1
                          ? FlutterFlowTheme.of(context).tertiary
                          : Color(0xCD17181D),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 16.0, 16.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.edit_location,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'wewzqocc' /* I need to change destination */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).alternate,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 12.0)),
                      ),
                    ),
                  ),
                ).animateOnActionTrigger(
                    animationsMap['containerOnActionTriggerAnimation1']!,
                    hasBeenTriggered: hasContainerTriggered1),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    logFirebaseEvent(
                        'WHY_CANCEL_THIS_RIDE_Container_o1cm9f0t_');
                    if (_model.select == 2) {
                      logFirebaseEvent('Container_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent('Container_update_component_state');
                      _model.select = null;
                      safeSetState(() {});
                    } else {
                      logFirebaseEvent('Container_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent('Container_update_component_state');
                      _model.select = 2;
                      safeSetState(() {});
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: _model.select == 2
                          ? FlutterFlowTheme.of(context).tertiary
                          : Color(0xCD17181D),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 16.0, 16.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.car_crash,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'uss7y04c' /* The driver isn’t moving */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).alternate,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 12.0)),
                      ),
                    ),
                  ),
                ).animateOnActionTrigger(
                    animationsMap['containerOnActionTriggerAnimation2']!,
                    hasBeenTriggered: hasContainerTriggered2),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    logFirebaseEvent(
                        'WHY_CANCEL_THIS_RIDE_Container_vgq7mtvb_');
                    if (_model.select == 3) {
                      logFirebaseEvent('Container_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent('Container_update_component_state');
                      _model.select = null;
                      safeSetState(() {});
                    } else {
                      logFirebaseEvent('Container_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent('Container_update_component_state');
                      _model.select = 3;
                      safeSetState(() {});
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: _model.select == 3
                          ? FlutterFlowTheme.of(context).tertiary
                          : Color(0xCD17181D),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 16.0, 16.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person_off_sharp,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'kpemoo7o' /* The driver asked me to cancel */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).alternate,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 12.0)),
                      ),
                    ),
                  ),
                ).animateOnActionTrigger(
                    animationsMap['containerOnActionTriggerAnimation3']!,
                    hasBeenTriggered: hasContainerTriggered3),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    logFirebaseEvent(
                        'WHY_CANCEL_THIS_RIDE_Container_px3lr7re_');
                    if (_model.select == 4) {
                      logFirebaseEvent('Container_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent('Container_update_component_state');
                      _model.select = null;
                      safeSetState(() {});
                    } else {
                      logFirebaseEvent('Container_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent('Container_update_component_state');
                      _model.select = 4;
                      safeSetState(() {});
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: _model.select == 4
                          ? FlutterFlowTheme.of(context).tertiary
                          : Color(0xCD17181D),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 16.0, 16.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.directions_car_filled,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'q2ag5jvt' /* I can’t find the driver */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).alternate,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 12.0)),
                      ),
                    ),
                  ),
                ).animateOnActionTrigger(
                    animationsMap['containerOnActionTriggerAnimation4']!,
                    hasBeenTriggered: hasContainerTriggered4),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    logFirebaseEvent(
                        'WHY_CANCEL_THIS_RIDE_Container_vemu8qhd_');
                    if (_model.select == 5) {
                      logFirebaseEvent('Container_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent('Container_update_component_state');
                      _model.select = null;
                      safeSetState(() {});
                    } else {
                      logFirebaseEvent('Container_widget_animation');
                      if (animationsMap['containerOnActionTriggerAnimation1'] !=
                          null) {
                        safeSetState(() => hasContainerTriggered1 = true);
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) async => await animationsMap[
                                    'containerOnActionTriggerAnimation1']!
                                .controller
                                .forward(from: 0.0));
                      }
                      logFirebaseEvent('Container_update_component_state');
                      _model.select = 5;
                      safeSetState(() {});
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: _model.select == 1
                          ? FlutterFlowTheme.of(context).tertiary
                          : Color(0xCD17181D),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 16.0, 16.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.pin_drop,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          Text(
                            FFLocalizations.of(context).getText(
                              'qfd1pgf9' /* I no longer need this ride */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).alternate,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(SizedBox(width: 12.0)),
                      ),
                    ),
                  ),
                ).animateOnActionTrigger(
                    animationsMap['containerOnActionTriggerAnimation5']!,
                    hasBeenTriggered: hasContainerTriggered5),
              ].divide(SizedBox(height: 12.0)),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FFButtonWidget(
                  onPressed: () async {
                    logFirebaseEvent(
                        'WHY_CANCEL_THIS_RIDE_HELP_NOW_BTN_ON_TAP');
                    logFirebaseEvent('Button_backend_call');

                    var chatRecordReference = ChatRecord.collection.doc();
                    await chatRecordReference.set(createChatRecordData(
                      rideOrderReference: widget.order,
                      userDocument: currentUserReference,
                    ));
                    _model.chatReference = ChatRecord.getDocumentFromData(
                        createChatRecordData(
                          rideOrderReference: widget.order,
                          userDocument: currentUserReference,
                        ),
                        chatRecordReference);
                    logFirebaseEvent('Button_navigate_to');

                    context.pushNamed(
                      ChatSupportWidget.routeName,
                      queryParameters: {
                        'chat': serializeParam(
                          _model.chatReference?.reference,
                          ParamType.DocumentReference,
                        ),
                      }.withoutNulls,
                    );

                    safeSetState(() {});
                  },
                  text: FFLocalizations.of(context).getText(
                    'biymab2t' /* Help Now */,
                  ),
                  options: FFButtonOptions(
                    width: 140.0,
                    height: 48.0,
                    padding: EdgeInsets.all(8.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontWeight,
                            fontStyle: FontStyle.italic,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle: FontStyle.italic,
                        ),
                    elevation: 0.0,
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).accent1,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
                FFButtonWidget(
                  onPressed: () async {
                    logFirebaseEvent(
                        'WHY_CANCEL_THIS_RIDE_CANCEL_RIDE_BTN_ON_');
                    logFirebaseEvent('Button_backend_call');

                    await widget.order!.update(createRideOrdersRecordData(
                      status: 'Canceled',
                      whyCanceled: () {
                        if (_model.select == 1) {
                          return 'I need to change destination';
                        } else if (_model.select == 2) {
                          return 'The driver isn\'t moving';
                        } else if (_model.select == 3) {
                          return 'The driver asked me to cancel';
                        } else if (_model.select == 4) {
                          return 'I can´t find the driver';
                        } else if (_model.select == 5) {
                          return 'I no longer need this ride';
                        } else {
                          return 'No comments';
                        }
                      }(),
                    ));
                    logFirebaseEvent('Button_navigate_to');

                    context.goNamed(Home5Widget.routeName);
                  },
                  text: FFLocalizations.of(context).getText(
                    '58sxiip3' /* Cancel Ride */,
                  ),
                  options: FFButtonOptions(
                    width: 140.0,
                    height: 48.0,
                    padding: EdgeInsets.all(8.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: Color(0xFFFC0514),
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FlutterFlowTheme.of(context)
                                .titleSmall
                                .fontWeight,
                            fontStyle: FontStyle.italic,
                          ),
                          color: FlutterFlowTheme.of(context).alternate,
                          letterSpacing: 0.0,
                          fontWeight: FlutterFlowTheme.of(context)
                              .titleSmall
                              .fontWeight,
                          fontStyle: FontStyle.italic,
                        ),
                    elevation: 0.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ].divide(SizedBox(width: 12.0)),
            ),
          ].divide(SizedBox(height: 20.0)),
        ),
      ),
    );
  }
}
