// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/actions/index.dart';

import 'dart:async';
import 'package:geolocator/geolocator.dart';

class _LocStreamHolderSimple {
  static StreamSubscription<Position>? sub;
}

/// Requisitos no FFAppState:
/// double currentLat = 0;
/// double currentLng = 0;
/// DateTime? locationTimestamp;
/// String locationStatus = 'idle';
Future<void> startLocationStreamSimple(BuildContext context) async {
  // 1) Serviços/permissão
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    FFAppState().locationStatus = 'denied';
    // opcional: abrir ajustes
    try {
      await Geolocator.openLocationSettings();
    } catch (_) {}
    return;
  }
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
  }
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    FFAppState().locationStatus = 'denied';
    return;
  }
  FFAppState().locationStatus = 'ok';

  // 2) Cancela stream anterior
  await _LocStreamHolderSimple.sub?.cancel();
  _LocStreamHolderSimple.sub = null;

  // 3) Settings universais (compatível com Web/iOS/Android)
  const distanceFilterMeters = 5; // ajuste depois se quiser
  const acc = LocationAccuracy.high;

  final settings = LocationSettings(
    accuracy: acc,
    distanceFilter: distanceFilterMeters,
  );

  // 4) Assina o stream
  _LocStreamHolderSimple.sub =
      Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
    if (pos == null) return;
    FFAppState().currentLat = pos.latitude;
    FFAppState().currentLng = pos.longitude;
    FFAppState().locationTimestamp = DateTime.now();
  }, onError: (_) {
    FFAppState().locationStatus = 'denied';
  });

  // 5) Posição inicial rápida
  try {
    final last = await Geolocator.getCurrentPosition(desiredAccuracy: acc);
    FFAppState().currentLat = last.latitude;
    FFAppState().currentLng = last.longitude;
    FFAppState().locationTimestamp = DateTime.now();
  } catch (_) {}
}
