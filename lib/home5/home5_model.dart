import '/backend/backend.dart';
import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home5_widget.dart' show Home5Widget;
import 'package:flutter/material.dart';

class Home5Model extends FlutterFlowModel<Home5Widget> {
  ///  Local state fields for this page.

  String rideChoose = 'ride';

  bool rideForConfirm = false;

  LatLng? location;

  LatLng? locationAtual;

  String? perto;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - googlePlacesNearbyImportant] action in Home5 widget.
  List<dynamic>? locationPerto;
  // Stores action output result for [Custom Action - localGreetingAction] action in Home5 widget.
  String? fraseInicial;
  // Stores action output result for [Custom Action - geocodeAddress] action in Container widget.
  dynamic geolocatoraddressonchoose;
  DateTime? datePicked;
  // Stores action output result for [Firestore Query - Query a collection] action in ContainerConfirmRide widget.
  List<RideOrdersRecord>? order;
  // Model for navbar component.
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel.dispose();
  }
}
