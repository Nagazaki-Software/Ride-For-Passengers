import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'switchsafetoolkit_model.dart';
export 'switchsafetoolkit_model.dart';

class SwitchsafetoolkitWidget extends StatefulWidget {
  const SwitchsafetoolkitWidget({
    super.key,
    bool? principal,
  }) : this.principal = principal ?? false;

  final bool principal;

  @override
  State<SwitchsafetoolkitWidget> createState() =>
      _SwitchsafetoolkitWidgetState();
}

class _SwitchsafetoolkitWidgetState extends State<SwitchsafetoolkitWidget> {
  late SwitchsafetoolkitModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SwitchsafetoolkitModel());

    _model.switchValue = false;
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _model.switchValue!,
      onChanged: (newValue) async {
        safeSetState(() => _model.switchValue = newValue);
      },
      activeColor: FlutterFlowTheme.of(context).accent1,
      activeTrackColor: Color(0xFF1B1B1C),
      inactiveTrackColor: Color(0xFF1B1B1C),
      inactiveThumbColor: FlutterFlowTheme.of(context).secondaryText,
    );
  }
}
