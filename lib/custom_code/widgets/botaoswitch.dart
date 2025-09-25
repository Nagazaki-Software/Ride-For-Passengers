// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class Botaoswitch extends StatefulWidget {
  const Botaoswitch({
    super.key,
    this.width,
    this.height,
    this.labelOn = 'ON',
    this.labelOff = 'OFF',
    this.initialValue = true,
    this.onChange, // agora opcional
  });

  final double? width;
  final double? height;

  final String labelOn;
  final String labelOff;
  final bool initialValue;

  final Future Function(bool onSelected)? onChange;

  @override
  State<Botaoswitch> createState() => _BotaoswitchState();
}

class _BotaoswitchState extends State<Botaoswitch> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.initialValue;
  }

  void _toggle() {
    setState(() => _isOn = !_isOn);
    // notificar mudança
    widget.onChange?.call(_isOn);
  }

  @override
  Widget build(BuildContext context) {
    final double h = (widget.height ?? 36).clamp(28.0, 100.0).toDouble();
    final double minW = h * 2.0;
    final double w = (widget.width ?? (h * 2.6)).clamp(minW, 1000.0).toDouble();

    const Color darkBg = Color(0xFF212121);
    const Color knobYellow = Color(0xFFF2C200);
    const Color textOn = knobYellow;
    final Color textOff = Colors.white54;

    final double radius = h;
    final double pad = h * 0.12;
    final double knobSize = h * 0.76;
    final double gap = h * 0.08;

    final double innerW = (w - pad * 2).clamp(0.0, w);
    final double desiredLabelW = (h * 1.7);
    final double labelMax = (innerW - (gap + knobSize)).clamp(0.0, innerW);
    final double labelWidth = desiredLabelW.clamp(0.0, labelMax);

    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: darkBg,
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: EdgeInsets.all(pad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double trackWidth = (constraints.maxWidth - gap)
                      .clamp(0.0, constraints.maxWidth);

                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      SizedBox(
                        width: trackWidth,
                        height: constraints.maxHeight,
                      ),
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        alignment: _isOn
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                            width: knobSize,
                            height: knobSize,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _isOn ? knobYellow : Colors.grey.shade400,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: h * 0.12,
                                  offset: Offset(0, h * 0.02),
                                  color: Colors.black.withOpacity(0.35),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(width: gap),
            SizedBox(
              width: labelWidth,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  style: TextStyle(
                    fontSize: h * 0.42,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: _isOn ? textOn : textOff,
                  ),
                  child: Text(
                    _isOn ? widget.labelOn : widget.labelOff,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
