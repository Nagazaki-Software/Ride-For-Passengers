// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';

class _LocStreamHolderSimple {
  static StreamSubscription? sub;
}

Future<void> stopLocationStreamSimple(BuildContext context) async {
  try {
    await _LocStreamHolderSimple.sub?.cancel();
    _LocStreamHolderSimple.sub = null;
  } catch (_) {}
}
