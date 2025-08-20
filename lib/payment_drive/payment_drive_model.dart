import '/flutter_flow/flutter_flow_util.dart';
import 'payment_drive_widget.dart' show PaymentDriveWidget;
import 'package:flutter/material.dart';

class PaymentDriveModel extends FlutterFlowModel<PaymentDriveWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
