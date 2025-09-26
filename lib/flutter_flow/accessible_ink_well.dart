import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../services/tts_service.dart';

class AccessibleInkWell extends StatelessWidget {
  const AccessibleInkWell({
    super.key,
    this.splashColor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onTapCancel,
    this.onTapDown,
    this.mouseCursor,
    this.borderRadius,
    this.customBorder,
    this.focusNode,
    this.canRequestFocus = true,
    this.autofocus = false,
    this.enableFeedback,
    this.excludeFromSemantics = false,
    this.splashFactory,
    required this.child,
    this.announceLabel,
  });

  final Color? splashColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCancelCallback? onTapCancel;
  final GestureTapDownCallback? onTapDown;
  final MouseCursor? mouseCursor;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final FocusNode? focusNode;
  final bool canRequestFocus;
  final bool autofocus;
  final bool? enableFeedback;
  final bool excludeFromSemantics;
  final InteractiveInkFeatureFactory? splashFactory;
  final Widget child;
  final String? announceLabel;

  void _announce(BuildContext context) {
    final label = announceLabel ?? _deriveLabelFromChild();
    if (label != null && label.isNotEmpty) {
      TtsService.instance.announceAction(label, context: context);
    }
  }

  String? _deriveLabelFromChild() {
    if (child is Text) {
      final t = child as Text;
      return t.data;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      splashColor: splashColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      mouseCursor: mouseCursor,
      borderRadius: borderRadius,
      customBorder: customBorder,
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      autofocus: autofocus,
      enableFeedback: enableFeedback,
      excludeFromSemantics: excludeFromSemantics,
      splashFactory: splashFactory,
      onTapDown: (details) {
        onTapDown?.call(details);
      },
      onTapCancel: () {
        onTapCancel?.call();
      },
      onLongPress: () {
        _announce(context);
        onLongPress?.call();
      },
      onDoubleTap: () {
        _announce(context);
        onDoubleTap?.call();
      },
      onTap: () {
        _announce(context);
        // Fire original tap handler
        onTap?.call();
      },
      child: child,
    );
    if ((announceLabel ?? _deriveLabelFromChild()) != null) {
      return Semantics(
        label: announceLabel ?? _deriveLabelFromChild(),
        button: true,
        child: content,
      );
    }
    return content;
  }
}
