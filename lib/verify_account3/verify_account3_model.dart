import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'verify_account3_widget.dart' show VerifyAccount3Widget;
import 'package:flutter/material.dart';

class VerifyAccount3Model extends FlutterFlowModel<VerifyAccount3Widget> {
  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }
}
