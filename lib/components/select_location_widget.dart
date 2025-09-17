import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
<<<<<<< HEAD
<<<<<<< HEAD
import '/flutter_flow/custom_functions.dart' as functions;
=======
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'select_location_model.dart';
export 'select_location_model.dart';

class SelectLocationWidget extends StatefulWidget {
  const SelectLocationWidget({
    super.key,
    required this.escolha,
  });

  final String? escolha;

  @override
  State<SelectLocationWidget> createState() => _SelectLocationWidgetState();
}

class _SelectLocationWidgetState extends State<SelectLocationWidget> {
  late SelectLocationModel _model;

  LatLng? currentUserLocationValue;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelectLocationModel());

    getCurrentUserLocation(defaultLocation: LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: SpinKitDoubleBounce(
              color: FlutterFlowTheme.of(context).accent1,
              size: 50.0,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.8,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height * 0.4,
        child: custom_widgets.AddressPicker(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.4,
          googleApiKey: 'AIzaSyCFBfcNHFg97sM7EhKnAP4OHIoY3Q8Y_xQ',
          country: 'us',
          initialDestination: 'Where to?',
          title: 'Select Location',
          confirmText: 'Confirm',
          countriesCsv: 'bs, br, us',
          language: 'en',
          latlngUser: currentUserLocationValue,
          quickPicksDefaultToDestination: true,
          onConfirm: (result) async {
            _model.jsonAddresss = result;
<<<<<<< HEAD
<<<<<<< HEAD
            safeSetState(() {});
            FFAppState().latlngAtual = functions.stringToLatlng('${getJsonField(
              result,
              r'''$.pickupLat''',
            ).toString()}, ${getJsonField(
              result,
              r'''$.pickupLng''',
            ).toString()}');
            FFAppState().latlangAondeVaiIr =
                functions.stringToLatlng('${getJsonField(
              result,
              r'''$.destinationLat''',
            ).toString()}, ${getJsonField(
              result,
              r'''$.destinationLng''',
            ).toString()}');
            FFAppState().locationWhereTo = getJsonField(
              result,
              r'''$.destinationMainText''',
            ).toString();
            safeSetState(() {});
            Navigator.pop(context);
=======
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
            // Extrai coordenadas como double e monta LatLng diretamente
            final double? pLat =
                (getJsonField(result, r'$.pickupLat') as num?)?.toDouble();
            final double? pLng =
                (getJsonField(result, r'$.pickupLng') as num?)?.toDouble();
            final double? dLat =
                (getJsonField(result, r'$.destinationLat') as num?)?.toDouble();
            final double? dLng =
                (getJsonField(result, r'$.destinationLng') as num?)?.toDouble();

            final LatLng? origem =
                (pLat != null && pLng != null) ? LatLng(pLat, pLng) : null;
            final LatLng? destino =
                (dLat != null && dLng != null) ? LatLng(dLat, dLng) : null;

            // Atualiza o AppState e notifica listeners
            FFAppState().latlngAtual = origem ?? FFAppState().latlngAtual;
            FFAppState().latlangAondeVaiIr =
                destino ?? FFAppState().latlangAondeVaiIr;
            FFAppState().locationWhereTo = getJsonField(
              result,
              r'$.destinationMainText',
            ).toString();
            FFAppState().update(() {});

            if (mounted) Navigator.pop(context);
<<<<<<< HEAD
>>>>>>> 10c9b5c (new frkdfm)
=======
>>>>>>> 10c9b5c9503d954411773ec70615ce97229cb3be
          },
        ),
      ),
    );
  }
}
