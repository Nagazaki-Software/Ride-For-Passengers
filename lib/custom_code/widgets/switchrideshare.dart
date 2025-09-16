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

class Switchrideshare extends StatefulWidget {
  const Switchrideshare({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<Switchrideshare> createState() => _SwitchrideshareState();
}

class _SwitchrideshareState extends State<Switchrideshare> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 60,
      height: widget.height ?? 30,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Switch(
          value: _isOn,
          onChanged: (value) {
            setState(() {
              _isOn = value;
            });
          },
          activeColor: Colors.white, // Cor do círculo quando ativo
          activeTrackColor: Colors.green, // Cor da faixa ativa
          inactiveThumbColor: Colors.black, // Cor do círculo inativo
          inactiveTrackColor: Colors.white, // Cor da faixa inativa
        ),
      ),
    );
  }
}
