import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:push_sale/models/client.dart';

class PositionController extends GetxController {
  CameraPosition? initialPos;
  Position? mycurrentPosition;
  String selectedPOS = "";
  List<Client> clients = [];

  Set<Marker> pos = {};
  RxBool ready = false.obs;
  RxBool showHeader = false.obs;
  RxBool readyPolyline = false.obs;

  Set<Polyline> mypolylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];

  String filter = "";
  int filterTPV = 0;
  int filterCity = 0;
  setPolylines(PointLatLng dest) async {
    PointLatLng source =
        PointLatLng(mycurrentPosition!.latitude, mycurrentPosition!.longitude);
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        googleApiKey: "AIzaSyDPXVs2cyNHYOP-CXCS_SzcLWXgAzkb6GM",
        request: PolylineRequest(
            mode: TravelMode.driving, origin: source, destination: dest));
    if (result.status == "OK") {
      result.points.forEach((element) {
        polylineCoordinates.add(LatLng(element.latitude, element.longitude));
      });
    }
    mypolylines.add(Polyline(
        width: 10,
        polylineId: PolylineId("polyline"),
        color: Colors.green,
        points: polylineCoordinates));
  }

  void loadPOS() async {
    pos = {};
    ready.value = false;
    for (Client client in clients
        .where((element) => element.name.contains(filter))
        .toList()
        .where((element) =>
            filterCity == 0 || element.address!.city.id == filterCity)
        .toList()
        .where((element) => filterTPV == 0 || element.typepv!.id == filterTPV)
        .toList()) {
      Marker pos1 = Marker(
          markerId: MarkerId(client.code),
          position: LatLng(client.address!.latitude, client.address!.longitude),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            {}
          });
      pos.add(pos1);
    }
    ready.value = true;
  }

  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<String> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    // return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    return ' ${place.locality}, ${place.postalCode}, ${place.country}';
  }

  double DistanceBetweenPositions(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(pos1.altitude, pos1.longitude,
        pos2.altitude, pos2.longitude); //distance en metre
  }

  Future<void> loadPositionPage() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      mycurrentPosition = await getLocation();
      initialPos = CameraPosition(
        target:
            LatLng(mycurrentPosition!.latitude, mycurrentPosition!.longitude),
        zoom: 11,
      );
      loadPOS();
    } else {
      initialPos = CameraPosition(
        target: LatLng(36.693672548327164, 3.073091941698789),
        zoom: 11,
      );
    }
  }

  @override
  void onInit() {
    loadPositionPage();
    super.onInit();
  }
}
