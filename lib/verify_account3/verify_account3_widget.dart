import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'verify_account3_model.dart';
export 'verify_account3_model.dart';

class VerifyAccount3Widget extends StatefulWidget {
  const VerifyAccount3Widget({
    super.key,
    required this.plataform,
  });

  final String? plataform;

  static String routeName = 'VerifyAccount3';
  static String routePath = '/verifyAccount3';

  @override
  State<VerifyAccount3Widget> createState() => _VerifyAccount3WidgetState();
}

class _VerifyAccount3WidgetState extends State<VerifyAccount3Widget>
    with TickerProviderStateMixin {
  late VerifyAccount3Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasContainerTriggered = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VerifyAccount3Model());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'VerifyAccount3'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('VERIFY_ACCOUNT3_VerifyAccount3_ON_INIT_S');
      await authManager.refreshUser();
      logFirebaseEvent('VerifyAccount3_auth');
      await authManager.sendEmailVerification();
      logFirebaseEvent('VerifyAccount3_start_periodic_action');
      _model.instantTimer = InstantTimer.periodic(
        duration: Duration(milliseconds: 3600),
        callback: (timer) async {
          logFirebaseEvent('VerifyAccount3_rebuild_page');
          safeSetState(() {});
          if (currentUserEmailVerified) {
            logFirebaseEvent('VerifyAccount3_navigate_to');

            context.goNamed(Home5Widget.routeName);
          }
        },
        startImmediately: true,
      );
    });

    animationsMap.addAll({
      'containerOnActionTriggerAnimation': AnimationInfo(
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
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primary,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 80.0, 0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          FFLocalizations.of(context).getText(
                            'ghn677x0' /* Verify Your 
Account */
                            ,
                          ),
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                ),
                                color: FlutterFlowTheme.of(context).alternate,
                                fontSize: 32.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                lineHeight: 0.0,
                              ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Text(
                              FFLocalizations.of(context).getText(
                                '5g27hqw3' /* An email was sent to */,
                              ),
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Text(
                              currentUserEmail,
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ].divide(SizedBox(height: 20.0)),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 15.0, 0.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'u0ctzyu7' /* Please confirm by clicking on ... */,
                      ),
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                  ),
                  Text(
                    FFLocalizations.of(context).getText(
                      'd1wov68j' /* Hang thight we´re almost there... */,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
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
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                  Spacer(),
                  if (currentUserEmailVerified)
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 28.0),
                      child: AuthUserStreamWidget(
                        builder: (context) => Stack(
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 28.0, 0.0, 0.0),
                              child: Container(
                                width: 280.0,
                                height: 44.0,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                      offset: Offset(
                                        0.0,
                                        2.0,
                                      ),
                                    )
                                  ],
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 28.0, 0.0, 0.0),
                              child: InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent(
                                      'VERIFY_ACCOUNT3_Container_yb2y43hg_ON_TA');
                                  logFirebaseEvent(
                                      'Container_widget_animation');
                                  if (animationsMap[
                                          'containerOnActionTriggerAnimation'] !=
                                      null) {
                                    safeSetState(
                                        () => hasContainerTriggered = true);
                                    SchedulerBinding.instance.addPostFrameCallback(
                                        (_) async => await animationsMap[
                                                'containerOnActionTriggerAnimation']!
                                            .controller
                                            .forward(from: 0.0));
                                  }
                                  if (widget.plataform == 'Ride Visitor') {
                                    logFirebaseEvent('Container_navigate_to');

                                    context
                                        .goNamed(ChoosePass4Widget.routeName);
                                  } else {
                                    logFirebaseEvent('Container_navigate_to');

                                    context.goNamed(Home5Widget.routeName);
                                  }
                                },
                                child: Container(
                                  width: 280.0,
                                  height: 44.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF303033),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 2.0,
                                        color: Color(0x48FFFFFF),
                                        offset: Offset(
                                          0.0,
                                          -1.0,
                                        ),
                                      )
                                    ],
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20.0),
                                      bottomRight: Radius.circular(20.0),
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    FFLocalizations.of(context).getText(
                                      'ni71euqk' /* Next */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .alternate,
                                          fontSize: 22.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                              ).animateOnActionTrigger(
                                  animationsMap[
                                      'containerOnActionTriggerAnimation']!,
                                  hasBeenTriggered: hasContainerTriggered),
                            ),
                          ],
                        ),
                      ),
                    ),
                ].divide(SizedBox(height: 55.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
