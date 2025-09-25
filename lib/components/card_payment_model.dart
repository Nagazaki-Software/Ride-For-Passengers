import '/flutter_flow/flutter_flow_credit_card_form.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'card_payment_widget.dart' show CardPaymentWidget;
import 'package:flutter/material.dart';

class CardPaymentModel extends FlutterFlowModel<CardPaymentWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Braintree Payment] action in Button widget.
  String? transactionId;
  // State field(s) for CreditCardForm widget.
  final creditCardFormKey = GlobalKey<FormState>();
  CreditCardModel creditCardInfo = emptyCreditCard();
  // Stores action output result for [Braintree Payment] action in Button widget.
  String? transactionId3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
