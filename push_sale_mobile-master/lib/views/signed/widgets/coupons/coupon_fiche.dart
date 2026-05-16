import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/controllers/coupon_controller.dart';
import 'package:push_sale/models/coupon.dart';
import 'package:push_sale/views/signed/widgets/coupons/coupons_list.dart';

class CouponFiche extends StatelessWidget {
  Coupon? coupon;
  CouponFiche(this.coupon);

  TextEditingController couponDescriptionController = TextEditingController();
  TextEditingController couponCodeController = TextEditingController();
  TextEditingController couponDiscountController = TextEditingController();
  TextEditingController couponCountController = TextEditingController();
  TextEditingController couponDateStartController = TextEditingController();
  TextEditingController couponDateEndController = TextEditingController();
  TextEditingController couponMinController = TextEditingController();
  DateTime? date_start;
  DateTime? date_end;
  CouponController couponController = Get.find();

  @override
  Widget build(BuildContext context) {
    couponController.start_date_selected.value = false;
    couponController.end_date_selected.value = false;
    couponController.sendMode = "create";
    couponController.coupon_id = null;
    if (coupon != null) {
      couponController.coupon_id = coupon!.id;
      couponController.sendMode = "update";
      couponDescriptionController.text = coupon!.description;
      couponCodeController.text = coupon!.code;
      couponDiscountController.text = coupon!.discount.toStringAsFixed(0);
      couponCountController.text = coupon!.count.toStringAsFixed(0);
      couponMinController.text = coupon!.min_amount.toStringAsFixed(0);
    }
    couponController.CouponFormKey = GlobalKey<FormState>();
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(coupon != null ? coupon!.description : "new.coupon".tr),
        centerTitle: true,
        backgroundColor: coupon != null ? Colors.red : Colors.green,
        shadowColor: Colors.grey,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: Get.height - 100,
            child: Form(
              key: couponController.CouponFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Center(
                          child: Column(
                        children: [
                          Text(
                            "coupon.settings".tr,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 25,
                                fontFamily: 'alata'),
                          ),
                          Container(
                            width: Get.width / 2,
                            child: Divider(thickness: 1),
                          )
                        ],
                      )),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              date_start = await showDatePicker(
                                locale: Locale(Get.deviceLocale!.languageCode),
                                context: context,
                                initialDate:
                                    DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date_start != null) {
                                couponController.setStartDate(date_start!);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      width: 1,
                                      color: const Color.fromARGB(
                                          255, 214, 214, 214))),
                              child: Obx(
                                () => Text(
                                  DateFormat('dd/MM/y').format(
                                      couponController.start_date_selected.value
                                          ? couponController.start_date!
                                          : coupon != null
                                              ? coupon!.start_date
                                              : DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(
                                        255, 122, 122, 122),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () async {
                              date_end = await showDatePicker(
                                locale: Locale(Get.deviceLocale!.languageCode),
                                context: context,
                                initialDate:
                                    DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date_end != null) {
                                couponController.setEndDate(date_end!);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      width: 1,
                                      color: const Color.fromARGB(
                                          255, 214, 214, 214))),
                              child: Obx(
                                () => Text(
                                  DateFormat('dd/MM/y').format(
                                      couponController.end_date_selected.value
                                          ? couponController.end_date!
                                          : coupon != null
                                              ? coupon!.end_date
                                              : DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(
                                        255, 122, 122, 122),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      validator: ((value) {
                        if (value == null || value == "") {
                          return "empty.not.allowed".tr;
                        }
                        return null;
                      }),
                      onSaved: (value) {
                        couponController.coupon_description = value!;
                      },
                      controller: couponDescriptionController,
                      maxLines: 1,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "description".tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      validator: ((value) {
                        if (value == null || value == "") {
                          return "empty.not.allowed".tr;
                        }
                        return null;
                      }),
                      controller: couponCodeController,
                      maxLines: 1,
                      onSaved: (value) {
                        couponController.coupon_code = value!;
                      },
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "code".tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      validator: ((value) {
                        if (value == null || value == "") {
                          return "empty.not.allowed".tr;
                        }
                        return null;
                      }),
                      keyboardType: TextInputType.number,
                      controller: couponMinController,
                      maxLines: 1,
                      onSaved: (value) {
                        couponController.coupon_minimum = double.parse(value!);
                      },
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "minimum".tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      validator: ((value) {
                        if (value == null || value == "") {
                          return "empty.not.allowed".tr;
                        }
                        return null;
                      }),
                      onSaved: (value) {
                        couponController.coupon_discount = int.parse(value!);
                      },
                      keyboardType: TextInputType.number,
                      controller: couponDiscountController,
                      maxLines: 1,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "discount".tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      validator: ((value) {
                        if (value == null || value == "") {
                          return "empty.not.allowed".tr;
                        }
                        return null;
                      }),
                      keyboardType: TextInputType.number,
                      controller: couponCountController,
                      maxLines: 1,
                      onSaved: (value) {
                        couponController.coupon_count = int.parse(value!);
                      },
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "count".tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Obx(
                      () => MaterialButton(
                        height: 45,
                        minWidth: Get.width,
                        elevation: 5,
                        color: Colors.blue,
                        onPressed: () async {
                          couponController.start_date =
                              date_start ?? DateTime.now();
                          couponController.end_date =
                              date_end ?? DateTime.now();
                          var response = await couponController.save();
                          if (response != "success") {
                            //
                            Flushbar(
                              title: "coupon".tr + " " + "error".tr,
                              message: response,
                              titleColor: Color.fromARGB(255, 255, 255, 255),
                              messageColor: Color.fromARGB(255, 253, 254, 255),
                              duration: Duration(seconds: 3),
                              icon: Icon(Icons.check,
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              backgroundColor:
                                  Color.fromARGB(255, 122, 122, 122),
                              flushbarPosition: FlushbarPosition.TOP,
                              borderRadius: BorderRadius.circular(10),
                              // borderColor: Color.fromARGB(255, 186, 224, 255),
                            )..show(context);
                          } else {
                            couponController.getCouponns();
                            Get.off(() => CouponsList());
                            Get.back();
                            couponController.send.value = "new";
                            Flushbar(
                              title: "success".tr,
                              message: "successfully.saved".tr,
                              titleColor: Color.fromARGB(255, 255, 255, 255),
                              messageColor: Color.fromARGB(255, 253, 254, 255),
                              duration: Duration(seconds: 3),
                              icon: Icon(Icons.check,
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              backgroundColor:
                                  Color.fromARGB(255, 122, 122, 122),
                              flushbarPosition: FlushbarPosition.TOP,
                              borderRadius: BorderRadius.circular(10),
                              // borderColor: Color.fromARGB(255, 186, 224, 255),
                            )..show(context);
                          }
                        },
                        child: couponController.send.value == "new"
                            ? Text(
                                "save".tr,
                                style: TextStyle(color: Colors.white),
                              )
                            : couponController.send.value == "sent"
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : couponController.send.value == "success"
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                    : Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
