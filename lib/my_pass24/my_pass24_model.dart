import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'my_pass24_widget.dart' show MyPass24Widget;
import 'package:flutter/material.dart';

class MyPass24Model extends FlutterFlowModel<MyPass24Widget> {
  ///  Local state fields for this page.

  String? click;

  ///  State fields for stateful widgets in this page.

  // Model for navbar component.
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel.dispose();
  }
}
