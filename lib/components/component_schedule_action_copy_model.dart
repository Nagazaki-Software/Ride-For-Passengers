import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'component_schedule_action_copy_widget.dart'
    show ComponentScheduleActionCopyWidget;
import 'package:flutter/material.dart';

class ComponentScheduleActionCopyModel
    extends FlutterFlowModel<ComponentScheduleActionCopyWidget> {
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
