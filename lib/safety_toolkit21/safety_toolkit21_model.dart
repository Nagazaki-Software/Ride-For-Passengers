import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'safety_toolkit21_widget.dart' show SafetyToolkit21Widget;
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
=======
>>>>>>> master

class SafetyToolkit21Model extends FlutterFlowModel<SafetyToolkit21Widget> {
  ///  Local state fields for this page.

  String? click;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Switch widget.
  bool? switchValue1;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
<<<<<<< HEAD
  late MaskTextInputFormatter textFieldMask2;
=======
>>>>>>> master
  String? Function(BuildContext, String?)? textController2Validator;
  // Model for navbar component.
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    navbarModel.dispose();
  }
}
