// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';

import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '/flutter_flow/lat_lng.dart';

class RouteListItem extends StatefulWidget {
  const RouteListItem({
    super.key,
    // required
    required this.origem,
    required this.destino,
    required this.startedAt,
    required this.durationMinutes,
    required this.price,
    required this.hasReceipt,
    required this.width,
    required this.height, // não fixamos a altura, só passamos pro FF
    // optional
    this.currencySymbol = '\$',
    this.dayLocale = 'en',
    this.backgroundColor = const Color(0xFF27292E),
    this.mutedTextColor = const Color(0xFF9AA0A6),
    this.titleColor = Colors.white,
    this.priceColor = Colors.white,
    this.receiptOnColor = const Color(0xFF3A3F45),
    this.receiptOffColor = const Color(0xFF2F3338),
    this.borderRadius = 16,
    this.padding = 14,
  });

  final LatLng origem;
  final LatLng destino;
  final DateTime startedAt;
  final int durationMinutes;
  final double price;
  final bool hasReceipt;

  final String currencySymbol;
  final String dayLocale;
  final Color backgroundColor;
  final Color mutedTextColor;
  final Color titleColor;
  final Color priceColor;
  final Color receiptOnColor;
  final Color receiptOffColor;
  final double borderRadius;
  final double padding;

  final double width;
  final double height;

  @override
  State<RouteListItem> createState() => _RouteListItemState();
}

class _RouteListItemState extends State<RouteListItem> {
  static final Map<String, String> _geoCache = {};
  late Future<_UiData> _dataFuture;

  // rótulo instantâneo (lat,lng → lat,lng) enquanto resolve
  late final String _instantLabel =
      '${_fmtLatLng(widget.origem)} → ${_fmtLatLng(widget.destino)}';

  @override
  void initState() {
    super.initState();
    _dataFuture = _buildUiData();
  }

  @override
  void didUpdateWidget(covariant RouteListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.origem != widget.origem ||
        oldWidget.destino != widget.destino ||
        oldWidget.startedAt != widget.startedAt ||
        oldWidget.durationMinutes != widget.durationMinutes ||
        oldWidget.price != widget.price ||
        oldWidget.hasReceipt != widget.hasReceipt ||
        oldWidget.currencySymbol != widget.currencySymbol ||
        oldWidget.dayLocale != widget.dayLocale ||
        oldWidget.width != widget.width) {
      _dataFuture = _buildUiData();
      setState(() {});
    }
  }

  static String _key(LatLng ll) =>
      '${ll.latitude.toStringAsFixed(5)},${ll.longitude.toStringAsFixed(5)}';

  static String _fmtLatLng(LatLng ll) =>
      '${ll.latitude.toStringAsFixed(5)}, ${ll.longitude.toStringAsFixed(5)}';

  // agora aceita null e devolve string vazia
  static String _stripParens(String? s) =>
      (s ?? '').replaceAll(RegExp(r'\s*\(.*?\)'), '').trim();

  // Reverse geocoding via Nominatim (Web-friendly) com timeout curto
  Future<String> _reverseGeocode(LatLng ll) async {
    final k = _key(ll);
    final cached = _geoCache[k];
    if (cached != null) return cached;

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=jsonv2&lat=${ll.latitude}&lon=${ll.longitude}&addressdetails=1',
    );

    try {
      final resp = await http.get(
        uri,
        headers: {
          'User-Agent': 'QuickySolutionsApp/1.0 (contact@example.com)',
          'Accept-Language': 'pt,en',
        },
      ).timeout(const Duration(seconds: 3));

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final addr = (data['address'] ?? {}) as Map<String, dynamic>;

        String join(List<String?> xs) =>
            xs.where((e) => e != null && e!.trim().isNotEmpty).join(', ');

        final road = addr['road'] as String?;
        final neighbourhood = addr['neighbourhood'] as String?;
        final suburb = addr['suburb'] as String?;
        final city = addr['city'] as String? ??
            addr['town'] as String? ??
            addr['village'] as String? ??
            addr['municipality'] as String?;
        final island = addr['island'] as String?;
        final state = addr['state'] as String?;
        final name = data['name'] as String?;

        final candidates = <String>[
          _stripParens(road), // "Bay Street"
          _stripParens(
              join([road, neighbourhood ?? suburb])), // "Bay Street, Centro"
          _stripParens(island ?? city), // "Paradise Island" ou "Nassau"
          _stripParens(join([city, state])),
          _stripParens(name),
          _stripParens(state),
        ];

        final chosen = candidates.firstWhere(
          (e) => e.isNotEmpty,
          orElse: () => _fmtLatLng(ll),
        );
        _geoCache[k] = chosen;
        return chosen;
      }
    } catch (_) {
      // timeout/erro -> fallback
    }

    final fb = _fmtLatLng(ll);
    _geoCache[k] = fb;
    return fb;
  }

  // Distância Haversine (km)
  double _haversineKm(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final la1 = _deg2rad(a.latitude);
    final la2 = _deg2rad(b.latitude);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return R * c;
  }

  double _deg2rad(double d) => d * math.pi / 180.0;

  Future<_UiData> _buildUiData() async {
    // geocode em paralelo
    final results = await Future.wait<String>([
      _reverseGeocode(widget.origem),
      _reverseGeocode(widget.destino),
    ]);

    final origemName = results[0];
    final destinoName = results[1];
    final routeLabel = '$origemName → $destinoName';

    final dayFmt = DateFormat.E(widget.dayLocale);
    final dayStr = dayFmt.format(widget.startedAt);

    final distKm = _haversineKm(widget.origem, widget.destino);
    final mins = widget.durationMinutes;

    final priceFmt = NumberFormat.currency(
      symbol: widget.currencySymbol,
      decimalDigits: 2,
    );
    final priceStr = priceFmt.format(widget.price);

    final meta = '$dayStr • ${distKm.toStringAsFixed(1)} km • $mins min';

    return _UiData(routeLabel: routeLabel, meta: meta, price: priceStr);
  }

  @override
  Widget build(BuildContext context) {
    final base = FlutterFlowTheme.of(context);

    return FutureBuilder<_UiData>(
      future: _dataFuture,
      builder: (context, snap) {
        final loading = !snap.hasData;
        final data = snap.data;

        return SizedBox(
          width: widget.width,
          child: Container(
            padding: EdgeInsets.all(widget.padding),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        loading ? _instantLabel : data!.routeLabel,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: (base.bodyMedium ?? const TextStyle()).copyWith(
                          color: widget.titleColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          loading ? '${widget.currencySymbol} --' : data!.price,
                          style:
                              (base.bodyMedium ?? const TextStyle()).copyWith(
                            color: widget.priceColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.hasReceipt
                                ? widget.receiptOnColor
                                : widget.receiptOffColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Receipt',
                            style:
                                (base.bodySmall ?? const TextStyle()).copyWith(
                              color: widget.mutedTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    loading ? '--- • --.- km • -- min' : data!.meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (base.bodySmall ?? const TextStyle()).copyWith(
                      color: widget.mutedTextColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UiData {
  _UiData({required this.routeLabel, required this.meta, required this.price});
  final String routeLabel;
  final String meta;
  final String price;
}
