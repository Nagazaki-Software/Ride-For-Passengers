import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'payment_mothods16_widget.dart' show PaymentMothods16Widget;
import 'package:flutter/material.dart';

class PaymentMothods16Model extends FlutterFlowModel<PaymentMothods16Widget> {
  ///  Local state fields for this page.

  String? click;

  PaymentMethodSaveStruct? cardClick;
  void updateCardClickStruct(Function(PaymentMethodSaveStruct) updateFn) {
    updateFn(cardClick ??= PaymentMethodSaveStruct());
  }

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
