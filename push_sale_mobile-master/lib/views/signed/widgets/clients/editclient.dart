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
import 'package:push_sale/theme/app_colors.dart';
import 'package:push_sale/theme/app_spacing.dart';
import 'package:push_sale/theme/app_text_styles.dart';
import 'package:push_sale/views/signed/widgets/clients/dropdown.dart';
import 'package:push_sale/widgets/common/app_card.dart';
import 'package:push_sale/widgets/common/app_snackbar.dart';
import 'package:push_sale/const/globals.dart' as global;

class EditClient extends StatelessWidget {
  DropDownController dropController = Get.put(DropDownController("typePV"));
  ClientController clientController = Get.find();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  Client? client;
  EditClient({super.key, this.client});

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
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: Text(edit ? "editer.client".tr : "new.client".tr),
          centerTitle: true,
          backgroundColor: AppColors.canvas,
          actions: [
            IconButton(
              onPressed: () async {
                final status = await Permission.location.status;
                if (status.isGranted) {
                  Position position = await clientController.getLocation();
                  await clientController.GetAddressFromLatLong(position);
                } else {
                  await Geolocator.requestPermission();
                }
              },
              icon: const Icon(Icons.my_location_rounded),
              tooltip: "GPS",
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Form(
            key: clientController.FormKey,
            child: Column(
              children: [
                AppCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                      previewWidth: double.infinity,
                      previewHeight: 190,
                      decoration: const InputDecoration(
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
                ),
                const SizedBox(height: AppSpacing.md),

                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          // Name
                          TextFormField(
                            controller: nameController,
                            validator: (value) =>
                                value!.length < 3 ? "errorLastName".tr : null,
                            onSaved: (newValue) {
                              clientController.Name = newValue;
                            },
                            decoration: InputDecoration(
                              labelText: "name.client".tr,
                              prefixIcon:
                                  const Icon(Icons.store_mall_directory),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          //phone
                          TextFormField(
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
                              prefixIcon: const Icon(Icons.phone_rounded),
                            ),
                          ),
                        ],
                      ),
                      //Button GPS
                      Obx(
                        () => clientController.GPS_ready.value
                            ? const SizedBox.shrink()
                            : Positioned(
                                right: Get.locale!.languageCode != 'ar'
                                    ? 20
                                    : null,
                                left: Get.locale!.languageCode == 'ar'
                                    ? 20
                                    : null,
                                top: 30,
                                child: Material(
                                  color: AppColors.surface,
                                  elevation: 3,
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd),
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
                                                  await Geolocator
                                                      .requestPermission();
                                                },
                                                context: Get.context!,
                                                dialogType: DialogType.error,
                                                title: "error".tr,
                                                desc:
                                                    "position.disabled.do.you.want.enable"
                                                        .tr)
                                            .show();
                                      } else if (status.isPermanentlyDenied) {
                                        AwesomeDialog(
                                                btnOkOnPress: () {},
                                                context: Get.context!,
                                                dialogType: DialogType.error,
                                                title: "error".tr,
                                                desc: "position.forver.disabled"
                                                    .tr)
                                            .show();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.location_on_outlined,
                                      size: 40,
                                      color: clientController.hasNoGPS.value &&
                                              clientController
                                                  .isButtonClicked.value
                                          ? const Color.fromARGB(
                                              255, 180, 61, 53)
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
                              ? const SizedBox(
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
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Type de client
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text("type_pv".tr, style: AppTextStyles.body),
                      ),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                            width: Get.width / 1.5,
                            child: TypePointVenteDropDown(
                              select_text: "please select ...".tr,
                            )),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                // Address du client
                Obx(
                  () => clientController.GPS_loading.value
                      ? const AppCard(
                          //only when GPS_loading
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : !clientController.GPS_ready.value && !edit
                          ? AppCard(
                              child: Column(
                                children: [
                                  const Icon(Icons.location_off_outlined,
                                      color: AppColors.warning, size: 36),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    "Position requise",
                                    style: AppTextStyles.title
                                        .copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    "Touchez l'icone GPS pour recuperer la position du client avant l'enregistrement.",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.subtitle,
                                  ),
                                ],
                              ),
                            )
                          : AppCard(
                              // GPS_ready or edit
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Adresse", style: AppTextStyles.title),
                                  const SizedBox(height: AppSpacing.md),
                                  //Wilaya
                                  Row(
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Text(
                                                "${clientController.Wilaya_Text!} - ${clientController.Country_Text!}")),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // City
                                  Row(
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Text(
                                                clientController.City_Text ??
                                                    "")),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  // Commune
                                  Row(
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
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Text(
                                                "${clientController.Commune_Text ?? ""} ${clientController.Street_Text ?? ""}")),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                ),

                // jours de visites
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Obx(
                    () => Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: List.generate(
                        global.weekdays.length,
                        (index) {
                          var day = global.weekdays[index];
                          return SizedBox(
                            width: 72,
                            child: Column(
                              children: [
                                Text(
                                  day.tr,
                                  style: const TextStyle(fontSize: 12),
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
                                      List<VisitDay> currentDays = edit
                                          ? client!.visitdays!
                                          : clientController.visit_days;

                                      if (currentDays
                                          .where(
                                              (element) => element.day == day)
                                          .isEmpty) {
                                        currentDays.add(
                                          VisitDay(day),
                                        );
                                      } else {
                                        currentDays.removeWhere(
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
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                //Button Save
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (clientController.hasNoGPS.value && !edit) {
                        AppSnackbar.error(
                          "Position requise",
                          "Recuperez la position GPS avant de sauvegarder ce client.",
                        );
                        return;
                      }
                      clientController.TypePVID = dropController.TpvID;
                      if (clientController.TypePVID == null ||
                          clientController.TypePVID == 0) {
                        AppSnackbar.error(
                          "Type de PV requis",
                          "Selectionnez le type de point de vente.",
                        );
                        return;
                      }
                      if (edit) {
                        clientController.visit_days = client!.visitdays!;
                      }
                      var rep = await clientController.save();
                      if (rep.status == "SUCCESS") {
                        Get.offAllNamed("/HomePage",
                            arguments: {"client_id": rep.data["id"]});
                        // Get.offAll(() => Clients(rep.data["id"]));
                      } else {
                        AppSnackbar.error(
                          "Client non enregistre",
                          rep.message.toString(),
                        );
                      }
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: Obx(() {
                      switch (clientController.stepSave.value) {
                        case "start":
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        case "finished.success":
                          return const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                          );
                        case "finished.error":
                          return const Icon(
                            Icons.error_sharp,
                            color: Colors.red,
                            size: 18,
                          );
                        default:
                          return Text(
                            "Save".tr,
                          );
                      }
                    }),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Obx(
                    () => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 7,
                      width: clientController.progressLevel.value == 0
                          ? 0
                          : (clientController.progressLevel.value * Get.width -
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
    );
  }
}
