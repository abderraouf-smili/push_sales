import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
// import 'package:latlong2/latlong.dart' as lat2;
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/controllers/order_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/purchase_order.dart';
import 'package:push_sale/models/route_maps.dart';

class MyLocalisation {
  //
  //

  static Future<Position> getMyLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // return from google map direction

  static Future<dynamic> getRouteOptimale(List<String> waypoints) async {
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
            'origin=${waypoints.first}'
            '&destination=${waypoints.last}'
            '&waypoints=optimize:true|${waypoints.sublist(1, waypoints.length - 1).join('|')}' // Exclut la première et la dernière position
            '&key=' +
        global.maps_key;
    var response = await Dio().get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = response.data;
      // Traitez les données de la réponse pour obtenir les instructions, la distance, le temps, etc.
      return data;
    } else {
      // Gérez les erreurs de la requête
      return null;
    }
  }

  static Future<Set<Marker>> loadPOS(
      List<Client> clients, OrderController orderController) async {
    Uint8List markIcons = await getImages("assets/images/order.png", 120);
    Set<Marker> pos = {};
    for (var client in clients) {
      Marker _marker = Marker(
          markerId: MarkerId(client.code),
          position: LatLng(client.address!.latitude, client.address!.longitude),
          icon: BitmapDescriptor.fromBytes(markIcons),
          onTap: () {
            {
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: Get.context!,
                  builder: (context) {
                    var formatter = new NumberFormat("#,##0.00", "fr_FR");
                    List<PurchaseOrder> _orders = orderController.shippingOrders
                        .where((element) => element.client!.id == client.id)
                        .toList();
                    return Container(
                      height: (_orders.length * 75 >= Get.height / 3 - 45
                              ? Get.height / 3 - 45
                              : _orders.length * 75) +
                          120,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 2, vertical: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue,
                            ),
                            height: 50,
                            child: Center(
                              child: Text(
                                client.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: (_orders.length * 75 >= Get.height / 3 - 45
                                ? Get.height / 3 - 45
                                : _orders.length * 75), //,
                            child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  var item = _orders[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // if (item.state != "paid") {
                                      orderController.selectedPO = item;
                                      orderController.pageController!
                                          .animateToPage(
                                              1,
                                              duration:
                                                  Duration(milliseconds: 250),
                                              curve: Curves.linear);

                                      // }
                                      Get.back();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 2, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color:
                                            Color.fromARGB(255, 216, 216, 216),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          item.code,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        leading: Container(
                                            width: 50,
                                            height: 50,
                                            child: item.state == "paid"
                                                ? Image.asset(
                                                    "assets/images/paid.png",
                                                    width: 20,
                                                  )
                                                : Icon(
                                                    Icons
                                                        .local_shipping_outlined,
                                                    color: Colors.green,
                                                    size: 30,
                                                  )),
                                        trailing: Text(
                                          formatter.format(item.residual),
                                          style: TextStyle(
                                            fontFamily: 'alata',
                                            fontSize: 18,
                                          ),
                                        ),
                                        subtitle:
                                            Text(item.purchase_date.toString()),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              height: 55,
                              width: Get.width,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromARGB(255, 216, 216, 216),
                              ),
                              child: Center(
                                child: Text(
                                  "cancel".tr,
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  });
            }
          });
      pos.add(_marker);
    }
    return pos;
  }

// A supprimer cette fonction et remplacer son resultat par la fonction prececdente
  static List<RouteMaps> getRouteBetweenPoints(dynamic value) {
    List<RouteMaps> _routes = [];
    List<LatLng> polylineCoordinates = [];
    // parcours de toutes l'itinéraire à découper pour chaque leg
    for (var leg in value["routes"][0]["legs"]) {
      int distance = leg["distance"]["value"] as int;
      int time = leg["duration"]["value"] as int;
      String start_address = leg["start_address"];
      String end_address = leg["end_address"];
      polylineCoordinates = [];
      for (var coord in leg["steps"]) {
        String encodedPolyline = coord["polyline"]["points"];
        List<PointLatLng> decodedPolyline =
            PolylinePoints().decodePolyline(encodedPolyline);
        for (PointLatLng point in decodedPolyline) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
      Set<Polyline> mypolylines = Set<Polyline>();
      mypolylines.add(Polyline(
          width: 2,
          polylineId: PolylineId("polyline"),
          color: Colors.blue,
          points: polylineCoordinates));
      _routes.add(RouteMaps(
        startAdress: start_address,
        endAdress: end_address,
        distance: distance,
        time: time,
        Polylines: mypolylines,
      ));
    }

    return _routes;
  }

  static Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
