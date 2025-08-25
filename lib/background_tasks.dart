import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

const kTaskId = 'periodic-fetch';

@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // TODO: sua lógica de sync/fetch aqui
    debugPrint('[WorkManager] Executando task: $task');
    return Future.value(true);
  });
}

Future<void> registerBackgroundFetch() async {
  await Workmanager().initialize(
    backgroundCallbackDispatcher,
    isInDebugMode: kDebugMode,
  );
  await Workmanager().registerPeriodicTask(
    'fetch-id-15min',
    kTaskId,
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 5),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );
}
