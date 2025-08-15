// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class Botaoswitch extends StatefulWidget {
  const Botaoswitch({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<Botaoswitch> createState() => _BotaoswitchState();
}

class _BotaoswitchState extends State<Botaoswitch> {
  bool _isOn = true; // Começa igual à imagem

  @override
  Widget build(BuildContext context) {
    final double h = (widget.height ?? 36).clamp(28.0, 100.0);
    final double w = widget.width ?? (h * 2.2);
    final Color darkBg = const Color(0xFF212121);
    final Color knobYellow = const Color(0xFFF2C200); // amarelo próximo da foto
    final Color textYellow = knobYellow;

    return GestureDetector(
      onTap: () => setState(() => _isOn = !_isOn),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: w,
        height: h,
        padding: EdgeInsets.all(h * 0.12),
        decoration: BoxDecoration(
          color: darkBg,
          borderRadius: BorderRadius.circular(h),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Texto ON/OFF (fica alinhado à direita igual à foto)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(right: h * 0.35),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _isOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: h * 0.42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: _isOn ? textYellow : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
            // Bolinha deslizante
            AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: _isOn ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: h * 0.76,
                height: h * 0.76,
                decoration: BoxDecoration(
                  color: _isOn ? knobYellow : Colors.grey.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: h * 0.12,
                      spreadRadius: 0,
                      offset: Offset(0, h * 0.02),
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
