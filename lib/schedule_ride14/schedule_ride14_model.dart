import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'schedule_ride14_widget.dart' show ScheduleRide14Widget;
import 'package:flutter/material.dart';

class ScheduleRide14Model extends FlutterFlowModel<ScheduleRide14Widget> {
  ///  Local state fields for this page.

  String? veiculos;

  String? repeat;

  DateTime? date;

  ///  State fields for stateful widgets in this page.

  // Model for navbar component.
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel.dispose();
  }
}
