import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:push_sale/api/my_image_picker.dart';
import 'package:push_sale/controllers/compte_menu_controller.dart';
import 'package:push_sale/controllers/dropdown_controller.dart';
import 'package:push_sale/models/actor.dart';
import 'package:push_sale/views/signed/homepage.dart';
import 'package:push_sale/views/signed/widgets/clients/dropdown.dart';

class EditPerosnalData extends StatelessWidget {
  CompteMenuController compteController =
      Get.isRegistered<CompteMenuController>()
          ? Get.find<CompteMenuController>()
          : Get.put(CompteMenuController());
  DropDownController dropController =
      Get.put(DropDownController("settingProfile"));
  TextEditingController lastNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  EditPerosnalData({super.key});
  @override
  Widget build(BuildContext context) {
    compteController.sendingState.value = 0;
    lastNameController.text = compteController.actor!.lastname;
    firstNameController.text = compteController.actor!.firstname;
    phoneController.text = compteController.actor!.phone;
    dropController.stateId.value = compteController.actor!.address!.wilaya.id;
    dropController.initialCity = compteController.actor!.address!.city.id;
    dropController.getCities();
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: compteController.FormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: Get.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.arrow_back)),
                      Text(
                        "edit.profile".tr,
                        style: const TextStyle(
                            fontFamily: "kodchasan",
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 23, 91, 146)),
                      ),
                      const SizedBox(),
                      const SizedBox(),
                    ],
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: Stack(children: [
                      Positioned(
                        top: 12,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                                width: 2,
                                color: const Color.fromARGB(255, 192, 92, 231)),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      MyImagePicker(
                        preferredCameraDevice: CameraDevice.front,
                        initialValue: compteController.actor!.hasImage
                            ? [
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        compteController.actor!.image,
                                      ),
                                    ),
                                  ),
                                )
                              ]
                            : null,
                        maxImages: 1,
                        previewMargin: const EdgeInsets.only(top: 1, left: 1),
                        previewWidth: 198,
                        previewHeight: 198,
                        boxShape: BoxShape.circle,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        name: "Image",
                        onSaved: (value) {
                          compteController.ImageActor = value;
                        },
                      ),
                    ]),
                  ),
                ),
                const Divider(thickness: 1),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    width: Get.width,
                    height: compteController.validate_lastname.value ? 73 : 50,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.length < 3) {
                          compteController.validate_lastname.value = true;
                        } else {
                          compteController.validate_lastname.value = false;
                        }
                        return value.length < 3 ? "errorLastName".tr : null;
                      },
                      controller: lastNameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.assignment_ind),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelText: "last.name".tr,
                      ),
                      onSaved: (value) {
                        compteController.lastName = value;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    width: Get.width,
                    height: compteController.validate_firstname.value ? 73 : 50,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.length < 3) {
                          compteController.validate_firstname.value = true;
                        } else {
                          compteController.validate_firstname.value = false;
                        }
                        return value.length < 3 ? "errorFirstName".tr : null;
                      },
                      controller: firstNameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_add),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: "first.name".tr,
                      ),
                      onSaved: (value) {
                        compteController.firstName = value;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    width: Get.width / 1.5 - 10,
                    height: compteController.validate_phone.value ? 73 : 50,
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        RegExp phoneExp = RegExp(r'^[0-9]{10}$');
                        if (value!.isEmpty) {
                          compteController.validate_phone.value = true;
                          return "errorPhone.empty".tr;
                        } else if (value.length > 10 ||
                            !phoneExp.hasMatch(value)) {
                          compteController.validate_phone.value = true;
                          return "errorPhone.notvalide".tr;
                        } else {
                          compteController.validate_phone.value = false;
                          return null;
                        }
                      },
                      controller: phoneController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_iphone),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: "phone".tr,
                      ),
                      onSaved: (value) {
                        compteController.phoneNumber = value;
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: Get.width / 1.5 - 40,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: const Color.fromARGB(255, 212, 212, 212)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: EmptyDropDown(
                    compteController.actor!.Profile!.name.tr,
                    hasBorder: false,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: Get.width / 1.5 - 40,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: const Color.fromARGB(255, 134, 134, 134)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: WilayaDropDown(
                    select_text: "Wilaya".tr,
                    hasBorder: false,
                    fontSize: 16,
                    wilaya: compteController.actor!.address!.wilaya,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: Get.width / 1.5 - 40,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: const Color.fromARGB(255, 134, 134, 134)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CityDropDown(
                    select_text: "City".tr,
                    hasBorder: false,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                compteController.actor!.distributor != null
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        width: Get.width,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: const Color.fromARGB(255, 212, 212, 212)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                            child: Text(
                          compteController.actor!.distributor!.name,
                          style: const TextStyle(
                            fontFamily: "kodchasan",
                            fontSize: 20,
                          ),
                        )))
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: Obx(
                      () => MaterialButton(
                        minWidth: Get.width - 20,
                        height: 70,
                        elevation: 10,
                        textColor: Colors.white,
                        color: Colors.blue,
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                        onPressed: () async {
                          //
                          compteController.stateId = dropController.WilayaID;
                          compteController.cityId = dropController.DairaID;
                          var response = await compteController.save();
                          if (response.status == "SUCCESS") {
                            compteController.ready.value = false;
                            compteController.sendingState.value = 2;
                            compteController.actor =
                                Actor.fromMap(response.data);
                            compteController.ready.value = true;
                            Get.offAll(HomePage(
                              index: 4,
                            ));
                          } else {
                            AwesomeDialog(
                                    dialogType: DialogType.error,
                                    title: "sure".tr,
                                    body: Text("error.saved".tr),
                                    context: context,
                                    btnOkOnPress: () {})
                                .show();
                            compteController.sendingState.value = -1;
                          }
                        },
                        child: compteController.sendingState.value == 0
                            ? Text("save".tr)
                            : compteController.sendingState.value == 1
                                ? const CircularProgressIndicator()
                                : compteController.sendingState.value == -1
                                    ? const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      )
                                    : const Icon(
                                        Icons.check_circle_outline_outlined,
                                        color: Colors.white,
                                      ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
