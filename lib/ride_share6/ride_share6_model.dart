import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'ride_share6_widget.dart' show RideShare6Widget;
import 'package:flutter/material.dart';

class RideShare6Model extends FlutterFlowModel<RideShare6Widget> {
  ///  Local state fields for this page.

  DocumentReference? session;

<<<<<<< HEAD
=======
  // Prevent duplicate navigations when session status changes.
  bool movedToPayment = false;

>>>>>>> master
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Create Document] action in Container widget.
  RideOrdersRecord? rideOrderQR;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
