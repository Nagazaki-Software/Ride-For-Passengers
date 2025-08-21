import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'choose_pass4_widget.dart' show ChoosePass4Widget;
import 'package:flutter/material.dart';

class ChoosePass4Model extends FlutterFlowModel<ChoosePass4Widget> {
  ///  Local state fields for this page.

  String? click;

  ///  State fields for stateful widgets in this page.

  InstantTimer? instantTimer;
  InstantTimer? instantTimerweek;
  InstantTimer? instantTimerMonth;
  // State field(s) for Switch widget.
  bool? switchValue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
    instantTimerweek?.cancel();
    instantTimerMonth?.cancel();
  }
}
