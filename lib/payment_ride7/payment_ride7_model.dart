import '/backend/api_requests/api_calls.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'payment_ride7_widget.dart' show PaymentRide7Widget;
import 'package:flutter/material.dart';

class PaymentRide7Model extends FlutterFlowModel<PaymentRide7Widget> {
  ///  Local state fields for this page.

  dynamic selectCard;

  int? selectTip;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - processCardPayload] action in Container widget.
  dynamic processPayment;
  // Stores action output result for [Backend Call - API (latlng To String)] action in Container widget.
  ApiCallResponse? latlngOrigem;
  // Stores action output result for [Backend Call - API (latlng To String)] action in Container widget.
  ApiCallResponse? latlngDestino;
  // Stores action output result for [Backend Call - Create Document] action in Container widget.
  RideOrdersRecord? order;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
