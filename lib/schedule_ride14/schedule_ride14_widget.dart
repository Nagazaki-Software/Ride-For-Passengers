import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/components/component_schedule_action_widget.dart';
import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'schedule_ride14_model.dart';
export 'schedule_ride14_model.dart';

class ScheduleRide14Widget extends StatefulWidget {
  const ScheduleRide14Widget({super.key});

  static String routeName = 'ScheduleRide14';
  static String routePath = '/scheduleRide14';

  @override
  State<ScheduleRide14Widget> createState() => _ScheduleRide14WidgetState();
}

class _ScheduleRide14WidgetState extends State<ScheduleRide14Widget> {
  late ScheduleRide14Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ScheduleRide14Model());
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
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 70.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          FFLocalizations.of(context).getText(
                            'o35t1fkk' /* Schedule a ride */,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).alternate,
                                fontSize: 22.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width * 0.92,
                          decoration: BoxDecoration(
                            color: Color(0xFF1B1B1C),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              StreamBuilder<List<RideOrdersRecord>>(
                                stream: queryRideOrdersRecord(
                                  queryBuilder: (rideOrdersRecord) =>
                                      rideOrdersRecord.where(
                                    'user',
                                    isEqualTo: currentUserReference,
                                  ),
                                ),
                                builder: (context, snapshot) {
                                  // Customize what your widget looks like when it's loading.
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: SizedBox(
                                        width: 50.0,
                                        height: 50.0,
                                        child: SpinKitDoubleBounce(
                                          color: FlutterFlowTheme.of(context)
                                              .accent1,
                                          size: 50.0,
                                        ),
                                      ),
                                    );
                                  }
                                  List<RideOrdersRecord>
                                      scheduleCaledarRideRideOrdersRecordList =
                                      snapshot.data!;

                                  return Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.9,
                                    height: 900.0,
                                    child: custom_widgets.ScheduleCaledarRide(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.9,
                                      height: 900.0,
                                      initialDate: getCurrentTimestamp,
                                      order:
                                          scheduleCaledarRideRideOrdersRecordList,
                                      onSelected: (date) async {
                                        _model.date = date;
                                        safeSetState(() {});
                                      },
                                      abrirPage: (orderRef) async {
                                        context.pushNamed(
                                          ViewDetalhesWidget.routeName,
                                          queryParameters: {
                                            'order': serializeParam(
                                              orderRef,
                                              ParamType.DocumentReference,
                                            ),
                                          }.withoutNulls,
                                        );
                                      },
                                      widgetAbaixo: (DateTime? date) =>
                                          ComponentScheduleActionWidget(
                                        parameter3: date,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ].divide(SizedBox(height: 10.0)),
                  ),
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.navbarModel,
                updateCallback: () => safeSetState(() {}),
                child: NavbarWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
