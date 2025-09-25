import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'schedule_picku_up_widget.dart' show SchedulePickuUpWidget;
import 'package:flutter/material.dart';

class SchedulePickuUpModel extends FlutterFlowModel<SchedulePickuUpWidget> {
  ///  Local state fields for this component.

  String action = 'Ride';

  String repeat = 'One-time';

  ///  State fields for stateful widgets in this component.

  DateTime? datePicked;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - Create Document] action in ContainerSave widget.
  RideOrdersRecord? orderRef;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
