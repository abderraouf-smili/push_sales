import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:push_sale/controllers/actors_controller.dart';
import 'package:push_sale/views/signed/widgets/actors/actor_item.dart';

class ActorsList extends StatelessWidget {
  ActorsController actorsController = Get.put(ActorsController());

  ActorsList({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("my.actors".tr),
        centerTitle: true,
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: actorsController.getActors,
          child: Obx(
            () => ListView.builder(
                itemCount: actorsController.actors.length *
                    (actorsController.loadActors.value ? 1 : 0),
                itemBuilder: (context, index) {
                  var item = actorsController.actors[index];
                  return ActorItem(item);
                }),
          ),
        ),
      ),
    );
  }
}
