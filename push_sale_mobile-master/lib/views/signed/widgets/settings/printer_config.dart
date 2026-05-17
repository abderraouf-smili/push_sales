import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/api/printer_controller.dart';

void ShowButtomSheetPrinterConfig({required BuildContext context}) {
  PrinterController printerController = Get.put(PrinterController());

  List<String> encode = [
    "UTF-8",
    "CP437",
    "CP932",
    "ISO_8859-1",
    "ISO_8859-2",
    "CP1251",
    "CP1252",
    "CP1256",
    "WPC1252",
    "WPC1256",
    "windows-1252",
    "windows-1256",
  ];

  List<String> printerSize = [
    "58",
    "80",
    "113",
  ];
  printerController.resetWindow();
  showModalBottomSheet<void>(
      isScrollControlled: true,
      anchorPoint: const Offset(10, 1),
      backgroundColor: Colors.black.withOpacity(0.60),
      context: context,
      builder: (context) {
        return Container(
          height: Get.height / 1.5,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 241, 241, 241),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 60,
                color: const Color.fromARGB(255, 218, 218, 218),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox.shrink(),
                    Container(
                      child: Center(
                        child: Text(
                          "printer.config.title".tr,
                          style: const TextStyle(
                            fontFamily: 'alata',
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      iconSize: 32,
                      onPressed: () async {
                        await printerController.ScanPrinter();
                      },
                      icon: const Icon(
                        Icons.refresh,
                      ),
                    )
                  ],
                ),
              ),
              Obx(() {
                return printerController.exist.value == false
                    ? printerController.address == null
                        ? SizedBox(
                            width: Get.width,
                            height: Get.height / 2.3 + 50,
                            child: Center(
                                child: Obx(() => Text(
                                    (printerController.PrinterState.value ==
                                                "bluetooth_off"
                                            ? "bluetooth.disabled"
                                            : "no printer !")
                                        .tr))),
                          )
                        : SizedBox(
                            width: Get.width,
                            height: Get.height / 2.3 + 50,
                            child: ListTile(
                              title: Text(printerController.name!),
                              leading: const Icon(
                                Icons.print_disabled,
                                size: 44,
                                color: Color.fromARGB(255, 194, 194, 194),
                              ),
                              subtitle: Text(
                                printerController.address!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: Get.height / 2.3 - 100,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: printerController.devices.length,
                              itemBuilder: (context, index) {
                                var item = printerController.devices[index];
                                return Obx(
                                  () => GestureDetector(
                                    onTap: () {
                                      printerController.selectedPrinter.value =
                                          index;
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: printerController
                                                    .selectedPrinter.value ==
                                                index
                                            ? const Color.fromARGB(
                                                255, 212, 212, 212)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: ListTile(
                                        title: Text(item.name!),
                                        trailing: printerController.address ==
                                                item.address
                                            ? const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              )
                                            : const SizedBox.shrink(),
                                        leading: const Icon(
                                          Icons.print,
                                          size: 44,
                                          color: Colors.grey,
                                        ),
                                        subtitle: Text(
                                          item.address!,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("size.subtitle".tr),
                                SizedBox(
                                  width: Get.width / 2 - 40,
                                  child: DropdownButtonFormField2(
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    value: printerController.charSize_2,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    // selectedItemHighlightColor:
                                    //     Color.fromARGB(255, 206, 235, 255),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none),
                                    ),
                                    isExpanded: true,
                                    hint: Text(
                                      printerController.charSize_2,
                                      style: const TextStyle(fontSize: 12),
                                    ),

                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black45,
                                        size: 30,
                                      ),
                                    ),
                                    buttonStyleData: const ButtonStyleData(
                                      height: 45,
                                    ), // buttonPadding: const EdgeInsets.only(left: 0, right: 10),
                                    items: const [
                                      DropdownMenuItem<String>(
                                        value: "Petite",
                                        child: Text(
                                          "Petite",
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: "Moyenne",
                                        child: Text(
                                          "Moyenne",
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      printerController.charSize_2 =
                                          value.toString();
                                    },
                                    onSaved: (value) {
                                      printerController.charSize_2 =
                                          value.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("encodage".tr),
                                SizedBox(
                                  width: Get.width / 2 - 40,
                                  child: DropdownButtonFormField2(
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    value: printerController.charset,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    // selectedItemHighlightColor:
                                    //     Color.fromARGB(255, 206, 235, 255),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none),
                                    ),
                                    isExpanded: true,
                                    hint: Text(
                                      printerController.charset,
                                      style: const TextStyle(fontSize: 12),
                                    ),

                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black45,
                                        size: 30,
                                      ),
                                    ),
                                    buttonStyleData: const ButtonStyleData(
                                      height: 45,
                                    ), // buttonPadding: const EdgeInsets.only(left: 0, right: 10),
                                    items:
                                        List.generate(encode.length, (index) {
                                      var item = encode[index];
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }),
                                    onChanged: (value) {
                                      printerController.charset =
                                          value.toString();
                                    },
                                    onSaved: (value) {
                                      printerController.charset =
                                          value.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("printer.size".tr),
                                SizedBox(
                                  width: Get.width / 2 - 40,
                                  child: DropdownButtonFormField2(
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    value: printerController.size,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    // selectedItemHighlightColor:
                                    //     Color.fromARGB(255, 206, 235, 255),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none),
                                    ),
                                    isExpanded: true,
                                    hint: Text(
                                      "${printerController.size}m",
                                      style: const TextStyle(fontSize: 12),
                                    ),

                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black45,
                                        size: 30,
                                      ),
                                    ),
                                    buttonStyleData: const ButtonStyleData(
                                      height: 45,
                                    ), // buttonPadding: const EdgeInsets.only(left: 0, right: 10),

                                    items: List.generate(printerSize.length,
                                        (index) {
                                      var item = printerSize[index];
                                      return DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          "${item}m",
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }),
                                    onChanged: (value) {
                                      printerController.size = value.toString();
                                    },
                                    onSaved: (value) {
                                      printerController.size = value.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
              }),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                width: Get.width,
                height: Get.height / 1.5 - 80 - Get.height / 2,
                child: MaterialButton(
                  onPressed: () async {
                    //
                    if (printerController.selectedPrinter.value != 1000) {
                      await printerController.savePrinter();
                      Get.back();
                    }
                  },
                  color: Colors.blue,
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  child: Text(
                    "save".tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
