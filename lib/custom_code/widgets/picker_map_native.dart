// ignore_for_file: avoid_print
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart'; // PlatformViewHitTestBehavior
import 'package:ride_bahamas/flutter_flow/lat_lng.dart' as ff; // LatLng do FlutterFlow

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

  Future<void> cameraTo(double lat, double lng,
      {double? zoom, double? bearing, double? tilt}) async =>
      _channel?.invokeMethod('cameraTo', {
        'latitude': lat,
        'longitude': lng,
        if (zoom != null) 'zoom': zoom,
        if (bearing != null) 'bearing': bearing,
        if (tilt != null) 'tilt': tilt
      }) ?? Future.value();

  Future<void> fitBounds(List<ff.LatLng> pts, {double padding = 0}) async =>
      _channel?.invokeMethod('fitBounds', {
        'points': pts
            .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
            .toList(),
        'padding': padding,
      }) ?? Future.value();

  Future<void> updateCarPosition(String id, ff.LatLng pos,
          {double? rotation, int? durationMs}) async =>
      _channel?.invokeMethod('updateCarPosition', {
        'id': id,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        if (rotation != null) 'rotation': rotation,
        if (durationMs != null) 'durationMs': durationMs
      }) ?? Future.value();

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
    this.routeColor = const Color(0xFFFFC107),
    this.routeWidth = 4,
    this.showDebugPanel = true,
    this.controller,
    this.driversRefs = const [],
    this.refreshMs,
    this.destinationMarkerPngUrl,
    this.userMarkerSize,
    this.driverIconWidth,
    this.driverTaxiIconAsset,
    this.driverDriverIconUrl,
    this.driverTaxiIconUrl,
    this.enableRouteSnake = false,
    this.brandSafePaddingBottom,
    this.liteModeOnAndroid,
    this.ultraLowSpecMode,

    // NOVOS (opcionais)
    this.logPanelInitialHeight = 120,
    this.logPanelMaxHeightFraction = 0.45,
    this.logPanelBottomExtraPadding = 0,
  });

  final ff.LatLng userLocation;
  final ff.LatLng? destination;
  final String? userName;
  final String? userPhotoUrl;

  final double? width;
  final double height;
  final double borderRadius;
  final Color routeColor;
  final int routeWidth;
  final bool showDebugPanel;
  final PickerMapNativeController? controller;
  final List<dynamic> driversRefs;
  final int? refreshMs;
  final String? destinationMarkerPngUrl;
  final double? userMarkerSize;
  final double? driverIconWidth;
  final String? driverTaxiIconAsset;
  final String? driverDriverIconUrl;
  final String? driverTaxiIconUrl;
  final bool enableRouteSnake;
  final double? brandSafePaddingBottom; // já existia – ajuda a não sobrepor navbar própria do app
  final bool? liteModeOnAndroid;
  final bool? ultraLowSpecMode;

  // NOVOS parâmetros p/ painel de logs
  final double logPanelInitialHeight;         // altura inicial (px)
  final double logPanelMaxHeightFraction;     // fração da tela (0–1)
  final double logPanelBottomExtraPadding;    // padding extra no bottom (px) além do SafeArea/brandSafe

  @override
  State<PickerMapNative> createState() => _PickerMapNativeState();
}

class _PickerMapNativeState extends State<PickerMapNative> {
  MethodChannel? _channel;
  int? _viewId;

  final _ktLogs = <String>[];
  bool _logsVisible = true;
  bool _logsMinimized = false;
  double _logPanelHeight = 0;

  void _pushLog(String msg) {
    if (!mounted) return;
    setState(() {
      final ts = DateTime.now().toIso8601String().substring(11, 19);
      _ktLogs.insert(0, '[$ts] $msg');
      if (_ktLogs.length > 300) _ktLogs.removeLast();
    });
    print(msg);
  }

  @override
  void initState() {
    super.initState();
    _logPanelHeight = widget.logPanelInitialHeight.clamp(80, 260);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    widget.controller?._detach();
    super.dispose();
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _viewId = id;
    _channel = MethodChannel('picker_map_native_$id');
    _channel!.setMethodCallHandler(_handleCall);
    widget.controller?._attach(_channel!);

    await _channel!.invokeMethod('updateConfig', {
      'userLocation': {
        'latitude': widget.userLocation.latitude,
        'longitude': widget.userLocation.longitude,
      },
      if (widget.destination != null)
        'destination': {
          'latitude': widget.destination!.latitude,
          'longitude': widget.destination!.longitude,
        },
      'route': const <Map<String, double>>[],
      'routeColor': widget.routeColor.value,
      'routeWidth': widget.routeWidth,
      'userName': widget.userName,
      'userPhotoUrl': widget.userPhotoUrl,
    });
  }

  Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == 'platformReady') {
      _pushLog('KT → Dart: platformReady');
    } else if (call.method == 'debugLog') {
      final m = (call.arguments as Map?) ?? const {};
      final level = (m['level'] ?? 'D').toString();
      final msg = (m['msg'] ?? '').toString();
      _pushLog('[KT/$level] $msg');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const Center(child: Text('PickerMapNative: apenas Android'));
    }

    // ID único p/ evitar colisão de PlatformView em rebuilds
    final uniqueId = (hashCode ^ DateTime.now().microsecondsSinceEpoch) & 0x7fffffff;

    final controller = PlatformViewsService.initSurfaceAndroidView(
      id: uniqueId,
      viewType: 'picker_map_native',
      layoutDirection: ui.TextDirection.ltr,
      creationParams: {
        'initialUserLocation': {
          'latitude': widget.userLocation.latitude,
          'longitude': widget.userLocation.longitude,
        },
      },
      creationParamsCodec: const StandardMessageCodec(),
    )
      ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
      ..create();

    final androidView = AndroidViewSurface(
      controller: controller as AndroidViewController,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      hitTestBehavior: PlatformViewHitTestBehavior.opaque,
    );

    final mapBox = SizedBox(
      width: widget.width,
      height: widget.height,
      child: androidView,
    );

    if (!widget.showDebugPanel) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: mapBox,
      );
    }

    // Cálculo de paddings para não sobrepor navbar/chat
    final mq = MediaQuery.of(context);
    final safeBottom = mq.padding.bottom; // system nav/gesture area
    final brandPad = widget.brandSafePaddingBottom ?? 0;
    final extra = widget.logPanelBottomExtraPadding;
    final bottomPad = (safeBottom + brandPad + extra).clamp(0, 200).toDouble();

    // Altura máxima da folha de logs – fração da tela
    final maxLogH = (mq.size.height * widget.logPanelMaxHeightFraction)
        .clamp(120, 420)
        .toDouble();

    final panelHeight = _logsMinimized ? 38.0 : _logPanelHeight.clamp(80.0, maxLogH);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: mapBox,
        ),

        // Toggle: mostrar/ocultar painel inteiro (não confundir com minimizar)
        Positioned(
          left: 8,
          top: 8 + mq.padding.top, // respeita status bar
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => setState(() => _logsVisible = !_logsVisible),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  _logsVisible ? 'Ocultar debug' : 'Mostrar debug',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),

        if (_logsVisible)
          // Painel de logs estilo mini bottom-sheet
          Positioned(
            left: 8,
            right: 8,
            bottom: 8 + bottomPad,
            child: _LogPanel(
              height: panelHeight,
              minimized: _logsMinimized,
              onDragDelta: (dy) {
                // arrasta por cima/baixo pra redimensionar
                setState(() {
                  _logPanelHeight = (_logPanelHeight - dy).clamp(80.0, maxLogH);
                });
              },
              onToggleMinimize: () => setState(() => _logsMinimized = !_logsMinimized),
              onClear: () => setState(_ktLogs.clear),
              onCopyAll: () {
                Clipboard.setData(ClipboardData(text: _ktLogs.reversed.join('\n')));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logs copiados')),
                );
              },
              child: ListView.builder(
                key: const PageStorageKey('picker_map_logs'),
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                itemCount: _ktLogs.length,
                itemBuilder: (_, i) => Text(
                  _ktLogs[i],
                  maxLines: 2, // lista mais "curta" por item
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 11, // diminui tipografia
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget do painel de logs (cabeçalho com ações + área rolável)
class _LogPanel extends StatelessWidget {
  const _LogPanel({
    required this.height,
    required this.child,
    required this.minimized,
    required this.onDragDelta,
    required this.onToggleMinimize,
    required this.onClear,
    required this.onCopyAll,
  });

  final double height;
  final Widget child;
  final bool minimized;
  final void Function(double dy) onDragDelta;
  final VoidCallback onToggleMinimize;
  final VoidCallback onClear;
  final VoidCallback onCopyAll;

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(10);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(minimized ? 0.45 : 0.72),
        borderRadius: border,
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Colors.black54, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: border,
        child: Column(
          children: [
            // Header com "drag handle" + ações
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) => onDragDelta(d.delta.dy),
              child: Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF222222), Color(0xFF1A1A1A)],
                  ),
                ),
                child: Row(
                  children: [
                    // drag handle
                    Container(
                      width: 36,
                      alignment: Alignment.center,
                      child: Container(
                        width: 24, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Logs',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    // ações
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: minimized ? 'Expandir' : 'Minimizar',
                      iconSize: 18,
                      color: Colors.white70,
                      onPressed: onToggleMinimize,
                      icon: Icon(minimized ? Icons.unfold_more : Icons.unfold_less),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Copiar tudo',
                      iconSize: 18,
                      color: Colors.white70,
                      onPressed: onCopyAll,
                      icon: const Icon(Icons.copy_all),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Limpar',
                      iconSize: 18,
                      color: Colors.white70,
                      onPressed: onClear,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),

            // Lista – some quando minimizado
            if (!minimized)
              Expanded(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                  child: child,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
