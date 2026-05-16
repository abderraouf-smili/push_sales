import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/dropdown_controller.dart';
import 'package:push_sale/controllers/filter_controller.dart';
import 'package:push_sale/models/actor_profile.dart';
import 'package:push_sale/models/type_point_vente.dart';
import 'package:push_sale/models/wilaya.dart';
import 'package:push_sale/models/city.dart';

class WilayaDropDown extends StatelessWidget {
  String select_text;
  String error_validate;
  bool hasBorder;
  double fontSize;
  Wilaya? wilaya;
  WilayaDropDown(
      {this.select_text = "Please select",
      this.error_validate = "No emtpy allowed",
      this.hasBorder = true,
      this.fontSize = 14,
      this.wilaya});

  DropDownController dropController = Get.find<DropDownController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => !dropController.wilayaready.value
        ? EmptyDropDown(
            "loading ...".tr,
            hasBorder: hasBorder,
          )
        : DropdownButtonFormField2(
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ), // Remplace `dropdownDecoration`
            ),
            value: wilaya != null ? wilaya!.id : null,
            key: dropController.dropdownStateWilaya,
            // selectedItemHighlightColor: Color.fromARGB(255, 206, 235, 255),
            // scrollbarTheme: true,
            // value: initialValue,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: hasBorder
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  : OutlineInputBorder(borderSide: BorderSide.none),
              //Add more decoration as you want here
              //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
            ),
            isExpanded: true,
            hint: Text(
              select_text,
              style: TextStyle(fontSize: fontSize),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ), // Remplace `icon`
              iconSize: 24, // Remplace `iconSize`
            ),
            buttonStyleData: ButtonStyleData(
              height: 50,
              padding: const EdgeInsets.only(left: 15, right: 10),
            ),
            items: [
              for (Wilaya item in dropController.wilayat)
                DropdownMenuItem<int>(
                  value: item.id,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.getName(Get.locale!.languageCode),
                        style: TextStyle(
                          fontSize: fontSize,
                        ),
                      ),
                      Text(item.code,
                          style: TextStyle(
                            fontSize: fontSize,
                          ))
                    ],
                  ),
                ),
            ],
            validator: (value) {
              if (value == null) {
                return error_validate;
              }
            },
            onChanged: (value) async {
              dropController.WilayaID = value as int;
              dropController.stateId.value = value as int;
              await dropController.getCities();
              dropController.initialCity = null;
              if (dropController.initialCity != null)
                dropController.dropdownStateCity.currentState!
                    .didChange(dropController.initialCity);
            },
            onSaved: (value) {
              dropController.WilayaID = value as int;
            },
          ));
  }
}

class CityDropDown extends StatelessWidget {
  String select_text;
  String error_validate;
  bool hasBorder;
  double fontSize;
  City? city;
  CityDropDown({
    this.select_text = "Please select",
    this.error_validate = "No emtpy allowed",
    this.hasBorder = true,
    this.fontSize = 14,
    this.city,
  });

  DropDownController dropController = Get.find<DropDownController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => !dropController.cityready.value
        ? EmptyDropDown(
            "loading ...".tr,
            hasBorder: hasBorder,
          )
        : DropdownButtonFormField2(
            key: dropController.dropdownStateCity,
            value: dropController.initialCity,
            // selectedItemHighlightColor: Color.fromARGB(255, 206, 235, 255),
            // scrollbarAlwaysShow: dropController.cityready.value,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: hasBorder
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  : OutlineInputBorder(borderSide: BorderSide.none),
              //Add more decoration as you want here
              //Add label If you want but add hint outside the decoration to be aligned in the button perfectly.
            ),
            isExpanded: true,
            hint: Text(
              select_text,
              style: TextStyle(fontSize: 14),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ), // Remplace `icon`
              iconSize: 24, // Remplace `iconSize`
            ),
            buttonStyleData: ButtonStyleData(
              height: 50,
              padding: const EdgeInsets.only(left: 15, right: 10),
            ),
            items: [
              for (City item in dropController.dairat)
                DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(
                    item.getName(Get.locale!.languageCode),
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                  ),
                ),
            ],
            validator: (value) {
              if (value == null) {
                return 'Please select city.';
              }
            },
            onChanged: (value) {
              dropController.DairaID = value as int;
            },
            onSaved: (value) {
              dropController.DairaID = value as int;
            },
          ));
  }
}

class TypePointVenteDropDown extends StatelessWidget {
  // GlobalKey dropdownStateTPV = GlobalKey<FormFieldState>();
  TypePointVenteDropDown({
    this.select_text = "Please select pointe de vente",
    this.error_validate = "Please select Type de point de vente.",
  });
  String select_text;
  String error_validate;

  GlobalKey<FormFieldState>? dropState;
  DropDownController dropController = Get.find<DropDownController>();

  @override
  Widget build(BuildContext context) {
    // if (initialValue != null && dropController.listTPVready.value) {
    // dropController.listTPVready.value = false;
    // dropdownState.currentState!.value()
    // dropController.listTPVready.value = true;
    // }
    return Obx(() => !dropController.listTPVready.value
        ? EmptyDropDown(
            "loading ...",
            hasBorder: false,
          )
        : DropdownButtonFormField2(
            key: dropController.dropdownStateTPV,
            // selectedItemHighlightColor: Color.fromARGB(255, 206, 235, 255),
            // scrollbarAlwaysShow: dropController.listTPVready.value,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
            isExpanded: true,
            hint: Text(
              select_text,
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ), // Remplace `icon`
              iconSize: 24, // Remplace `iconSize`
            ),
            buttonStyleData: ButtonStyleData(
              height: 50,
              padding: const EdgeInsets.only(left: 15, right: 10),
            ),
            items: [
              for (TypePointVente item in dropController.listTPV)
                DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(
                    item.getName(Get.locale!.languageCode),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
            validator: (value) {
              if (value == null) {
                return error_validate;
              }
            },
            onChanged: (value) async {
              dropController.TpvID = value as int;
            },
            onSaved: (value) {
              dropController.TpvID = value as int;
            },
          ));
  }
}

class ActorProfileDropDown extends StatelessWidget {
  String select_text;
  String error_validate;
  ActorProfileDropDown({
    this.select_text = "Please select",
    this.error_validate = "No empty allowed",
  });

  DropDownController dropController = Get.find<DropDownController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() => !dropController.listAPready.value
        ? EmptyDropDown("loading ...")
        : DropdownButtonFormField2(
            key: dropController.dropdownStateProfile,
            // selectedItemHighlightColor: Color.fromARGB(255, 206, 235, 255),
            // scrollbarAlwaysShow: !dropController.listAPready.value,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            isExpanded: true,
            hint: Text(
              select_text,
              style: TextStyle(fontSize: 14),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black45,
              ), // Remplace `icon`
              iconSize: 24, // Remplace `iconSize`
            ),
            buttonStyleData: ButtonStyleData(
              height: 50,
              padding: const EdgeInsets.only(left: 15, right: 10),
            ),
            items: [
              for (ActorProfile item in dropController.listAP)
                DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(
                    item.getName(Get.locale!.languageCode),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
            validator: (value) {
              if (value == null) {
                return error_validate;
              }
            },
            onChanged: (value) async {
              dropController.ActProID = value as int;
            },
            onSaved: (value) {
              dropController.ActProID = value as int;
            },
          ));
  }
}

class EmptyDropDown extends StatelessWidget {
  String text;
  bool hasBorder;
  double fontSize;
  EmptyDropDown(
    this.text, {
    this.hasBorder = true,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45,
      padding: EdgeInsets.only(left: 30, right: 10, top: 2),
      decoration: hasBorder
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey))
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
                color: Color.fromARGB(115, 77, 77, 77), fontSize: fontSize),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: Color.fromARGB(115, 116, 116, 116),
            size: 30,
          )
        ],
      ),
    );
  }
}

class TypePVSearchDropDown extends StatelessWidget {
  TypePVSearchDropDown({
    this.select_text = "Pointe de vente",
  });
  String select_text;

  GlobalKey<FormFieldState>? dropState;
  FilterController filterController = Get.find<FilterController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => !filterController.listTPVready.value
        ? EmptyDropDown(
            "loading ...",
            hasBorder: false,
          )
        : DropdownButtonFormField2(
            key: filterController.searchKeyTPV,
            style: TextStyle(
                fontSize: 12, color: Color.fromARGB(255, 85, 179, 255)),
            // selectedItemHighlightColor: Color.fromARGB(255, 206, 235, 255),
            // scrollbarAlwaysShow: filterController.listTPVready.value,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
            isExpanded: true,
            hint: Text(
              select_text,
            ),
            // buttonPadding: const EdgeInsets.only(left: 0, right: 10),
            iconStyleData: IconStyleData(
              icon: filterController.filter_button.value
                  ? Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black45,
                    )
                  : SizedBox.shrink(), // Remplace `icon`
              iconSize: 30, // Remplace `iconSize`
            ),
            buttonStyleData: ButtonStyleData(
              height: 45,
              padding: const EdgeInsets.only(left: 15, right: 10),
            ),
            items: [
              for (TypePointVente item in filterController.listTPV)
                DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(
                    item.getName(Get.locale!.languageCode),
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
            onChanged: (value) async {
              // dropController.TpvID = value as int;
              filterController.selectedTPV.value = value as int;
            },
            onSaved: (value) {
              // dropController.TpvID = value as int;
            },
          ));
  }
}

class CitiesSearchDropDown extends StatelessWidget {
  CitiesSearchDropDown({
    this.select_text = "cities",
  });
  String select_text;

  FilterController filterController = Get.find<FilterController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => !filterController.listTPVready.value
        ? EmptyDropDown(
            "loading ...",
            hasBorder: false,
          )
        : DropdownButtonFormField2(
            key: filterController.searchKeyCity,
            style: TextStyle(
                fontSize: 12, color: Color.fromARGB(255, 85, 179, 255)),
            // selectedItemHighlightColor: Color.fromARGB(255, 206, 235, 255),
            // scrollbarAlwaysShow: filterController.cityready.value,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
            isExpanded: true,
            hint: Text(
              select_text.tr,
            ),

            // buttonPadding: const EdgeInsets.only(left: 0, right: 10),
            iconStyleData: IconStyleData(
              icon: filterController.filter_button.value
                  ? Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black45,
                    )
                  : SizedBox.shrink(), // Remplace `icon`
              iconSize: 30, // Remplace `iconSize`
            ),
            buttonStyleData: ButtonStyleData(
              height: 45,
              // padding: const EdgeInsets.only(left: 15, right: 10),
            ),
            items: [
              for (City item in filterController.listCities)
                DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
            onChanged: (value) async {
              // dropController.TpvID = value as int;
              filterController.selectedCity.value = value as int;
            },
            onSaved: (value) {
              // dropController.TpvID = value as int;
            },
          ));
  }
}
