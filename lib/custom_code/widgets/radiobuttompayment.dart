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

class Radiobuttompayment extends StatefulWidget {
  const Radiobuttompayment({
    super.key,
    this.width,
    this.height,
    this.selected = false,
  });

  final double? width;
  final double? height;
  final bool selected;

  @override
  State<Radiobuttompayment> createState() => _RadiobuttompaymentState();
}

class _RadiobuttompaymentState extends State<Radiobuttompayment> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width ?? 24.0;
    final h = widget.height ?? 24.0;

    return GestureDetector(
      onTap: () => setState(() => isSelected = !isSelected),
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: Center(
          child: isSelected
              ? Container(
                  width: w * 0.5,
                  height: h * 0.5,
                  decoration: const BoxDecoration(
                    color: Colors.amber, // centro amarelo
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
