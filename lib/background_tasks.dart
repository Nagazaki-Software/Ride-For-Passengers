import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

const kTaskId = 'periodic-fetch';

@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // TODO: coloque aqui sua lógica de sync/fetch:
    // - chamar sua API
    // - salvar no Firestore/SQLite
    // - enviar analytics, etc.
    debugPrint('[WorkManager] Executando task: $task');

    // Retorne true em sucesso, false em falha para re-tentativa/backoff
    return Future.value(true);
  });
}

/// Registra a tarefa periódica (Android)
Future<void> registerBackgroundFetch() async {
  await Workmanager().initialize(
    backgroundCallbackDispatcher,
    isInDebugMode: kDebugMode, // log verboso em debug
  );

  await Workmanager().registerPeriodicTask(
    'fetch-id-15min',
    kTaskId,
    frequency: const Duration(minutes: 15), // mínimo do Android
    initialDelay: const Duration(minutes: 5),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
      requiresCharging: false,
    ),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );
}
