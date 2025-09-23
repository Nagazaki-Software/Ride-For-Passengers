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

  String? rideID;

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Stores action output result for [Custom Action - processCardPayload] action in ContainerConfirmPay widget.
  dynamic processPayment;
  // Stores action output result for [Backend Call - API (latlng To String)] action in ContainerConfirmPay widget.
  ApiCallResponse? latlngOrigem;
  // Stores action output result for [Backend Call - API (latlng To String)] action in ContainerConfirmPay widget.
  ApiCallResponse? latlngDestino;
  // Stores action output result for [Backend Call - Create Document] action in ContainerConfirmPay widget.
  RideOrdersRecord? order;
  // Stores action output result for [Backend Call - API (latlng To String)] action in Text widget.
  ApiCallResponse? latlngOrigemcop;
  // Stores action output result for [Backend Call - API (latlng To String)] action in Text widget.
  ApiCallResponse? latlngDestinocop;
  // Stores action output result for [Backend Call - Create Document] action in Text widget.
  RideOrdersRecord? ordertest;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
