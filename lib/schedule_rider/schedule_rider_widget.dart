import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
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
          ],
        ),
      ),
    );
  }
}
