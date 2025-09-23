import '/auth/firebase_auth/auth_util.dart';
import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

Future passUpdate(BuildContext context) async {
  PasseUpdateCloudFunctionCallResponse? cloudFunctionh5j;

  logFirebaseEvent('passUpdate_cloud_function');
  try {
    final result =
        await FirebaseFunctions.instance.httpsCallable('passeUpdate').call({
      "users": currentUserUid,
    });
    cloudFunctionh5j = PasseUpdateCloudFunctionCallResponse(
      succeeded: true,
    );
  } on FirebaseFunctionsException catch (error) {
    cloudFunctionh5j = PasseUpdateCloudFunctionCallResponse(
      errorCode: error.code,
      succeeded: false,
    );
  }
}
