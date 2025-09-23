import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'schedule_rider_widget.dart' show ScheduleRiderWidget;
import 'package:flutter/material.dart';

class ScheduleRiderModel extends FlutterFlowModel<ScheduleRiderWidget> {
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
