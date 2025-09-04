import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'activity20_widget.dart' show Activity20Widget;
import 'package:flutter/material.dart';

class Activity20Model extends FlutterFlowModel<Activity20Widget> {
  ///  Local state fields for this page.

  String? choiceChip = 'All';

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
