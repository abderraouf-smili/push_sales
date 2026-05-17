import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/product.dart';
import 'package:push_sale/models/promotion.dart';
import 'package:push_sale/models/promotion_lines.dart';
import 'package:push_sale/models/variant.dart';
import 'package:uuid/uuid.dart';

class PromotionController extends GetxController {
  RxBool start_date_selected = false.obs;
  RxBool end_date_selected = false.obs;
  RxString promo_type = "discount_price".obs;
  RxBool listIsReady = false.obs;
  RxBool saved = false.obs;

  String? promotionId;
  String description = "";
  DateTime? start_date;
  DateTime? end_date;

  List<Promotion> promotions = [];

  List<PromotionLines> items = [];

  Product? product;
  Variant? variant;

  RxString promoCateg = "product".obs;
  int pourcentage = 1;
  RxInt pro_sel_tile = 0.obs;
  RxInt var_sel_tile = 0.obs;
  int minimum = 1;
  String unite = "Pcs";

  Future<void> getPromotions() async {
    promotions = [];

    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.promotionsList,
    );
    if (response.status == "SUCCESS") {
      for (var element in response.data) {
        promotions.add(Promotion.fromMap(element));
      }
    } else {
      print(response.message);
    }
    listIsReady.value = true;
  }

  void setStartDate(DateTime d) {
    start_date_selected.value = false;
    start_date = d;
    start_date_selected.value = true;
  }

  void setEndDate(DateTime d) {
    end_date_selected.value = false;
    end_date = d;
    end_date_selected.value = true;
  }

  void addItem() {
    listIsReady.value = false;
    print(minimum);
    items.add(PromotionLines(
      id: generateId(),
      discount: double.parse(pourcentage.toString()),
      minimum: double.parse(minimum.toString()),
      unite: unite,
      category: null,
      product: promoCateg.value == "product" ? product : null,
      variant: promoCateg.value == "variant" ? variant : null,
    ));
    product = null;
    variant = null;
    listIsReady.value = true;
  }

  void removeItem(PromotionLines item) {
    items.removeWhere((element) => element.id == item.id);
  }

  Future<bool> save() async {
    //
    Promotion promo = Promotion(
      id: promotionId!,
      description: description,
      start_date: start_date!,
      end_date: end_date!,
      image: "",
      type_promotion: null,
      typepv: null,
      lines: items,
      type_promotion_id: promo_type.value == "discount_price" ? 1 : 2,
    );
    print(promo.toMap());
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.savePromotion, data: promo.toMap());

    if (response.status == "SUCCESS") {
      saved.value = true;
      return true;
    } else {
      print(response.message);
      return false;
    }
  }

  String generateId() {
    Uuid uuid = const Uuid();
    return uuid.v1();
  }

  void generatePromoId() {
    promotionId = generateId();
  }
}
