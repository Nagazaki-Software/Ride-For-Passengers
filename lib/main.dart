import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'background_tasks.dart'; // importa o arquivo acima

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Registra o job apenas no Android (AAB é Android; iOS tem outras regras)
  if (!kIsWeb && Platform.isAndroid) {
    await registerBackgroundFetch();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('WorkManager ligado ✅')),
      ),
    );
  }
}
