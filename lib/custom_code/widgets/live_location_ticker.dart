// lib/custom_code/live_location_ticker.dart
// Stream global de localização: atualiza FFAppState().latlngAtual em tempo real.
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/flutter_flow_util.dart'; // FFAppState

class LiveLocationTicker extends StatefulWidget {
  const LiveLocationTicker({super.key, required this.child});
  final Widget child;

  @override
  State<LiveLocationTicker> createState() => _LiveLocationTickerState();
}

class _LiveLocationTickerState extends State<LiveLocationTicker> {
  StreamSubscription<Position>? _sub;

  // Filtros pra evitar “tremedeira” e spam.
  static const _distanceFilterMeters = 7.0; // ignora variações pequenas
  static const _intervalSeconds = 2;        // no máx. 1 update a cada 2s

  Position? _lastPos;
  DateTime? _lastEmitAt;

  Future<bool> _ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  void _publish(Position p) {
    // Filtro de distância
    if (_lastPos != null) {
      final d = Geolocator.distanceBetween(
        _lastPos!.latitude, _lastPos!.longitude, p.latitude, p.longitude,
      );
      if (d < _distanceFilterMeters) return;
    }
    // Filtro de tempo
    final now = DateTime.now();
    if (_lastEmitAt != null && now.difference(_lastEmitAt!).inSeconds < _intervalSeconds) {
      return;
    }

    _lastPos = p;
    _lastEmitAt = now;

    // Atualiza o FFAppState globalmente (sem prints).
    FFAppState().latlngAtual = LatLng(p.latitude, p.longitude);
    FFAppState().update(() {});
  }

  Future<void> _start() async {
    if (!await _ensurePermission()) {
      // Sem permissão, não faz nada e deixa o app seguir a vida.
      return;
    }

    // Fix inicial (se disponível)
    try {
      final first = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _publish(first);
    } catch (_) {
      // ignora erro do fix inicial
    }

    // Stream contínua
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // Android/iOS já aplicam parte do filtro
    );

    await _sub?.cancel();
    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(_publish);
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
