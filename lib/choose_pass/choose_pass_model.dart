import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import '/index.dart';
import 'choose_pass_widget.dart' show ChoosePassWidget;
import 'package:flutter/material.dart';

class ChoosePassModel extends FlutterFlowModel<ChoosePassWidget> {
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
