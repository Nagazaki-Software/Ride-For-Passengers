import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'tip_driver_widget.dart' show TipDriverWidget;
import 'package:flutter/material.dart';

class TipDriverModel extends FlutterFlowModel<TipDriverWidget> {
  ///  Local state fields for this component.

  double tipvalue = 1.0;

  PaymentMethodSaveStruct? cardSelected;
  void updateCardSelectedStruct(Function(PaymentMethodSaveStruct) updateFn) {
    updateFn(cardSelected ??= PaymentMethodSaveStruct());
  }

  ///  State fields for stateful widgets in this component.

  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  // Stores action output result for [Braintree Payment] action in Button widget.
  String? transactionId3;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
