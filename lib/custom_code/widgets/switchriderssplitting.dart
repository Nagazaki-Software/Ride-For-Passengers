// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class Switchriderssplitting extends StatefulWidget {
  const Switchriderssplitting({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<Switchriderssplitting> createState() => _SwitchriderssplittingState();
}

class _SwitchriderssplittingState extends State<Switchriderssplitting> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isOn = !_isOn;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.width ?? 60,
        height: widget.height ?? 30,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: _isOn ? Colors.green : const Color(0xFF1A1A1A), // fundo ON/OFF
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: _isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isOn ? Colors.white : Colors.black87, // bolinha
            ),
          ),
        ),
      ),
    );
  }
}
