// ignore_for_file: avoid_print
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // PlatformViewHitTestBehavior
import 'package:flutter/services.dart';
import 'package:ride_bahamas/flutter_flow/lat_lng.dart' as ff;

/// Nassau, Bahamas (fallback quando userLocation vier nulo/0,0)
const _kNassau = ff.LatLng(25.03428, -77.39628);

bool _isZero(ff.LatLng p) =>
    (p.latitude == 0.0 && p.longitude == 0.0) ||
    (p.latitude.abs() < 0.000001 && p.longitude.abs() < 0.000001);

ff.LatLng _safe(ff.LatLng p) => _isZero(p) ? _kNassau : p;

/// Controller para chamar métodos nativos (Android/iOS).
class PickerMapNativeController {
  MethodChannel? _channel;
  void _attach(MethodChannel ch) => _channel = ch;
  void _detach() => _channel = null;

  Future<void> updateConfig(Map<String, dynamic> cfg) async =>
      _channel?.invokeMethod('updateConfig', cfg) ?? Future.value();

  Future<void> setMarkers(List<Map<String, dynamic>> m) async =>
      _channel?.invokeMethod('setMarkers', m) ?? Future.value();

  Future<void> setPolylines(List<Map<String, dynamic>> l) async =>
      _channel?.invokeMethod('setPolylines', l) ?? Future.value();

  Future<void> setPolygons(List<Map<String, dynamic>> p) async =>
      _channel?.invokeMethod('setPolygons', p) ?? Future.value();

  Future<void> cameraTo(
    double lat,
    double lng, {
    double? zoom,
    double? bearing,
    double? tilt,
  }) async =>
      _channel?.invokeMethod('cameraTo', {
        'latitude': lat,
        'longitude': lng,
        if (zoom != null) 'zoom': zoom,
        if (bearing != null) 'bearing': bearing,
        if (tilt != null) 'tilt': tilt,
      }) ??
      Future.value();

  Future<void> fitBounds(List<ff.LatLng> pts, {double padding = 0}) async =>
      _channel?.invokeMethod('fitBounds', {
        'points': pts
            .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
            .toList(),
        'padding': padding,
      }) ??
      Future.value();

  Future<void> updateCarPosition(
    String id,
    ff.LatLng pos, {
    double? rotation,
    int? durationMs,
  }) async =>
      _channel?.invokeMethod('updateCarPosition', {
        'id': id,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        if (rotation != null) 'rotation': rotation,
        if (durationMs != null) 'durationMs': durationMs,
      }) ??
      Future.value();

  Future<dynamic> debugInfo() async =>
      _channel?.invokeMethod('debugInfo') ?? Future.value();
}

class PickerMapNative extends StatefulWidget {
  const PickerMapNative({
    super.key,
    required this.userLocation,
    this.destination,
    this.userName,
    this.userPhotoUrl,
    this.width,
    this.height = 320,
    this.borderRadius = 16,
    this.routeColor = const Color(0xFFBDBDBD), // rota cinza
    this.routeWidth = 5,
    this.controller,

    // ==== Compat (legado) — o nativo pode ignorar ====
    @Deprecated('Compat apenas. Não é usado pelo nativo.')
    this.driversRefs = const [],
    this.refreshMs,
    this.destinationMarkerPngUrl,
    this.userMarkerSize,
    this.driverIconWidth,
    this.driverTaxiIconAsset,
    this.driverDriverIconUrl,
    this.driverTaxiIconUrl,
    this.enableRouteSnake = false,
    this.liteModeOnAndroid,
    this.ultraLowSpecMode,
    this.brandSafePaddingBottom,
    // =================================================

    this.mapStyleJson,
    this.showDebugPanel = false, // desligado por padrão
  });

  /// Localização do usuário (FF LatLng)
  final ff.LatLng userLocation;

  /// Destino (opcional)
  final ff.LatLng? destination;

  /// Dados opcionais
  final String? userName;
  final String? userPhotoUrl;

  /// Layout
  final double? width;
  final double height;
  final double borderRadius;

  /// Rota
  final Color routeColor;
  final int routeWidth;

  /// Painel de debug (opcional)
  final bool showDebugPanel;

  /// Controller
  final PickerMapNativeController? controller;

  // ====== Compat (legado) ======
  @Deprecated('Compat apenas. Não é usado pelo nativo.')
  final List<dynamic> driversRefs;
  final int? refreshMs;

  final String? destinationMarkerPngUrl;
  final double? userMarkerSize;
  final double? driverIconWidth;
  final String? driverTaxiIconAsset;
  final String? driverDriverIconUrl;
  final String? driverTaxiIconUrl;
  final bool enableRouteSnake;
  final bool? liteModeOnAndroid;
  final bool? ultraLowSpecMode;
  final double? brandSafePaddingBottom;
  // =============================

  /// Estilo JSON do Google Maps (ex.: preto/cinza).
  final String? mapStyleJson;

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  static int _nextViewId = 1;

  MethodChannel? _channel;
  late final int _viewId;
  bool _platformReady = false;

  // memo pra evitar updates redundantes (que causam “flash”)
  ff.LatLng? _lastUser;
  ff.LatLng? _lastDest;
  String? _lastStyle;
  int? _lastRouteColor;
  int? _lastRouteWidth;

  final _ktLogs = <String>[];
  bool _logsVisible = false;

  @override
  void initState() {
    super.initState();
    _viewId = _nextViewId++;
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    widget.controller?._detach();
    super.dispose();
  }

  Map<String, dynamic> _buildConfig({required bool initial}) {
    final u = _safe(widget.userLocation);
    final d = (widget.destination != null) ? _safe(widget.destination!) : null;

    return {
      'userLocation': {'latitude': u.latitude, 'longitude': u.longitude},
      if (d != null) 'destination': {'latitude': d.latitude, 'longitude': d.longitude},
      'route': const <Map<String, double>>[],
      'routeColor': widget.routeColor.value,
      'routeWidth': widget.routeWidth,
      'userName': widget.userName,
      'userPhotoUrl': widget.userPhotoUrl,
      if (widget.mapStyleJson != null) 'mapStyleJson': widget.mapStyleJson,
      // compat (podem ser ignorados no nativo, mas não quebram)
      if (widget.refreshMs != null) 'refreshMs': widget.refreshMs,
      if (widget.destinationMarkerPngUrl != null)
        'destinationMarkerPngUrl': widget.destinationMarkerPngUrl,
      if (widget.userMarkerSize != null) 'userMarkerSize': widget.userMarkerSize,
      if (widget.driverIconWidth != null) 'driverIconWidth': widget.driverIconWidth,
      if (widget.driverTaxiIconAsset != null) 'driverTaxiIconAsset': widget.driverTaxiIconAsset,
      if (widget.driverDriverIconUrl != null) 'driverDriverIconUrl': widget.driverDriverIconUrl,
      if (widget.driverTaxiIconUrl != null) 'driverTaxiIconUrl': widget.driverTaxiIconUrl,
      'enableRouteSnake': widget.enableRouteSnake,
      if (widget.liteModeOnAndroid != null) 'liteModeOnAndroid': widget.liteModeOnAndroid,
      if (widget.ultraLowSpecMode != null) 'ultraLowSpecMode': widget.ultraLowSpecMode,
      // dica ao nativo: setar câmera logo após o primeiro update
      if (initial)
        'initialCamera': {
          'zoom': 15.5,
          'bearing': -18.0,
          'tilt': 48.0,
        },
    };
  }

  Future<void> _sendFullConfig({required bool initial}) async {
    if (_channel == null) return;
    final cfg = _buildConfig(initial: initial);
    await _channel!.invokeMethod('updateConfig', cfg);

    // memo
    _lastUser = _safe(widget.userLocation);
    _lastDest = widget.destination != null ? _safe(widget.destination!) : null;
    _lastStyle = widget.mapStyleJson;
    _lastRouteColor = widget.routeColor.value;
    _lastRouteWidth = widget.routeWidth;
  }

  @override
  void didUpdateWidget(covariant PickerMapNative oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_platformReady || _channel == null) return;

    final u = _safe(widget.userLocation);
    final d = widget.destination != null ? _safe(widget.destination!) : null;

    final styleChanged = widget.mapStyleJson != _lastStyle;
    final routeChanged =
        widget.routeColor.value != _lastRouteColor || widget.routeWidth != _lastRouteWidth;
    final userChanged = _lastUser == null || u.latitude != _lastUser!.latitude || u.longitude != _lastUser!.longitude;
    final destChanged = (_lastDest?.latitude != d?.latitude) || (_lastDest?.longitude != d?.longitude);

    if (styleChanged || routeChanged || destChanged) {
      _sendFullConfig(initial: false);
      return;
    }

    if (userChanged) {
      // move a câmera suavemente pro novo user (sem piscar)
      _channel!.invokeMethod('cameraTo', {
        'latitude': u.latitude,
        'longitude': u.longitude,
        'zoom': 15.5,
        'bearing': -18.0,
        'tilt': 48.0,
      });
      _lastUser = u;
    }
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _channel = MethodChannel('picker_map_native_$id');
    widget.controller?._attach(_channel!);

    _channel!.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'platformReady':
          _platformReady = true;
          await _sendFullConfig(initial: true);
          break;
        case 'debugLog':
          if (!widget.showDebugPanel) break;
          final m = (call.arguments as Map?) ?? const {};
          final level = (m['level'] ?? 'D').toString();
          final msg = (m['msg'] ?? '').toString();
          setState(() {
            _ktLogs.insert(0, '[$level] $msg');
            if (_ktLogs.length > 120) _ktLogs.removeLast();
          });
          break;
      }
      return null;
    });

    // Envia ao menos uma vez (se o nativo ainda não disparou platformReady)
    if (!_platformReady) {
      await _sendFullConfig(initial: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.maybeOf(context)?.padding.bottom ?? 0;
    final brandBottom = widget.brandSafePaddingBottom ?? 0;
    final outerPadding = EdgeInsets.fromLTRB(0, 0, 0, bottomSafe + brandBottom);

    final ff.LatLng initial = _safe(widget.userLocation);

    Widget platformView;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final controller = PlatformViewsService.initSurfaceAndroidView(
        id: _viewId,
        viewType: 'picker_map_native',
        layoutDirection: ui.TextDirection.ltr,
        creationParams: {
          'initialUserLocation': {
            'latitude': initial.latitude,
            'longitude': initial.longitude,
          },
          if (widget.mapStyleJson != null) 'mapStyleJson': widget.mapStyleJson,
          if (widget.refreshMs != null) 'refreshMs': widget.refreshMs,
          if (widget.liteModeOnAndroid != null) 'liteModeOnAndroid': widget.liteModeOnAndroid,
          if (widget.ultraLowSpecMode != null) 'ultraLowSpecMode': widget.ultraLowSpecMode,
        },
        creationParamsCodec: const StandardMessageCodec(),
      )
        ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
        ..create();

      platformView = ColoredBox( // evita “flash” branco por baixo
        color: Colors.black,
        child: AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: 'picker_map_native',
        creationParams: {
          'initialUserLocation': {
            'latitude': initial.latitude,
            'longitude': initial.longitude,
          },
          if (widget.mapStyleJson != null) 'mapStyleJson': widget.mapStyleJson,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return const Center(child: Text('PickerMapNative: plataforma não suportada'));
    }

    final Widget baseBox = SizedBox(
      width: widget.width,
      height: widget.height,
      child: platformView,
    );

    final Widget mapBoxPadded = Padding(padding: outerPadding, child: baseBox);

    final Widget mapBox = (defaultTargetPlatform == TargetPlatform.android)
        ? mapBoxPadded // sem ClipRRect no Android (evita “véu cinza”)
        : ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: mapBoxPadded,
          );

    if (!widget.showDebugPanel) return mapBox;

    final double topSafe = (MediaQuery.maybeOf(context)?.padding.top ?? 0) + 8;

    return Stack(
      children: [
        mapBox,
        Positioned(
          left: 8,
          top: topSafe,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => setState(() => _logsVisible = !_logsVisible),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text('LOGS', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ),
        ),
        if (_logsVisible)
          Positioned(
            left: 8,
            right: 8,
            bottom: 12 + brandBottom,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _ktLogs.length,
                    itemBuilder: (_, i) => Text(
                      _ktLogs[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Estilo preto/cinza sem azul
const String kGoogleMapsMonoBlackStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#111111"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#111111"}]},

  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#1a1a1a"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#141414"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#161616"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0d0d0d"}]},

  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#202020"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#2a2a2a"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
  {"featureType":"road","elementType":"labels.text.stroke","stylers":[{"color":"#0f0f0f"}]}
]
''';
