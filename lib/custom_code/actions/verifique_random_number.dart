// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math'; // <— precisamos disso

/// Gera um código aleatório tipo "XK23FG" e garante que seja único.
///
/// Troque [fieldName] pelo nome do campo em `users` onde você salva o código.
Future<String> verifiqueRandomNumber(List<UsersRecord> users) async {
  const String fieldName =
      'randomCode'; // <<--- ajuste aqui se o campo tiver outro nome
  const int length = 6;
  const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final Random rng = Random.secure();

  String _geraCodigo() =>
      List.generate(length, (_) => alphabet[rng.nextInt(alphabet.length)])
          .join();

  Future<bool> _jaExisteNoFirestore(String code) async {
    // Busca 1 usuário com o mesmo código. Se achar, já era.
    final hit = await queryUsersRecordOnce(
      queryBuilder: (q) => q.where(fieldName, isEqualTo: code),
      limit: 1,
    );
    return hit.isNotEmpty;
  }

  // Tenta várias vezes até achar um que não exista.
  for (int attempt = 0; attempt < 5000; attempt++) {
    final code = _geraCodigo();
    final existe = await _jaExisteNoFirestore(code);
    if (!existe) {
      return code; // sucesso: retorna para o fluxo do app
    }
  }

  // Se chegou aqui, algo está muito improvável (muitos conflitos).
  throw Exception(
      'Não foi possível gerar um código único agora. Tente novamente.');
}
