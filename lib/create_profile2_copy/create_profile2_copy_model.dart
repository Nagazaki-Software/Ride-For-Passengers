import '/backend/backend.dart';
import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'create_profile2_copy_widget.dart' show CreateProfile2CopyWidget;
import 'package:flutter/material.dart';

class CreateProfile2CopyModel
    extends FlutterFlowModel<CreateProfile2CopyWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataF7h = false;
  FFUploadedFile uploadedLocalFile_uploadDataF7h =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataF7h = '';

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for TextFieldPassword widget.
  FocusNode? textFieldPasswordFocusNode;
  TextEditingController? textFieldPasswordTextController;
  late bool textFieldPasswordVisibility;
  String? Function(BuildContext, String?)?
      textFieldPasswordTextControllerValidator;
  bool isDataUploading_uploadDataM11 = false;
  FFUploadedFile uploadedLocalFile_uploadDataM11 =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataM11 = '';

  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;
  // Stores action output result for [Cloud Function - classificarDocBahamas] action in ContainerNext widget.
  ClassificarDocBahamasCloudFunctionCallResponse? classificarDocBhaaian;
  // Stores action output result for [Firestore Query - Query a collection] action in ContainerNext widget.
  List<UsersRecord>? usersList;
  // Stores action output result for [Custom Action - verifiqueRandomNumber] action in ContainerNext widget.
  String? randomNumber;

  @override
  void initState(BuildContext context) {
    textFieldPasswordVisibility = false;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    emailTextController?.dispose();

    textFieldPasswordFocusNode?.dispose();
    textFieldPasswordTextController?.dispose();
  }
}
