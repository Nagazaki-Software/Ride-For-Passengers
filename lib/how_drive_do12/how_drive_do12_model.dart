import '/flutter_flow/flutter_flow_util.dart';
import 'how_drive_do12_widget.dart' show HowDriveDo12Widget;
import 'package:flutter/material.dart';

class HowDriveDo12Model extends FlutterFlowModel<HowDriveDo12Widget> {
  ///  Local state fields for this page.

  String? rideChoose;

  ///  State fields for stateful widgets in this page.

  // State field(s) for RatingBar widget.
  double? ratingBarValue;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
