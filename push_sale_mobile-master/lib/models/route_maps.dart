import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteMaps {
  final String startAdress;
  final String endAdress;
  final int distance;
  final int time;
  final Set<Polyline> Polylines;
  RouteMaps({
    required this.startAdress,
    required this.endAdress,
    required this.distance,
    required this.time,
    required this.Polylines,
  });

  String getStartAdress() {
    int startIndex = startAdress.indexOf(', ') + 2;
    return startAdress.substring(startIndex);
  }

  String getEndAdress() {
    int startIndex = endAdress.indexOf(', ') + 2;
    return endAdress.substring(startIndex);
  }
}
