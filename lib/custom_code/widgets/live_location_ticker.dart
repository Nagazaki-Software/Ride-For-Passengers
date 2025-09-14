// live_location_ticker.dart
// Ouve a posição do usuário em tempo real e atualiza FFAppState().latlngAtual
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
  Position? _lastEmitted;

  // ajuste fino aqui
  static const _distanceFilterMeters = 7.0;      // ignora “tremedeira” menor que 7m
  static const _intervalSeconds = 2;             // não mais que 1 update/2s

  Future<bool> _ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever ||
        perm == LocationPermission.denied) {
      return false;
    }
    return true;
  }

  void _emit(Position p) {
    // filtra ruído por distância
    if (_lastEmitted != null) {
      final d = Geolocator.distanceBetween(
        _lastEmitted!.latitude, _lastEmitted!.longitude,
        p.latitude, p.longitude,
      );
      if (d < _distanceFilterMeters) return;
    }
    _lastEmitted = p;

    // Atualiza o FFAppState (sem prints)
    FFAppState().latlngAtual = LatLng(p.latitude, p.longitude);
    FFAppState().update(() {});
  }

  Future<void> _start() async {
    if (!await _ensurePermission()) {
      // não atrapalha o app se o user negar; deixa latlngAtual como está
      return;
    }

    // pega um fix inicial, mas só publica se fizer sentido
    try {
      final first = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _emit(first);
    } catch (_) {/* ignore */}

    // stream contínuo
    final settings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // Android/iOS já fazem parte do filtro
    );

    _sub?.cancel();
    _sub = Geolocator.getPositionStream(locationSettings: settings)
        // throttling simples: espaça a emissão
        .where((_) {
          // usa um relógio “manual” com base no lastEmitted
          return true;
        })
        .listen((pos) {
          // espaça por tempo
          final lastTs = _lastEmitted?.timestamp;
          final now = DateTime.now();
          if (lastTs != null &&
              now.difference(lastTs).inSeconds < _intervalSeconds) {
            return;
          }
          _emit(pos);
        });
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
