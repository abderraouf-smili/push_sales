import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:push_sale/api/my_image_picker.dart';
import 'package:push_sale/controllers/dropdown_controller.dart';
import 'package:push_sale/controllers/client_controller.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/visit_day.dart';
import 'package:push_sale/views/signed/widgets/clients/dropdown.dart';
import 'package:push_sale/const/globals.dart' as global;

class EditClient extends StatelessWidget {
  DropDownController dropController = Get.put(DropDownController("typePV"));
  ClientController clientController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  Client? client;
  EditClient({this.client});

  @override
  Widget build(BuildContext context) {
    clientController.GPS_ready.value = false;
    clientController.GPS_loading.value = false;
    clientController.hasNoGPS.value = true;
    clientController.progressLevel.value = 0;
    clientController.totalLevel = 0;
    clientController.stepSave.value = "";
    clientController.isButtonClicked.value = false;
    bool edit = client != null;
    nameController.text = edit ? client!.name : "";
    phoneController.text = edit ? client!.mobile : "";
    clientController.client = null;
    if (edit) {
      clientController.client = client;
      dropController.initialTPV = client!.typepv!.id;
      clientController.CountryName = client!.address!.country!.name;
      clientController.Country_Text = client!.address!.country!.code;
      clientController.Wilaya_Text = client!.address!.wilaya.name;
      clientController.City_Text = client!.address!.city.name;
      clientController.Commune_Text = client!.address!.commune;
      clientController.Street_Text = client!.address!.street;
      clientController.Zipcode_Text = client!.address!.zipcode;
      clientController.Latitude = client!.address!.latitude;
      clientController.Longitude = client!.address!.longitude;
      clientController.hasNoGPS.value = false;
    } else {
      clientController.generateId();
    }
    return SafeArea(
      bottom: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(edit ? "editer.client".tr : "new.client".tr),
          centerTitle: true,
          backgroundColor:
              edit ? Colors.red.withOpacity(0.7) : Colors.transparent,
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.menu))],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Form(
            key: clientController.FormKey,
            child: Container(
              padding: EdgeInsets.only(bottom: 40),
              color: Color.fromARGB(255, 244, 249, 255),
              child: Column(
                children: [
                  //Picture
                  Container(
                    // color: Colors.orange,
                    height: Get.height / 2.5,
                    width: double.infinity,
                    child: MyImagePicker(
                      preferredCameraDevice: CameraDevice.rear,
                      initialValue: client != null && client!.hasImage
                          ? [
                              Image.network(
                                client!.image,
                                fit: BoxFit.cover,
                              )
                            ]
                          : null,
                      maxImages: 1,
                      previewMargin: EdgeInsets.zero,
                      previewWidth: Get.width,
                      previewHeight: Get.height / 2.5,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      name: "Image",
                      // validator: (value) {
                      //   return value == null || value.length == 0
                      //       ? "     " "No.Empty.Picture".tr
                      //       : null;
                      // },
                      onSaved: (value) {
                        clientController.ImageClient = value;
                      },
                    ),
                  ),

                  Stack(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1,
                            color: Color.fromARGB(255, 196, 196, 196),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Name
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                child: TextFormField(
                                  controller: nameController,
                                  validator: (value) => value!.length < 3
                                      ? "errorLastName".tr
                                      : null,
                                  onSaved: (newValue) {
                                    clientController.Name = newValue;
                                  },
                                  decoration: InputDecoration(
                                    labelText: "name.client".tr,
                                    labelStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            //phone
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                child: TextFormField(
                                  keyboardType: TextInputType.phone,
                                  controller: phoneController,
                                  // validator: (value) => value!.length < 7
                                  //     ? "errorphone".tr
                                  //     : null,
                                  onSaved: (newValue) {
                                    clientController.Mobile = newValue;
                                  },
                                  decoration: InputDecoration(
                                    labelText: "mobile.client".tr,
                                    labelStyle: TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Button GPS
                      Obx(
                        () => clientController.GPS_ready.value
                            ? SizedBox.shrink()
                            : Positioned(
                                right: Get.locale!.languageCode != 'ar'
                                    ? 20
                                    : null,
                                left: Get.locale!.languageCode == 'ar'
                                    ? 20
                                    : null,
                                top: 30,
                                child: Container(
                                  height: 60,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: IconButton(
                                    onPressed: () async {
                                      var status =
                                          await Permission.location.status;

                                      if (status.isGranted) {
                                        Position position =
                                            await clientController
                                                .getLocation();
                                        await clientController
                                            .GetAddressFromLatLong(position);
                                      } else if (status.isDenied) {
                                        AwesomeDialog(
                                            btnCancelOnPress: () {},
                                            btnOkOnPress: () async {
                                              var permission = await Geolocator
                                                  .requestPermission();
                                            },
                                            context: Get.context!,
                                            dialogType: DialogType.error,
                                            title: "error".tr,
                                            desc:
                                                "position.disabled.do.you.want.enable"
                                                    .tr)
                                          ..show();
                                      } else if (status.isPermanentlyDenied) {
                                        AwesomeDialog(
                                            btnOkOnPress: () {},
                                            context: Get.context!,
                                            dialogType: DialogType.error,
                                            title: "error".tr,
                                            desc: "position.forver.disabled".tr)
                                          ..show();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.location_on_outlined,
                                      size: 40,
                                      color: clientController.hasNoGPS.value &&
                                              clientController
                                                  .isButtonClicked.value
                                          ? Color.fromARGB(255, 180, 61, 53)
                                          : Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      // validate error button GPS
                      Positioned(
                        right: Get.locale!.languageCode != 'ar' ? 0 : null,
                        left: Get.locale!.languageCode == 'ar' ? 0 : null,
                        top: 80,
                        child: Obx(
                          () => clientController.hasNoGPS.value &&
                                  clientController.isButtonClicked.value
                              ? Container(
                                  width: 80,
                                  height: 40,
                                  child: Center(
                                    child: Text(
                                      "GPS",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 206, 62, 52),
                                          fontSize: 12),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),

                  // Type de client
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 1,
                        color: Color.fromARGB(255, 196, 196, 196),
                      ),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex: 1, child: Text("type_pv".tr)),
                          Expanded(
                            flex: 2,
                            child: Container(
                                width: Get.width / 1.5,
                                child: TypePointVenteDropDown(
                                  select_text: "please select ...".tr,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  // Address du client
                  Obx(
                    () => clientController.GPS_loading.value
                        ? Container(
                            //only when GPS_loading
                            height: 156,
                            width: 156,
                            padding: EdgeInsets.all(60),
                            child: CircularProgressIndicator(),
                          )
                        : !clientController.GPS_ready.value && !edit
                            ? SizedBox(
                                // only when !edit and !GPS_ready and !GPS_loading
                                height: 156,
                              )
                            : Container(
                                // GPS_ready or edit
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        width: 1,
                                        color: Color.fromARGB(
                                            255, 196, 196, 196))),
                                padding: EdgeInsets.symmetric(vertical: 30),
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      //Wilaya
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text("Wilaya".tr),
                                            ),
                                            // Container(width: Get.width / 1.5, child: WilayaDropDown()),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15),
                                                  child: Text(
                                                      "${clientController.Wilaya_Text!} - ${clientController.Country_Text!}")),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),

                                      // City
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text("City".tr),
                                            ),
                                            // Container(width: Get.width / 1.5, child: WilayaDropDown()),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15),
                                                  child: Text(clientController
                                                          .City_Text ??
                                                      "")),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      // Commune
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text("address".tr),
                                            ),
                                            // Container(width: Get.width / 1.5, child: WilayaDropDown()),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 15),
                                                  child: Text(
                                                      "${clientController.Commune_Text ?? ""} ${clientController.Street_Text ?? ""}")),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  ),

                  // jours de visites
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 1,
                            color: Color.fromARGB(255, 196, 196, 196))),
                    padding: EdgeInsets.symmetric(vertical: 30),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          global.weekdays.length,
                          (index) {
                            var day = global.weekdays[index];
                            return Column(
                              mainAxisAlignment:
                                  clientController.weekday_changed.value >= 0
                                      ? MainAxisAlignment.center
                                      : MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.tr,
                                  style: TextStyle(fontSize: 12),
                                ),
                                Checkbox(
                                    value: edit
                                        ? client!.visitdays!
                                            .where(
                                                (element) => element.day == day)
                                            .isNotEmpty
                                        : clientController.visit_days
                                            .where(
                                                (element) => element.day == day)
                                            .isNotEmpty,
                                    onChanged: (value) {
                                      List<VisitDay> current_days = edit
                                          ? client!.visitdays!
                                          : clientController.visit_days;

                                      if (current_days
                                          .where(
                                              (element) => element.day == day)
                                          .isEmpty) {
                                        current_days.add(
                                          VisitDay(day),
                                        );
                                      } else {
                                        current_days.removeWhere(
                                            (element) => element.day == day);
                                      }
                                      print(clientController.visit_days.length);
                                      /*                if (edit) {
                                        client!.visitdays = current_days;
                                      } else {
                                        clientController.visit_days =
                                            current_days;
                                      } */
                                      clientController.weekday_changed.value++;
                                    })
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  //Button Save
                  MaterialButton(
                    shape: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10)),
                        borderSide: BorderSide.none),
                    color: Color.fromARGB(255, 109, 175, 111),
                    minWidth: Get.width - 20,
                    height: 50,
                    onPressed: () async {
                      clientController.TypePVID = dropController.TpvID;
                      if (edit) {
                        clientController.visit_days = client!.visitdays!;
                      }
                      var rep = await clientController.save();
                      if (rep.status == "SUCCESS") {
                        Get.offAllNamed("/HomePage",
                            arguments: {"client_id": rep.data["id"]});
                        // Get.offAll(() => Clients(rep.data["id"]));
                      }
                    },
                    child: Obx(() {
                      switch (clientController.stepSave.value) {
                        case "start":
                          return CircularProgressIndicator(
                            color: Colors.white,
                          );
                        case "finished.success":
                          return Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                          );
                        case "finished.error":
                          return Icon(
                            Icons.error_sharp,
                            color: Colors.red,
                            size: 18,
                          );
                        default:
                          return Text(
                            "Save".tr,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          );
                      }
                    }),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Obx(
                      () => Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        height: 7,
                        width: clientController.progressLevel.value == 0
                            ? 0
                            : (clientController.progressLevel.value *
                                        Get.width -
                                    20) /
                                clientController.totalLevel,
                        color: Colors.red,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
