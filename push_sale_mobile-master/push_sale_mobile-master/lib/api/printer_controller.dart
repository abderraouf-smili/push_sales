import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:push_sale/models/line_text_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterController extends GetxController {
  RxInt selectedPrinter = 1000.obs;
  RxBool exist = false.obs;

  String? showMessage;
  // List<LineText> listText = [];
  RxString PrinterState = "disconnected".obs;
  List<dynamic> devices = [];
  SharedPreferences? prefs;
  bool isSaved = false;
  String? address;
  String? name;
  String size = "80";
  String charset = "windows-1256";
  String charSize_1 = "Moyenne";
  String charSize_2 = "Petite";
  bool connected = false;

  resetWindow() {
    PrinterState.value = "";
    showMessage = "no printer !";
  }

  Future ScanPrinter() async {
    await initPrinter();
  }

  Future initPrinter() async {
    BlueThermalPrinter bluetoothPrint = BlueThermalPrinter.instance;
    devices = [];
    showMessage = "searching";
    try {
      devices = await bluetoothPrint.getBondedDevices();

      // print("=============>" + devices.first.connected.toString());
    } on PlatformException {}
    await bluetoothPrint.onStateChanged().listen((state) {
      exist.value = devices.isNotEmpty;
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          connected = true;
          PrinterState.value = "connected";
          showMessage = "connected";
          break;
        case BlueThermalPrinter.DISCONNECTED:
          connected = false;
          PrinterState.value = "disconnected";
          showMessage = "disconnected";

          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          connected = false;
          PrinterState.value = "disconnected";
          showMessage = "disconnected";
          // print("bluetooth device state: disconnect requested");

          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          connected = false;
          PrinterState.value = "printer_off";
          showMessage = "printer_off";
          // print("bluetooth device state: bluetooth turning off");

          break;
        case BlueThermalPrinter.STATE_OFF:
          connected = false;
          PrinterState.value = "bluetooth_off";
          showMessage = "bluetooth_off";
          // print("bluetooth device state: bluetooth off");

          break;
        case BlueThermalPrinter.STATE_ON:
          connected = false;
          PrinterState.value = "bluetooth_on";
          showMessage = "bluetooth_on";
          // print("bluetooth device state: bluetooth on");

          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          connected = false;
          PrinterState.value = "bluetooth_on";
          showMessage = "bluetooth_on";
          // print("bluetooth device state: bluetooth turning on");

          break;
        case BlueThermalPrinter.ERROR:
          connected = false;
          PrinterState.value = "error";
          showMessage = "error";
          print("bluetooth device state: error");

          break;
        default:
          print(state);
          break;
      }
    });
  }

  Future savePrinter() async {
    address = devices[selectedPrinter.value].address;
    name = devices[selectedPrinter.value].name;

    prefs = await SharedPreferences.getInstance();
    await prefs!.setBool("isPrinterSaved", true);
    await prefs!.setString("printer_address", address!);
    await prefs!.setString("printer_name", name!);
    await prefs!.setString("printer_size", size);
    await prefs!.setString("printer_charset", charset);
    await prefs!.setString("printer_charSize_1", charSize_1);
    await prefs!.setString("printer_charSize_2", charSize_2);
    isSaved = true;
  }

  Future<String> StartPrinting(List<LineTextPrinter> list) async {
    BlueThermalPrinter bt = BlueThermalPrinter.instance;
    BluetoothDevice _device = BluetoothDevice(name, address);
    if (!(await bt.isConnected)!) {
      try {
        await bt.connect(_device);
      } catch (e) {
        print(e);
        return "unknown";
      }
    }
    if ((await bt.isConnected)!) {
      Printing(bt, list);
      return "ok";
    } else if (!(await bt.isAvailable)!) {
      return "not_available";
    } else {
      return "bluetooth_pb";
    }
    // print(await bt.isConnected);
  }

//0 : 64
//1 :
  void Printing(BlueThermalPrinter bluetooth, List<LineTextPrinter> list) {
    for (LineTextPrinter line in list) {
      if (line.text1 == "") {
        bluetooth.printNewLine();
      } else if (line.text1 == "-") {
        bluetooth.printCustom(
            "------------------------------------------------",
            1,
            LineTextPrinter.CENTER,
            charset: charset);
      } else {
        if (line.type == "Text") {
          if (line.text2 == null) {
            // 1 column
            bluetooth.printCustom(
              line.text1,
              line.isSubTitle
                  ? charSize_2 == "Petite"
                      ? 0
                      : 1
                  : line.size,
              line.align,
              charset: charset,
            );
          } else if (line.text3 == null) {
            // 2 columns
            bluetooth.printLeftRight(
              line.text1,
              line.text2!,
              line.isSubTitle
                  ? charSize_2 == "Petite"
                      ? 0
                      : 1
                  : line.size,
              charset: charset,
              format: line.format,
            );
          } else if (line.text4 == null) {
            // 3 columns
            bluetooth.print3Column(
              line.text1,
              line.text2!,
              line.text3!,
              line.isSubTitle
                  ? charSize_2 == "Petite"
                      ? 0
                      : 1
                  : line.size,
              charset: charset,
              format: line.format,
            );
          } else {
            // 4 columns
            bluetooth.print4Column(
              line.text1,
              line.text2!,
              line.text3!,
              line.text4!,
              line.isSubTitle
                  ? charSize_2 == "Petite"
                      ? 0
                      : 1
                  : line.size,
              charset: charset,
              format: line.format,
            );
          }
        }
        if (line.type == "Code_Qr") {
          print("QR ::::: " + line.text1);
          bluetooth.printQRcode(line.text1, line.size, line.size, line.align);
        }
      }
    }
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.paperCut();
  }

  //
  @override
  void onInit() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs!.getBool("isPrinterSaved") != null &&
        prefs!.getBool("isPrinterSaved") == true) {
      address = prefs!.getString("printer_address");
      name = prefs!.getString("printer_name");
      size = prefs!.getString("printer_size")!;
      charset = prefs!.getString("printer_charset") ?? "windows-1256";
      charSize_1 = prefs!.getString("printer_charSize_1") ?? "Moyenne";
      charSize_2 = prefs!.getString("printer_charSize_2") ?? "Petite";
      isSaved = true;
    }
    super.onInit();
  }
}
