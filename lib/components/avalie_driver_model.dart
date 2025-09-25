import '/flutter_flow/flutter_flow_util.dart';
import 'avalie_driver_widget.dart' show AvalieDriverWidget;
import 'package:flutter/material.dart';

class AvalieDriverModel extends FlutterFlowModel<AvalieDriverWidget> {
  ///  Local state fields for this component.

  List<int> whatStoodOut = [];
  void addToWhatStoodOut(int item) => whatStoodOut.add(item);
  void removeFromWhatStoodOut(int item) => whatStoodOut.remove(item);
  void removeAtIndexFromWhatStoodOut(int index) => whatStoodOut.removeAt(index);
  void insertAtIndexInWhatStoodOut(int index, int item) =>
      whatStoodOut.insert(index, item);
  void updateWhatStoodOutAtIndex(int index, Function(int) updateFn) =>
      whatStoodOut[index] = updateFn(whatStoodOut[index]);

  List<int> anything = [];
  void addToAnything(int item) => anything.add(item);
  void removeFromAnything(int item) => anything.remove(item);
  void removeAtIndexFromAnything(int index) => anything.removeAt(index);
  void insertAtIndexInAnything(int index, int item) =>
      anything.insert(index, item);
  void updateAnythingAtIndex(int index, Function(int) updateFn) =>
      anything[index] = updateFn(anything[index]);

  ///  State fields for stateful widgets in this component.

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
