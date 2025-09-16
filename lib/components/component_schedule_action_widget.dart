import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/ride_schedule_sucess_widget.dart';
import '/components/select_location_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'component_schedule_action_model.dart';
export 'component_schedule_action_model.dart';

class ComponentScheduleActionWidget extends StatefulWidget {
  const ComponentScheduleActionWidget({
    super.key,
    required this.parameter3,
  });

  final DateTime? parameter3;

  @override
  State<ComponentScheduleActionWidget> createState() =>
      _ComponentScheduleActionWidgetState();
}

class _ComponentScheduleActionWidgetState
    extends State<ComponentScheduleActionWidget> {
  late ComponentScheduleActionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ComponentScheduleActionModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: Container(
              width: double.infinity,
              height: 139.4,
              decoration: BoxDecoration(
                color: Color(0xFF1B1B1C),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              '856t18lj' /* Pickup */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          enableDrag: false,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: SelectLocationWidget(
                                escolha: '',
                              ),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryText,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 0.0, 0.0),
                            child: Text(
                              FFAppState().locationAondeEleEsta != ''
                                  ? FFAppState().locationAondeEleEsta
                                  : 'Bay Street 14',
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
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 12.0,
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
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'no2shcld' /* Dropoff */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await showModalBottomSheet(
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          enableDrag: false,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              child: SelectLocationWidget(
                                escolha: '',
                              ),
                            );
                          },
                        ).then((value) => safeSetState(() {}));
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: 35.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryText,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(-1.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 0.0, 0.0),
                            child: Text(
                              FFAppState().locationWhereTo != ''
                                  ? FFAppState().locationWhereTo
                                  : 'Lynden Pindling Airport',
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
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 12.0,
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
                        ),
                      ),
                    ),
                  ),
                ].divide(SizedBox(height: 6.0)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: Container(
              width: double.infinity,
              height: 78.0,
              decoration: BoxDecoration(
                color: Color(0xFF1B1B1C),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'jamhybvq' /* Vehicle */,
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
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 10.0,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (_model.action == 'Ride') {
                            _model.action = 'Ride';
                            safeSetState(() {});
                          } else {
                            _model.action = 'Ride';
                            safeSetState(() {});
                          }
                        },
                        child: Container(
                          width: 60.0,
                          height: 25.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                valueOrDefault<Color>(
                                  _model.action == 'Ride'
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                valueOrDefault<Color>(
                                  _model.action == 'Ride'
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context).accent1,
                                )
                              ],
                              stops: [0.0, 1.0],
                              begin: AlignmentDirectional(1.0, 0.87),
                              end: AlignmentDirectional(-1.0, -0.87),
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              '43r7ws5u' /* Ride */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: valueOrDefault<Color>(
                                    _model.action == 'Ride'
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context)
                                            .alternate,
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (_model.action == 'XL') {
                            _model.action = 'Ride';
                            safeSetState(() {});
                          } else {
                            _model.action = 'XL';
                            safeSetState(() {});
                          }
                        },
                        child: Container(
                          width: 60.0,
                          height: 25.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                valueOrDefault<Color>(
                                  _model.action == 'XL'
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                      : FlutterFlowTheme.of(context).tertiary,
                                  FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                valueOrDefault<Color>(
                                  _model.action == 'XL'
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context).tertiary,
                                  FlutterFlowTheme.of(context).accent1,
                                )
                              ],
                              stops: [0.0, 1.0],
                              begin: AlignmentDirectional(1.0, 0.87),
                              end: AlignmentDirectional(-1.0, -0.87),
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              '35k8wmyh' /* XL */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: valueOrDefault<Color>(
                                    _model.action == 'XL'
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context)
                                            .alternate,
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (_model.action == 'Luxury') {
                            _model.action = 'Ride';
                            safeSetState(() {});
                          } else {
                            _model.action = 'Luxury';
                            safeSetState(() {});
                          }
                        },
                        child: Container(
                          width: 68.0,
                          height: 25.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                valueOrDefault<Color>(
                                  _model.action == 'Luxury'
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                valueOrDefault<Color>(
                                  _model.action == 'Luxury'
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context).accent1,
                                )
                              ],
                              stops: [0.0, 1.0],
                              begin: AlignmentDirectional(1.0, 0.87),
                              end: AlignmentDirectional(-1.0, -0.87),
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'pxgch01i' /* Luxury */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: valueOrDefault<Color>(
                                    _model.action == 'Luxury'
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context)
                                            .alternate,
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText(
                          'iqml58mw' /* Repeat */,
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
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 10.0,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (_model.repeat == 'One-time') {
                            _model.repeat = 'One-time';
                            safeSetState(() {});
                          } else {
                            _model.repeat = 'One-time';
                            safeSetState(() {});
                          }
                        },
                        child: Container(
                          width: 78.0,
                          height: 25.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                valueOrDefault<Color>(
                                  _model.repeat == 'One-time'
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                valueOrDefault<Color>(
                                  _model.repeat == 'One-time'
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context).accent1,
                                )
                              ],
                              stops: [0.0, 1.0],
                              begin: AlignmentDirectional(1.0, 0.87),
                              end: AlignmentDirectional(-1.0, -0.87),
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'wpj5tgnr' /* One-time */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: valueOrDefault<Color>(
                                    _model.repeat == 'One-time'
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context)
                                            .alternate,
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (_model.repeat == 'Weekdays') {
                            _model.repeat = 'One-time';
                            safeSetState(() {});
                          } else {
                            _model.repeat = 'Weekdays';
                            safeSetState(() {});
                          }
                        },
                        child: Container(
                          width: 80.0,
                          height: 25.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                valueOrDefault<Color>(
                                  _model.repeat == 'Weekdays'
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                valueOrDefault<Color>(
                                  _model.repeat == 'Weekdays'
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context).accent1,
                                )
                              ],
                              stops: [0.0, 1.0],
                              begin: AlignmentDirectional(1.0, 0.87),
                              end: AlignmentDirectional(-1.0, -0.87),
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'quw1f8h7' /* Weekdays */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: valueOrDefault<Color>(
                                    _model.repeat == 'Weekdays'
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context)
                                            .alternate,
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          if (_model.repeat == 'Custom') {
                            _model.repeat = 'One-time';
                            safeSetState(() {});
                          } else {
                            _model.repeat = 'Custom';
                            safeSetState(() {});
                          }
                        },
                        child: Container(
                          width: 78.0,
                          height: 25.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                valueOrDefault<Color>(
                                  _model.repeat == 'Custom'
                                      ? FlutterFlowTheme.of(context)
                                          .secondaryBackground
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                valueOrDefault<Color>(
                                  _model.repeat == 'Custom'
                                      ? FlutterFlowTheme.of(context).accent1
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context).accent1,
                                )
                              ],
                              stops: [0.0, 1.0],
                              begin: AlignmentDirectional(1.0, 0.87),
                              end: AlignmentDirectional(-1.0, -0.87),
                            ),
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              '7cei3svq' /* Custom */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: valueOrDefault<Color>(
                                    _model.repeat == 'Custom'
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context)
                                            .alternate,
                                    FlutterFlowTheme.of(context).primary,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ].divide(SizedBox(height: 6.0)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: Container(
              width: double.infinity,
              height: 90.0,
              decoration: BoxDecoration(
                color: Color(0xFF1B1B1C),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              '0mtvp1iq' /* Estimate */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(-1.0, -1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 0.0, 0.0),
                          child: Text(
                            FFLocalizations.of(context).getText(
                              'atbe9izh' /* $18 • pickup recalculated at t... */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  fontSize: 10.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primaryText,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                      ),
                      child: Container(
                        width: 200.0,
                        child: TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            hintText: FFLocalizations.of(context).getText(
                              'v3644x1m' /* Notes (optional) */,
                            ),
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0x00000000),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                          cursorColor: FlutterFlowTheme.of(context).primaryText,
                          enableInteractiveSelection: true,
                          validator: _model.textControllerValidator
                              .asValidator(context),
                        ),
                      ),
                    ),
                  ),
                ].divide(SizedBox(height: 6.0)),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.0, 0.87),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    await RideOrdersRecord.collection
                        .doc()
                        .set(createRideOrdersRecordData(
                          user: currentUserReference,
                          latlng: FFAppState().latlangAondeVaiIr,
                          dia: widget.parameter3,
                          option: _model.action,
                          latlngAtual: FFAppState().latlngAtual,
                          notas: _model.textController.text,
                          repeat: _model.repeat,
                          salvarSomente: false,
                        ));
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: MediaQuery.viewInsetsOf(context),
                          child: RideScheduleSucessWidget(
                            orderRef: _model.orderRef!.reference,
                          ),
                        );
                      },
                    ).then((value) => safeSetState(() {}));
                  },
                  child: Container(
                    width: 148.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).accent1,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'irm5g15g' /* Shedule ride */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                ),
                Container(
                  width: 148.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).alternate,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Text(
                    FFLocalizations.of(context).getText(
                      '49itxhbn' /* Schedule Ride Share */,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              var rideOrdersRecordReference = RideOrdersRecord.collection.doc();
              await rideOrdersRecordReference.set(createRideOrdersRecordData(
                user: currentUserReference,
                latlng: FFAppState().latlangAondeVaiIr,
                dia: widget.parameter3,
                option: _model.action,
                latlngAtual: FFAppState().latlngAtual,
                notas: _model.textController.text,
                repeat: _model.repeat,
                salvarSomente: true,
              ));
              _model.orderRef = RideOrdersRecord.getDocumentFromData(
                  createRideOrdersRecordData(
                    user: currentUserReference,
                    latlng: FFAppState().latlangAondeVaiIr,
                    dia: widget.parameter3,
                    option: _model.action,
                    latlngAtual: FFAppState().latlngAtual,
                    notas: _model.textController.text,
                    repeat: _model.repeat,
                    salvarSomente: true,
                  ),
                  rideOrdersRecordReference);
              await showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                enableDrag: false,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: MediaQuery.viewInsetsOf(context),
                    child: RideScheduleSucessWidget(
                      orderRef: _model.orderRef!.reference,
                    ),
                  );
                },
              ).then((value) => safeSetState(() {}));

              safeSetState(() {});
            },
            child: Container(
              width: 320.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: Color(0xFF242424),
                borderRadius: BorderRadius.circular(10.0),
              ),
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Text(
                FFLocalizations.of(context).getText(
                  'jqfg3zeg' /* Save to canlendar */,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.poppins(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).alternate,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            ),
          ),
        ].divide(SizedBox(height: 8.0)),
      ),
    );
  }
}
