import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'schedule_ride14_widget.dart' show ScheduleRide14Widget;
import 'package:flutter/material.dart';

class ScheduleRide14Model extends FlutterFlowModel<ScheduleRide14Widget> {
  ///  Local state fields for this page.

  String? veiculos;

  String? repeat;

  DateTime? date;

  ///  State fields for stateful widgets in this page.

  // Model for navbar component.
  late NavbarModel navbarModel;

  // Controllers and focus nodes for text fields used in the page.
  final unfocusNode = FocusNode();
  TextEditingController? textController1;
  FocusNode? textFieldFocusNode1;
  String? Function(BuildContext, String?)? textController1Validator;

  TextEditingController? textController2;
  FocusNode? textFieldFocusNode2;
  String? Function(BuildContext, String?)? textController2Validator;

  TextEditingController? textController3;
  FocusNode? textFieldFocusNode3;
  String? Function(BuildContext, String?)? textController3Validator;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
    textFieldFocusNode1 = FocusNode();
    textFieldFocusNode2 = FocusNode();
    textFieldFocusNode3 = FocusNode();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    textController3 = TextEditingController();
  }

  @override
  void dispose() {
    navbarModel.dispose();
    unfocusNode.dispose();
    textFieldFocusNode1?.dispose();
    textFieldFocusNode2?.dispose();
    textFieldFocusNode3?.dispose();
    textController1?.dispose();
    textController2?.dispose();
    textController3?.dispose();
  }
}
