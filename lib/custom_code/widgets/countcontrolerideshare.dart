// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class Countcontrolerideshare extends StatefulWidget {
  const Countcontrolerideshare({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<Countcontrolerideshare> createState() => _CountcontrolerideshareState();
}

class _CountcontrolerideshareState extends State<Countcontrolerideshare> {
  int _count = 1;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: widget.width ?? 120,
      height: widget.height ?? 32,
      decoration: BoxDecoration(
        color: theme.primaryText,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Color(0x22000000), offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            Icons.remove_rounded,
            onTap: () {
              if (_count > 0) setState(() => _count--);
            },
          ),
          SizedBox(
            width: 38,
            child: Center(
              child: Text(
                '$_count',
                style: theme.bodyMedium.override(
                  font: GoogleFonts.poppins(),
                  color: theme.alternate,
                  fontSize: 14,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w700,
                  fontStyle: theme.bodyMedium.fontStyle,
                ),
              ),
            ),
          ),
          _buildButton(
            Icons.add_rounded,
            onTap: () => setState(() => _count++),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, {required VoidCallback onTap}) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        width: 34,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xA5414141),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: theme.secondaryText),
      ),
    );
  }
}
