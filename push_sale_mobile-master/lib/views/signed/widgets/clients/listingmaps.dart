import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/controllers/filter_controller.dart';
import 'package:push_sale/controllers/position_controller.dart';
import 'package:push_sale/models/client.dart';

class ListingMaps extends StatelessWidget {
  final List<Client> listing;
  String filter;
  int filterCity;
  int filterTPV;
  ListingMaps(
    this.listing, {
    this.filter = "",
    this.filterTPV = 0,
    this.filterCity = 0,
  });
  PositionController posController = Get.find();
  ClientController clientController = Get.find();
  FilterController filterController = Get.find();
  @override
  Widget build(BuildContext context) {
    // posController.readyPolyline.value = false;
    posController.clients = listing
        .where((element) => element.name.contains(clientController.filter))
        .toList()
        .where((element) =>
            filterController.selectedCity.value == 0 ||
            element.address!.city.id == filterController.selectedCity.value)
        .toList()
        .where((element) =>
            filterController.selectedTPV.value == 0 ||
            element.typepv!.id == filterController.selectedTPV.value)
        .toList()
        .where((element) =>
            element.visitdays != null &&
                element.visitdays!
                    .where((item) =>
                        item.day ==
                        DateFormat("EEEE").format(DateTime.now()).toLowerCase())
                    .isNotEmpty ||
            !clientController.visit_day_only.value)
        .toList();
    if (posController.filter != filter) {
      posController.filter = filter;
    }
    posController.loadPOS();
    return Obx(() {
      return Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
            trafficEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            polylines: posController.readyPolyline.value
                ? posController.mypolylines
                : Set<Polyline>(),
            onMapCreated: (controller) {},
            initialCameraPosition: posController.initialPos ??
                CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 11,
                ),
            markers: posController.pos,
            circles: Set.from(
              [
                Circle(
                  circleId: CircleId("myposition"),
                  center: LatLng(
                      posController.mycurrentPosition != null
                          ? posController.mycurrentPosition!.latitude
                          : 0,
                      posController.mycurrentPosition != null
                          ? posController.mycurrentPosition!.longitude
                          : 0),
                  radius: 500,
                  strokeWidth: 1,
                  strokeColor: Colors.blue,
                  fillColor: Colors.blue.withOpacity(0.25),
                ),
              ],
            ),
          )),
          !posController.showHeader.value
              ? SizedBox()
              : Positioned(
                  top: 0,
                  child: Container(
                    width: Get.width - 140,
                    margin: EdgeInsets.symmetric(horizontal: 70),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset.zero,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          child: Icon(
                            Icons.gps_fixed_rounded,
                            size: 40,
                            color: Colors.green.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          posController
                              .selectedPOS, //     <----------- Name of POS
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                ),
        ],
      );
    });
  }
}
