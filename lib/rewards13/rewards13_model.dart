import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'rewards13_widget.dart' show Rewards13Widget;
import 'package:flutter/material.dart';

class Rewards13Model extends FlutterFlowModel<Rewards13Widget> {
  ///  Local state fields for this page.

  String? click = 'All';

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
