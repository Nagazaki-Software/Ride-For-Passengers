import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'profile15_widget.dart' show Profile15Widget;
import 'package:flutter/material.dart';

class Profile15Model extends FlutterFlowModel<Profile15Widget> {
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
