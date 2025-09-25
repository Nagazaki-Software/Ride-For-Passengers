import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/ride_schedule_sucess_widget.dart';
import '/components/select_location_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'schedule_picku_up_model.dart';
export 'schedule_picku_up_model.dart';

class SchedulePickuUpWidget extends StatefulWidget {
  const SchedulePickuUpWidget({
    super.key,
    required this.order,
  });

  final DocumentReference? order;

  @override
  State<SchedulePickuUpWidget> createState() => _SchedulePickuUpWidgetState();
}

class _SchedulePickuUpWidgetState extends State<SchedulePickuUpWidget>
    with TickerProviderStateMixin {
  late SchedulePickuUpModel _model;

  var hasContainerTriggered = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SchedulePickuUpModel());

    _model.textFieldFocusNode ??= FocusNode();

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
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RideOrdersRecord>(
      stream: RideOrdersRecord.getDocument(widget.order!),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: SpinKitDoubleBounce(
                color: FlutterFlowTheme.of(context).accent1,
                size: 50.0,
              ),
            ),
          );
        }

        final containerRideOrdersRecord = snapshot.data!;

        return Container(
          width: double.infinity,
          height: 470.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0.0),
              bottomRight: Radius.circular(0.0),
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  FFLocalizations.of(context).getText(
                    'w0u7bqkr' /* Schedule Pickup */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF1B1B1C),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
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
                                      '4fvoeal1' /* Pickup */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 10.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                logFirebaseEvent(
                                    'SCHEDULE_PICKU_UP_ContainerDay_ON_TAP');
                                logFirebaseEvent('ContainerDay_bottom_sheet');
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
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
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
                                      containerRideOrdersRecord
                                                      .nomeOrigem !=
                                                  ''
                                          ? containerRideOrdersRecord.nomeOrigem
                                          : 'Bay Street 14',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
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
                                      'wcdbs5fg' /* Dropoff */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 10.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                logFirebaseEvent(
                                    'SCHEDULE_PICKU_UP_ContainerDay_ON_TAP');
                                logFirebaseEvent('ContainerDay_bottom_sheet');
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
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
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
                                      containerRideOrdersRecord
                                                      .nomeDestino !=
                                                  ''
                                          ? containerRideOrdersRecord
                                              .nomeDestino
                                          : 'Lynden Pindling Airport',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
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
                                      'q68ukv21' /* Date */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.normal,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          fontSize: 10.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.normal,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                logFirebaseEvent(
                                    'SCHEDULE_PICKU_UP_ContainerDay_ON_TAP');
                                logFirebaseEvent(
                                    'ContainerDay_date_time_picker');
                                final _datePickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: getCurrentTimestamp,
                                  firstDate: getCurrentTimestamp,
                                  lastDate: DateTime(2050),
                                  builder: (context, child) {
                                    return wrapInMaterialDatePickerTheme(
                                      context,
                                      child!,
                                      headerBackgroundColor:
                                          FlutterFlowTheme.of(context).primary,
                                      headerForegroundColor:
                                          FlutterFlowTheme.of(context).info,
                                      headerTextStyle: FlutterFlowTheme.of(
                                              context)
                                          .headlineLarge
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineLarge
                                                      .fontStyle,
                                            ),
                                            fontSize: 32.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .headlineLarge
                                                    .fontStyle,
                                          ),
                                      pickerBackgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      pickerForegroundColor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      selectedDateTimeBackgroundColor:
                                          FlutterFlowTheme.of(context).primary,
                                      selectedDateTimeForegroundColor:
                                          FlutterFlowTheme.of(context).info,
                                      actionButtonForegroundColor:
                                          FlutterFlowTheme.of(context)
                                              .primaryText,
                                      iconSize: 24.0,
                                    );
                                  },
                                );

                                TimeOfDay? _datePickedTime;
                                if (_datePickedDate != null) {
                                  _datePickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                        getCurrentTimestamp),
                                    builder: (context, child) {
                                      return wrapInMaterialTimePickerTheme(
                                        context,
                                        child!,
                                        headerBackgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        headerForegroundColor:
                                            FlutterFlowTheme.of(context).info,
                                        headerTextStyle: FlutterFlowTheme.of(
                                                context)
                                            .headlineLarge
                                            .override(
                                              font: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .headlineLarge
                                                        .fontStyle,
                                              ),
                                              fontSize: 32.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineLarge
                                                      .fontStyle,
                                            ),
                                        pickerBackgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        pickerForegroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        selectedDateTimeBackgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        selectedDateTimeForegroundColor:
                                            FlutterFlowTheme.of(context).info,
                                        actionButtonForegroundColor:
                                            FlutterFlowTheme.of(context)
                                                .primaryText,
                                        iconSize: 24.0,
                                      );
                                    },
                                  );
                                }

                                if (_datePickedDate != null &&
                                    _datePickedTime != null) {
                                  safeSetState(() {
                                    _model.datePicked = DateTime(
                                      _datePickedDate.year,
                                      _datePickedDate.month,
                                      _datePickedDate.day,
                                      _datePickedTime!.hour,
                                      _datePickedTime.minute,
                                    );
                                  });
                                } else if (_model.datePicked != null) {
                                  safeSetState(() {
                                    _model.datePicked = getCurrentTimestamp;
                                  });
                                }
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width * 1.0,
                                height: 35.0,
                                decoration: BoxDecoration(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
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
                                      () {
                                        if ((containerRideOrdersRecord.dia !=
                                                null) &&
                                            (_model.datePicked == null)) {
                                          return '${dateTimeFormat(
                                            "EEEE",
                                            containerRideOrdersRecord.dia,
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
                                          )} - ${dateTimeFormat(
                                            "jm",
                                            containerRideOrdersRecord.dia,
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
                                          )}';
                                        } else if ((containerRideOrdersRecord
                                                    .dia ==
                                                null) &&
                                            (_model.datePicked != null)) {
                                          return '${dateTimeFormat(
                                            "EEEE",
                                            _model.datePicked,
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
                                          )} - ${dateTimeFormat(
                                            "jm",
                                            _model.datePicked,
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
                                          )}';
                                        } else {
                                          return '${dateTimeFormat(
                                            "EEEE",
                                            getCurrentTimestamp,
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
                                          )} - ${dateTimeFormat(
                                            "jm",
                                            getCurrentTimestamp,
                                            locale: FFLocalizations.of(context)
                                                .languageCode,
                                          )}';
                                        }
                                      }(),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.poppins(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
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
                                '3usdhe18' /* Vehicle */,
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
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
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
                                logFirebaseEvent(
                                    'SCHEDULE_PICKU_UP_Container_n78u2gyg_ON_');
                                if (_model.action == 'Ride') {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
                                  _model.action = 'Ride';
                                  safeSetState(() {});
                                } else {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
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
                                        () {
                                          if (_model.action == 'Ride') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else if (containerRideOrdersRecord
                                                  .option ==
                                              'Ride') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
                                        FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      valueOrDefault<Color>(
                                        () {
                                          if (_model.action == 'Ride') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else if (containerRideOrdersRecord
                                                  .option ==
                                              'Ride') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
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
                                    'fcwq3ubh' /* Ride */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: valueOrDefault<Color>(
                                          () {
                                            if (_model.action == 'Ride') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else if (containerRideOrdersRecord
                                                    .option ==
                                                'Ride') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .alternate;
                                            }
                                          }(),
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
                                logFirebaseEvent(
                                    'SCHEDULE_PICKU_UP_Container_6w5oeatq_ON_');
                                if (_model.action == 'XL') {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
                                  _model.action = 'Ride';
                                  safeSetState(() {});
                                } else {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
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
                                        () {
                                          if (_model.action == 'XL') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else if (containerRideOrdersRecord
                                                  .option ==
                                              'XL') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .tertiary;
                                          }
                                        }(),
                                        FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      valueOrDefault<Color>(
                                        () {
                                          if (_model.action == 'XL') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else if (containerRideOrdersRecord
                                                  .option ==
                                              'XL') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .tertiary;
                                          }
                                        }(),
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
                                    'i2h37o56' /* XL */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: valueOrDefault<Color>(
                                          () {
                                            if (_model.action == 'XL') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else if (containerRideOrdersRecord
                                                    .option ==
                                                'XL') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .alternate;
                                            }
                                          }(),
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
                                logFirebaseEvent(
                                    'SCHEDULE_PICKU_UP_Container_3imdw5ow_ON_');
                                if (_model.action == 'Luxury') {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
                                  _model.action = 'Ride';
                                  safeSetState(() {});
                                } else {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
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
                                        () {
                                          if (_model.action == 'Luxury') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else if (containerRideOrdersRecord
                                                  .option ==
                                              'Luxury') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
                                        FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      valueOrDefault<Color>(
                                        () {
                                          if (_model.action == 'Luxury') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else if (containerRideOrdersRecord
                                                  .option ==
                                              'Luxury') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
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
                                    'bty2m5u3' /* Luxury */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: valueOrDefault<Color>(
                                          () {
                                            if (_model.action == 'Luxury') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else if (containerRideOrdersRecord
                                                    .option ==
                                                'Luxury') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .alternate;
                                            }
                                          }(),
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
                                'yhw91pyp' /* Repeat */,
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
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
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
                                logFirebaseEvent(
                                    'SCHEDULE_PICKU_UP_Container_0cke5gl8_ON_');
                                if (_model.repeat == 'One-time') {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
                                  _model.repeat = 'One-time';
                                  safeSetState(() {});
                                } else {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
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
                                        () {
                                          if (_model.repeat == 'One-time') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else if (containerRideOrdersRecord
                                                  .repeat ==
                                              'One-time') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
                                        FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      valueOrDefault<Color>(
                                        () {
                                          if (_model.repeat == 'One-time') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else if (containerRideOrdersRecord
                                                  .repeat ==
                                              'One-time') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
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
                                    'h4d3uj9f' /* One-time */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: valueOrDefault<Color>(
                                          () {
                                            if (_model.repeat == 'One-time') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else if (containerRideOrdersRecord
                                                    .repeat ==
                                                'One-time') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .alternate;
                                            }
                                          }(),
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
                                logFirebaseEvent(
                                    'SCHEDULE_PICKU_UP_Container_0lczl03i_ON_');
                                if (_model.repeat == 'Weekdays') {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
                                  _model.repeat = 'One-time';
                                  safeSetState(() {});
                                } else {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
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
                                        () {
                                          if (_model.repeat == 'Weekdays') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else if (containerRideOrdersRecord
                                                  .repeat ==
                                              'Weekdays') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
                                        FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      valueOrDefault<Color>(
                                        () {
                                          if (_model.repeat == 'Weekdays') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else if (containerRideOrdersRecord
                                                  .repeat ==
                                              'Weekdays') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
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
                                    'simj912b' /* Weekdays */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: valueOrDefault<Color>(
                                          () {
                                            if (_model.repeat == 'Weekdays') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else if (containerRideOrdersRecord
                                                    .repeat ==
                                                'Weekdays') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .alternate;
                                            }
                                          }(),
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
                                logFirebaseEvent(
                                    'SCHEDULE_PICKU_UP_Container_hvnrj0ko_ON_');
                                if (_model.repeat == 'Custom') {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
                                  _model.repeat = 'One-time';
                                  safeSetState(() {});
                                } else {
                                  logFirebaseEvent(
                                      'Container_update_component_state');
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
                                        () {
                                          if (_model.repeat == 'Custom') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else if (containerRideOrdersRecord
                                                  .repeat ==
                                              'Custom') {
                                            return FlutterFlowTheme.of(context)
                                                .secondaryBackground;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
                                        FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      valueOrDefault<Color>(
                                        () {
                                          if (_model.repeat == 'Custom') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else if (containerRideOrdersRecord
                                                  .repeat ==
                                              'Custom') {
                                            return FlutterFlowTheme.of(context)
                                                .accent1;
                                          } else {
                                            return FlutterFlowTheme.of(context)
                                                .primaryBackground;
                                          }
                                        }(),
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
                                    'uuf6olc6' /* Custom */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: valueOrDefault<Color>(
                                          () {
                                            if (_model.repeat == 'Custom') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else if (containerRideOrdersRecord
                                                    .repeat ==
                                                'Custom') {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .primary;
                                            } else {
                                              return FlutterFlowTheme.of(
                                                      context)
                                                  .alternate;
                                            }
                                          }(),
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
                    height: 70.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF1B1B1C),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
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
                                controller: _model.textController ??=
                                    TextEditingController(
                                  text: containerRideOrdersRecord.notas,
                                ),
                                focusNode: _model.textFieldFocusNode,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                                    '3myclplm' /* Notes (optional) */,
                                  ),
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.poppins(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
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
                                          .alternate,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
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
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    logFirebaseEvent('SCHEDULE_PICKU_UP_ContainerSave_ON_TAP');
                    logFirebaseEvent('ContainerSave_widget_animation');
                    if (animationsMap['containerOnActionTriggerAnimation'] !=
                        null) {
                      safeSetState(() => hasContainerTriggered = true);
                      SchedulerBinding.instance.addPostFrameCallback(
                          (_) async => await animationsMap[
                                  'containerOnActionTriggerAnimation']!
                              .controller
                              .forward(from: 0.0));
                    }
                    logFirebaseEvent('ContainerSave_backend_call');

                    var rideOrdersRecordReference =
                        RideOrdersRecord.collection.doc();
                    await rideOrdersRecordReference
                        .set(createRideOrdersRecordData(
                      user: currentUserReference,
                      latlng: containerRideOrdersRecord.latlng,
                      dia: _model.datePicked != null
                          ? _model.datePicked
                          : getCurrentTimestamp,
                      option: _model.action,
                      latlngAtual: containerRideOrdersRecord.latlngAtual,
                      notas: _model.textController.text,
                      repeat: _model.repeat,
                      salvarSomente: true,
                    ));
                    _model.orderRef = RideOrdersRecord.getDocumentFromData(
                        createRideOrdersRecordData(
                          user: currentUserReference,
                          latlng: containerRideOrdersRecord.latlng,
                          dia: _model.datePicked != null
                              ? _model.datePicked
                              : getCurrentTimestamp,
                          option: _model.action,
                          latlngAtual: containerRideOrdersRecord.latlngAtual,
                          notas: _model.textController.text,
                          repeat: _model.repeat,
                          salvarSomente: true,
                        ),
                        rideOrdersRecordReference);
                    logFirebaseEvent('ContainerSave_bottom_sheet');
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
                    height: 40.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FlutterFlowTheme.of(context).secondaryBackground,
                          FlutterFlowTheme.of(context).accent1
                        ],
                        stops: [0.0, 1.0],
                        begin: AlignmentDirectional(-0.34, 1.0),
                        end: AlignmentDirectional(0.34, -1.0),
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        '9en68510' /* Schedule */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primary,
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                ).animateOnActionTrigger(
                    animationsMap['containerOnActionTriggerAnimation']!,
                    hasBeenTriggered: hasContainerTriggered),
              ].divide(SizedBox(height: 8.0)),
            ),
          ),
        );
      },
    );
  }
}
