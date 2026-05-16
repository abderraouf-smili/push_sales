import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/actor.dart';
import 'package:push_sale/const/globals.dart' as global;

class ActorsController extends GetxController {
  //
  List<Actor> actors = [];
  RxBool loadActors = false.obs;

  Future<void> getActors() async {
    loadActors.value = false;
    actors = [];
    ResponseHttpRequest response = await CallApi.RequestHttp(global.actorsList);
    if (response.status == "SUCCESS") {
      for (var element in response.data) {
        actors.add(Actor.fromMap(element));
      }
      loadActors.value = true;
    } else {
      print(response.message);
    }
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    await getActors();
    super.onInit();
  }
}
