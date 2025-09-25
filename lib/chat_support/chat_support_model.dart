import '/flutter_flow/flutter_flow_util.dart';
import 'chat_support_widget.dart' show ChatSupportWidget;
import 'package:flutter/material.dart';

class ChatSupportModel extends FlutterFlowModel<ChatSupportWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataZuu = false;
  FFUploadedFile uploadedLocalFile_uploadDataZuu =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataZuu = '';

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
