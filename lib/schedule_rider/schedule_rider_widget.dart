import '/backend/backend.dart';
import '/components/component_schedule_action_widget.dart';
import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'schedule_rider_model.dart';
export 'schedule_rider_model.dart';

class ScheduleRiderWidget extends StatefulWidget {
  const ScheduleRiderWidget({super.key});

  static String routeName = 'ScheduleRider';
  static String routePath = '/scheduleRider';

  @override
  State<ScheduleRiderWidget> createState() => _ScheduleRiderWidgetState();
}

class _ScheduleRiderWidgetState extends State<ScheduleRiderWidget> {
  late ScheduleRiderModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ScheduleRiderModel());

    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'ScheduleRider'});
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
              alignment: AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.navbarModel,
                updateCallback: () => safeSetState(() {}),
                child: NavbarWidget(),
              ),
            ),
            StreamBuilder<List<RideOrdersRecord>>(
              stream: queryRideOrdersRecord(),
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
                List<RideOrdersRecord>
                    scheduleCalendarRideRideOrdersRecordList = snapshot.data!;

                return Container(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.9,
                  child: custom_widgets.ScheduleCalendarRide(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.9,
                    disableBookedSlots: false,
                    use24hFormat: false,
                    // Use a valid intl locale (language + country)
                    dateLocale: 'en_US',
                    initialDate: getCurrentTimestamp,
                    orders: scheduleCalendarRideRideOrdersRecordList,
                    order: scheduleCalendarRideRideOrdersRecordList,
                    onSelected: (date) async {},
                    openPage: (orderRef) async {},
                    abrirPage: (orderRef) async {},
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
    );
  }
}
