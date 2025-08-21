import '/flutter_flow/flutter_flow_util.dart';
import 'payment_ride7_widget.dart' show PaymentRide7Widget;
import 'package:flutter/material.dart';

class PaymentRide7Model extends FlutterFlowModel<PaymentRide7Widget> {
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
