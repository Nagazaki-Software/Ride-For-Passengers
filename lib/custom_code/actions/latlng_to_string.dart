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

import 'dart:convert';
import 'package:http/http.dart' as http;
import '/flutter_flow/lat_lng.dart';

/// Reverse geocode robusto:
/// - language: pt-BR
/// - filtra por street_address/route
/// - monta "Rua X, Bairro – Cidade/UF"
/// - logs úteis para 403/REQUEST_DENIED
Future<String> latlngToString(
  LatLng latlng,
  String apiKey,
) async {
  String _coordsFallback() =>
      '${latlng.latitude.toStringAsFixed(6)}, ${latlng.longitude.toStringAsFixed(6)}';

  try {
    final key = (apiKey).trim(); // String já é non-nullable no FF
    if (key.isEmpty) return _coordsFallback();

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=${latlng.latitude},${latlng.longitude}'
      '&language=en-US'
      '&key=$key',
    );

    // timeout pra evitar “nada acontece feijoada”
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));

    // Logs leves para depurar (apenas no debug)
    // ignore: avoid_print
    print('[latlngToString] HTTP ${resp.statusCode}');

    if (resp.statusCode == 403) {
      // ignore: avoid_print
      print(
          '[latlngToString] 403: verifique Billing e API restrictions (habilite Geocoding API para esta key). Body=${resp.body}');
      return _coordsFallback();
    }
    if (resp.statusCode != 200) return _coordsFallback();

    final data = json.decode(resp.body) as Map<String, dynamic>;
    final status = (data['status'] ?? '').toString();

    if (status == 'REQUEST_DENIED' || status == 'OVER_DAILY_LIMIT') {
      // ignore: avoid_print
      print(
          '[latlngToString] $status: confira faturamento e permissões da key. Body=${resp.body}');
      return _coordsFallback();
    }
    if (status != 'OK') {
      // ignore: avoid_print
      print('[latlngToString] status=$status (sem endereço).');
      return _coordsFallback();
    }

    final results = (data['results'] as List?) ?? const [];
    if (results.isEmpty) return _coordsFallback();

    // 1) tenta um resultado com tipo "street_address" ou "route"
    Map<String, dynamic>? best =
        results.cast<Map<String, dynamic>?>().firstWhere(
      (r) {
        final types = (r?['types'] as List?)?.cast<String>() ?? const [];
        return types.contains('street_address') || types.contains('route');
      },
      orElse: () => null,
    );

    // 2) se não achou, pega o primeiro mesmo
    best ??= results.first as Map<String, dynamic>;

    // Tenta formatted_address direto
    final formatted = best['formatted_address']?.toString();
    if (formatted != null && formatted.trim().isNotEmpty) {
      return formatted.trim();
    }

    // Monta manualmente: Rua, Bairro – Cidade/UF
    String? route,
        neighborhood,
        sublocality,
        locality,
        admin1Short; // UF/estado (short)

    final comps =
        (best['address_components'] as List?)?.cast<Map<String, dynamic>>() ??
            const [];

    String? _get(List<String> wanted, {bool short = false}) {
      for (final c in comps) {
        final types = (c['types'] as List?)?.cast<String>() ?? const [];
        if (types.any(wanted.contains)) {
          return short
              ? (c['short_name']?.toString())
              : (c['long_name']?.toString());
        }
      }
      return null;
    }

    route = _get(['route']);
    neighborhood = _get(['neighborhood']);
    sublocality = _get(['sublocality', 'sublocality_level_1']);
    locality = _get(['locality', 'postal_town']);
    admin1Short = _get(['administrative_area_level_1'], short: true);

    final bairro = (neighborhood ?? sublocality);
    final partes = <String>[];
    if (route != null && route!.trim().isNotEmpty) partes.add(route!.trim());
    if (bairro != null && bairro!.trim().isNotEmpty) partes.add(bairro!.trim());

    final cidadeUf = [
      if (locality != null && locality!.trim().isNotEmpty) locality!.trim(),
      if (admin1Short != null && admin1Short!.trim().isNotEmpty)
        admin1Short!.trim(),
    ].join('/');

    String montado;
    if (partes.isNotEmpty && cidadeUf.isNotEmpty) {
      montado = '${partes.join(', ')} – $cidadeUf';
    } else if (partes.isNotEmpty) {
      montado = partes.join(', ');
    } else if (cidadeUf.isNotEmpty) {
      montado = cidadeUf;
    } else {
      montado = _coordsFallback();
    }

    return montado;
  } catch (e) {
    // ignore: avoid_print
    print('[latlngToString] erro: $e');
    return _coordsFallback();
  }
}
