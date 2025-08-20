// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Automatic FlutterFlow imports:
import 'dart:async';
import 'package:flutter/foundation.dart';

Future<String> localGreetingAction() async {
  // Hora local do dispositivo
  final now = DateTime.now();
  final hour = now.hour;

  // Sempre inglês
  const isEnglish = true;

  // Faixas de horário:
  String greeting;
  String emoji;

  if (hour >= 0 && hour <= 4) {
    greeting = 'Good early morning';
    emoji = '🌙';
  } else if (hour >= 5 && hour <= 11) {
    greeting = 'Good morning';
    emoji = '🌤️';
  } else if (hour >= 12 && hour <= 17) {
    greeting = 'Good afternoon';
    emoji = '☀️';
  } else {
    greeting = 'Good evening';
    emoji = '🌆';
  }

  // String final — ex.: "Good morning 🌤️"
  final result = '$greeting $emoji';

  return result;
}
