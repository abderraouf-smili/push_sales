import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageChat extends StatelessWidget {
  const MessageChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("chat".tr),
        centerTitle: true,
      ),
      body: SizedBox(
        width: Get.width,
        height: Get.height - 120,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            var item = index;
            return ListTile(
              title: Text(item.toString()),
            );
          },
        ),
      ),
    );
  }
}
