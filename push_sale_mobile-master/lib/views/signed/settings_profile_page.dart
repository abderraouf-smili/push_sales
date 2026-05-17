import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:push_sale/controllers/dropdown_controller.dart';
import 'package:push_sale/controllers/settings_profile_controller.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/views/signed/widgets/clients/dropdown.dart';

class SettingsProfilePage extends StatelessWidget {
  DropDownController dropController =
      Get.put(DropDownController("settingProfile"));

  SettingsProfileController settingProfile =
      Get.put(SettingsProfileController());
  TextEditingController mailController = TextEditingController();
  TextEditingController ln_Controller = TextEditingController();
  TextEditingController fn_Controller = TextEditingController();
  XFile? _file;

  SettingsProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    ln_Controller.text = global.lastName;
    fn_Controller.text = global.firstName;
    settingProfile.generateId();

    return SafeArea(
      bottom: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 244, 250, 255),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: settingProfile.keyForm,
              child: Column(
                children: [
                  Image(
                    image: const AssetImage("assets/images/settingprofile.png"),
                    width: Get.width / 3,
                  ),
                  //last name
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        controller: ln_Controller,
                        validator: (value) =>
                            value!.length < 3 ? "errorLastName".tr : null,
                        onSaved: (newValue) {
                          settingProfile.lastname = newValue!;
                        },
                        decoration: InputDecoration(labelText: "Last Name".tr),
                      ),
                    ),
                  ),
                  //first name
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        controller: fn_Controller,
                        validator: (value) =>
                            value!.length < 3 ? "errorFirstName".tr : null,
                        onSaved: (newValue) {
                          settingProfile.firstname = newValue!;
                        },
                        decoration: InputDecoration(labelText: "First Name".tr),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),

                  //profile vendeur
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Profile".tr),
                        SizedBox(
                            width: Get.width / 1.6,
                            child: ActorProfileDropDown(
                                select_text: "select-profile".tr,
                                error_validate: "errorProfile".tr))
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //wilaya
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Wilaya".tr),
                        SizedBox(
                          width: Get.width / 1.6,
                          child: WilayaDropDown(
                            select_text: "Wilaya".tr,
                            error_validate: "errorWilaya".tr,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  // city
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("City".tr),
                        SizedBox(
                          width: Get.width / 1.6,
                          child: CityDropDown(
                            select_text: "City".tr,
                            error_validate: "errorCity".tr,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  //street
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        onSaved: (newValue) {
                          settingProfile.street = newValue!;
                        },
                        decoration: const InputDecoration(labelText: "Street"),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //code postal
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        onSaved: (newValue) {
                          settingProfile.zipcode = newValue!;
                        },
                        decoration:
                            const InputDecoration(labelText: "Code Postal"),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  MaterialButton(
                    color: const Color.fromARGB(255, 77, 134, 75),
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    minWidth: Get.width / 1.6,
                    height: 45,
                    onPressed: () async {
                      settingProfile.profile_id = dropController.ActProID ?? 0;
                      settingProfile.state_id = dropController.WilayaID ?? 0;
                      settingProfile.city_id = dropController.DairaID ?? 0;
                      if (await settingProfile.SubmitFormActorCreate()) {
                        AwesomeDialog(
                                btnOkOnPress: () {},
                                context: Get.context!,
                                dialogType: DialogType.info,
                                title: "success".tr,
                                desc: "profilesaved".tr)
                            .show();
                        Get.offAllNamed("/HomePage");
                      }
                    },
                    child: Text(
                      "Save".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
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

                  // FormBuilderImagePicker(
                  //   decoration: InputDecoration(
                  //     border: InputBorder.none,
                  //   ),
                  //   validator: (value) =>
                  //       value!.isEmpty ? "error picture" : null,
                  //   onChanged: (value) {
                  //     if (value!.isNotEmpty) {
                  //       settingProfile.image =
                  //           base64Encode(File(value[0].path).readAsBytesSync());
                  //     }
                  //   },
                  //   name: 'photos',
                  //   maxImages: 1,
                  // ),