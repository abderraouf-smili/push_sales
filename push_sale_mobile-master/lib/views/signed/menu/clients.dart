import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/controllers/filter_controller.dart';
import 'package:push_sale/controllers/permissions_controller.dart';
import 'package:push_sale/controllers/position_controller.dart';
import 'package:push_sale/views/signed/widgets/clients/dropdown.dart';
import 'package:push_sale/views/signed/widgets/clients/editclient.dart';
import 'package:push_sale/views/signed/widgets/clients/listingicon.dart';
import 'package:push_sale/views/signed/widgets/clients/listinglist.dart';
import 'package:push_sale/views/signed/widgets/clients/listingmaps.dart';
import 'dart:math' as math;

class Clients extends StatelessWidget {
  String posted_id;

  Clients(this.posted_id, {super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListClients(posted_id),
    );
  }
}

class ListClients extends StatelessWidget {
  String posted_id;

  ListClients(this.posted_id, {super.key});

  ClientController clientController = Get.put(ClientController("get"));
  FilterController filterController = Get.put(FilterController());
  PositionController posController = Get.put(PositionController());
  PermissionsController Perm = Get.find();
  PageController pageController = PageController();
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // entete search bar
              SizedBox(
                height: 40,
                // margin: const EdgeInsets.only(right: 10),
                width: Get.width - 60,
                child: TextFormField(
                  controller: searchController,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontFamily: 'alata',
                  ),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(30)),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 231, 244, 255),
                      prefixIcon: const Icon(
                        Icons.search_outlined,
                        color: Color.fromARGB(255, 135, 201, 255),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          clientController.ready.value = false;
                          clientController.filter = "";
                          searchController.text = "";
                          clientController.ready.value = true;
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                        ),
                      ),
                      hintText: "search".tr,
                      hintStyle: const TextStyle(
                          fontFamily: "alata",
                          color: Color.fromARGB(255, 135, 201, 255))),
                  onChanged: (value) {
                    clientController.ready.value = false;
                    clientController.filter = value;
                    clientController.ready.value = true;
                  },
                ),
              ),

              SizedBox(
                width: 40,
                child: IconButton(
                  onPressed: () {
                    filterController.filter_button.value =
                        !filterController.filter_button.value;
                  },
                  icon: Obx(
                    () => AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      transform: Matrix4.rotationZ(
                          !filterController.filter_button.value
                              ? 0
                              : math.pi / 2),
                      transformAlignment: const AlignmentDirectional(0, 0),
                      child: Icon(
                        filterController.selectedCity.value > 0 ||
                                filterController.selectedTPV.value > 0
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        //filter bar + mode view vbar
        Container(
          margin: const EdgeInsets.only(bottom: 2),
          child: Column(
            children: [
              Obx(
                () => AnimatedContainer(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 231, 244, 255),
                    border: Border.all(
                      width: 0.5,
                      color: const Color.fromARGB(255, 198, 230, 255),
                    ),
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(30)),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  duration: const Duration(milliseconds: 500),
                  height: filterController.filter_button.value ? 40 : 0,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: Get.width / 2.25,
                        child: TypePVSearchDropDown(),
                      ),
                      SizedBox(
                        width: Get.width / 2.5,
                        child: CitiesSearchDropDown(),
                      ),
                      IconButton(
                        onPressed: () {
                          filterController.selectedCity.value = 0;
                          filterController.selectedTPV.value = 0;
                          filterController.searchKeyCity.currentState!.reset();
                          filterController.searchKeyTPV.currentState!.reset();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Color.fromARGB(255, 197, 110, 83),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // view mode bar
              Obx(
                () => AnimatedContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 231, 244, 255),
                    border: Border.all(
                      width: 0.5,
                      color: const Color.fromARGB(255, 198, 230, 255),
                    ),
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(30)),
                  ),
                  duration: const Duration(milliseconds: 500),
                  width: double.infinity,
                  height: filterController.filter_button.value ? 0 : 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            // padding: EdgeInsets.only(right: Get.width / 2 - 14),
                            child: clientController.ready.value
                                ? Text(
                                    clientController.clientsList
                                        .where((element) => element.name
                                            .contains(clientController.filter))
                                        .toList()
                                        .where((element) =>
                                            filterController.selectedCity.value ==
                                                0 ||
                                            element.address!.city.id ==
                                                filterController
                                                    .selectedCity.value)
                                        .toList()
                                        .where((element) =>
                                            filterController.selectedTPV.value ==
                                                0 ||
                                            element.typepv!.id ==
                                                filterController
                                                    .selectedTPV.value)
                                        .toList()
                                        .where((element) =>
                                            element.visitdays != null &&
                                                element.visitdays!
                                                    .where((item) =>
                                                        item.day == "tuesday")
                                                    .isNotEmpty ||
                                            !clientController.visit_day_only.value)
                                        .toList()
                                        .length
                                        .toString(),
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontFamily: 'alata',
                                        fontSize: 12),
                                  )
                                : const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              clientController.visit_day_only.value =
                                  !clientController.visit_day_only.value;
                            },
                            child: SizedBox(
                              width: Get.width / 5,
                              height: 40,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 1),
                                decoration: BoxDecoration(
                                  color: clientController.visit_day_only.value
                                      ? const Color.fromARGB(255, 161, 167, 255)
                                      : const Color.fromARGB(
                                          255, 210, 213, 255),
                                  border: Border.all(
                                    width: 1,
                                    color: clientController.visit_day_only.value
                                        ? const Color.fromARGB(
                                            255, 139, 131, 252)
                                        : const Color.fromARGB(
                                            255, 167, 173, 255),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                    child: Text(
                                  "day.only".tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: clientController.visit_day_only.value
                                        ? Colors.white
                                        : Colors.grey,
                                  ),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: Get.width / 1.5,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            !clientController.ready.value ||
                                    clientController.clientsList
                                        .where((element) => element.name
                                            .contains(clientController.filter))
                                        .toList()
                                        .where((element) =>
                                            filterController.selectedCity.value == 0 ||
                                            element.address!.city.id ==
                                                filterController
                                                    .selectedCity.value)
                                        .toList()
                                        .where((element) =>
                                            filterController.selectedTPV.value == 0 ||
                                            element.typepv!.id ==
                                                filterController
                                                    .selectedTPV.value)
                                        .toList()
                                        .where((element) =>
                                            element.visitdays != null &&
                                                element.visitdays!
                                                    .where((item) =>
                                                        item.day ==
                                                        DateFormat("EEEE").format(DateTime.now()).toLowerCase())
                                                    .isNotEmpty ||
                                            !clientController.visit_day_only.value)
                                        .toList()
                                        .isNotEmpty
                                ? const SizedBox.shrink()
                                : IconButton(
                                    onPressed: () async {
                                      clientController.ready.value = false;
                                      await clientController.getClients();
                                      clientController.ready.value = true;
                                    },
                                    icon: const Icon(
                                      Icons.change_circle_outlined,
                                      color: Colors.blue,
                                    ),
                                  ),
                            IconButton(
                              onPressed: () {
                                clientController.page.value = 0;
                                pageController.jumpToPage(0);
                              },
                              icon: Icon(
                                Icons.view_headline_rounded,
                                color: clientController.page.value == 0
                                    ? const Color.fromARGB(255, 197, 110, 83)
                                    : Colors.blue,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                clientController.page.value = 1;
                                pageController.jumpToPage(1);
                              },
                              icon: Icon(
                                Icons.grid_view_rounded,
                                color: clientController.page.value == 1
                                    ? const Color.fromARGB(255, 197, 110, 83)
                                    : Colors.blue,
                                size: 23,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                clientController.page.value = 2;
                                pageController.jumpToPage(2);
                              },
                              icon: Icon(
                                Icons.language,
                                color: clientController.page.value == 2
                                    ? const Color.fromARGB(255, 197, 110, 83)
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        // Content Page
        Stack(
          children: [
            Container(
              color: const Color.fromARGB(255, 239, 247, 255),
              width: double.infinity,
              height: Get.height - 150,
              child: Obx(
                () => PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      color: clientController.ready.value
                          ? Colors.transparent
                          : Colors.transparent,
                      child: ListingList(
                          clientController.clientsList
                              .where((element) => element.name
                                  .contains(clientController.filter))
                              .toList()
                              .where((element) =>
                                  filterController.selectedCity.value == 0 ||
                                  element.address!.city.id ==
                                      filterController.selectedCity.value)
                              .toList()
                              .where((element) =>
                                  filterController.selectedTPV.value == 0 ||
                                  element.typepv!.id ==
                                      filterController.selectedTPV.value)
                              .toList()
                              .where((element) =>
                                  element.visitdays != null &&
                                      element.visitdays!
                                          .where((item) =>
                                              item.day ==
                                              DateFormat("EEEE")
                                                  .format(DateTime.now())
                                                  .toLowerCase())
                                          .isNotEmpty ||
                                  !clientController.visit_day_only.value)
                              .toList(),
                          posted_id: posted_id),
                    ),
                    Container(
                      color: clientController.ready.value
                          ? Colors.transparent
                          : Colors.transparent,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ListingIcon(
                          clientController.clientsList
                              .where((element) => element.name
                                  .contains(clientController.filter))
                              .toList()
                              .where((element) =>
                                  filterController.selectedCity.value == 0 ||
                                  element.address!.city.id ==
                                      filterController.selectedCity.value)
                              .toList()
                              .where((element) =>
                                  filterController.selectedTPV.value == 0 ||
                                  element.typepv!.id ==
                                      filterController.selectedTPV.value)
                              .toList()
                              .where((element) =>
                                  element.visitdays != null &&
                                      element.visitdays!
                                          .where((item) =>
                                              item.day ==
                                              DateFormat("EEEE")
                                                  .format(DateTime.now())
                                                  .toLowerCase())
                                          .isNotEmpty ||
                                  !clientController.visit_day_only.value)
                              .toList(),
                          posted_id: posted_id),
                    ),
                    ListingMaps(
                      clientController.clientsList,
                      filter: clientController.filter,
                      filterTPV: filterController.selectedTPV.value,
                      filterCity: filterController.selectedCity.value,
                    ),
                  ],
                ),
              ),
            ),
            Perm.check(
                Obx(
                  () => Positioned(
                    bottom: 40,
                    // right: Get.width / 2,
                    right: Get.locale!.languageCode != "ar"
                        ? clientController.page.value == 2
                            ? Get.width / 2 - 28
                            : 10
                        : null,
                    left: Get.locale!.languageCode == "ar"
                        ? clientController.page.value == 2
                            ? Get.width / 2 - 28
                            : 10
                        : null,
                    child: FloatingActionButton(
                      onPressed: () {
                        Get.to(() => EditClient());
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ),
                "Clients.add"),
          ],
        ),
      ],
    );
  }
}
