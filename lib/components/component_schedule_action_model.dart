import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'component_schedule_action_widget.dart'
    show ComponentScheduleActionWidget;
import 'package:flutter/material.dart';

class ComponentScheduleActionModel
    extends FlutterFlowModel<ComponentScheduleActionWidget> {
  ///  Local state fields for this component.

  String action = 'Ride';

  String repeat = 'One-time';

  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Backend Call - Create Document] action in Container widget.
  RideOrdersRecord? orderRef;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
