import 'package:cloud_functions/cloud_functions.dart';

Future<Map<String, dynamic>> makeCloudCall(
  String callName,
  Map<String, dynamic> input,
) async {
  try {
    final response = await FirebaseFunctions.instance
        .httpsCallable(callName, options: HttpsCallableOptions())
        .call(input);
    return response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : {};
  } on FirebaseFunctionsException catch (e) {
    print(
      'Cloud call error!\n$callName\n'
      'Code: ${e.code}\n'
      'Details: ${e.details}\n'
      'Message: ${e.message}',
    );
    final Map<String, dynamic> err = {
      'error': e.message ?? e.code,
      if (e.details != null && e.details is Map) ...{
        'details': Map<String, dynamic>.from(e.details as Map),
      } else if (e.details != null) ...{
        'details': {'info': e.details.toString()},
      }
    };
    return err;
  } catch (e) {
    print('Cloud call error:$callName $e');
    return {
      'error': e.toString(),
    };
  }
}

Future<Map<String, dynamic>> cancelRideAndRefund({
  required String orderPath,
  String? reason,
  bool allowRefund = true,
  bool isProd = false,
}) async {
  return await makeCloudCall('cancelRideAndRefund', {
    'orderPath': orderPath,
    if (reason != null) 'reason': reason,
    'allowRefund': allowRefund,
    'isProd': isProd,
  });
}

Future<Map<String, dynamic>> refundTransaction({
  required String transactionId,
  double? amount,
  bool isProd = false,
}) async {
  return await makeCloudCall('refundTransaction', {
    'transactionId': transactionId,
    if (amount != null) 'amount': amount,
    'isProd': isProd,
  });
}
