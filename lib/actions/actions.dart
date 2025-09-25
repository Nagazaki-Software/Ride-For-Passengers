import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/custom_cloud_functions/custom_cloud_function_response_manager.dart';
import '/components/avalie_driver_widget.dart';
import '/components/raceemergency_widget.dart';
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

Future emergencyActive(BuildContext context) async {
  logFirebaseEvent('emergencyActive_bottom_sheet');
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    context: context,
    builder: (context) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: RaceemergencyWidget(),
      );
    },
  );
}

Future avaliateDriver(
  BuildContext context, {
  required DocumentReference? order,
}) async {
  logFirebaseEvent('avaliateDriver_bottom_sheet');
  await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    context: context,
    builder: (context) {
      return Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: AvalieDriverWidget(
          order: order!,
        ),
      );
    },
  );
}
