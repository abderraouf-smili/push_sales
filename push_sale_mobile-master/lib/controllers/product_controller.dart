import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/client.dart';
import 'package:push_sale/models/product.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/variant.dart';

class ProductController extends GetxController {
  RxBool ready = false.obs;
  RxBool selectedVariantReady = false.obs;
  RxInt page = 0.obs;

  RxBool isProSelected = false.obs;
  Product? productSelected;
  List<Product> listProducts = [];

  RxBool opt1 = false.obs;
  List<dynamic> option1 = [];
  var selectedVariant;

  String filter = "";

  Client? client;

  RxBool loadVariantReady = false.obs;
  RxBool loadProductReady = false.obs;
  // List<Promotion> listPromotions = [];
  List<Variant> listVariant = [];
  List<PromoShow> listPromo = [];

  // or catalogue show list
  RxBool CatalogueReady = false.obs;
  List<Product> listCatalogue = [];
  //

  Future<void> getVariants() async {
    listVariant = [];
    // print("call api --------------- VARIANT");
    loadVariantReady.value = false;
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.fullVariant,
    );

    if (response.status == "SUCCESS") {
      listVariant = [];
      for (var element in response.data) {
        listVariant.add(Variant.fromMap(element));
      }
      loadVariantReady.value = true;
    }
  }

  Future<void> getPurchaseVariants() async {
    listVariant = [];
    print("call api --------------- PURCHASE VARIANT");
    loadVariantReady.value = false;
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.purchasevariantList,
    );

    if (response.status == "SUCCESS") {
      listVariant = [];
      for (var element in response.data) {
        listVariant.add(Variant.fromMap(element));
      }
      loadVariantReady.value = true;
    } else {
      print(response.message);
    }
  }

  Future<void> getFullPromotion() async {
    print("call Full Promotions --------------");
    List<PromoShow> list = [];
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.fullPromotion, data: {
      "typepv_id": client!.typepv!.id,
    });
    if (response.status == "SUCCESS") {
      for (var item in response.data) {
        list.add(
          PromoShow(
            description: item["description"],
            discount: double.parse(item["discount"].toString()),
            image: item["category"] != null
                ? "${global.urlAPI}${item["category"]["image"] == null || item["category"]["image"] == "" ? "/storage/products/no_image.png" : item["category"]["image"]}"
                : item["product"] != null
                    ? "${global.urlAPI}${item["product"]["image"] == null || item["product"]["image"] == "" ? "/storage/products/no_image.png" : item["product"]["image"]}"
                    : "${global.urlAPI}${item["variant"]["image"] == null || item["variant"]["image"] == "" ? "/storage/products/no_image.png" : item["variant"]["image"]}",
            product: item["category"] != null
                ? item["category"]["short_description_fr"]
                : item["product"] != null
                    ? item["product"]["short_description_fr"]
                    : item["variant"]["variant1_fr"] +
                        " " +
                        item["variant"]["variant2_fr"],
          ),
        );
      }
    } else {
      print(response.message);
    }
    loadVariantReady.value = true;
    listPromo = list;
  }

  List<Variant> getPromotions() {
    var list = listVariant;
    list = listVariant
        .where((element) => element.promotion_typepv_id == client!.typepv!.id)
        .toList();
    return list;
  }

  Future<void> getProducts() async {
    loadProductReady.value = false;
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.productsList,
      data: client == null
          ? null
          : {
              "typepv_id": client!.typepv!.id,
            },
    );

    if (response.status == "SUCCESS") {
      listProducts = [];
      for (var element in response.data) {
        Product tmpPro = Product.fromMap(element);
        if ((tmpPro.variants != null && tmpPro.variants!.isNotEmpty) ||
            (tmpPro.purchasevariants != null &&
                tmpPro.purchasevariants!.isNotEmpty)) {
          listProducts.add(tmpPro);
        }
      }
      loadProductReady.value = true;
    }
  }

  List<Variant> getVariantsLowPrice() {
    List<Variant> variants = [];
    for (int i = 0; i < productSelected!.variants!.length; i++) {
      Variant tmp = productSelected!.variants![i];
      for (int j = i + 1; j < productSelected!.variants!.length; j++) {
        if (productSelected!.variants![i].id ==
            productSelected!.variants![j].id) {
          if (tmp.price * (1 - tmp.discount / 100) >
              productSelected!.variants![j].price *
                  (1 - productSelected!.variants![j].discount / 100)) {
            tmp = productSelected!.variants![j];
          }
        }
      }
      if (variants.where((element) => element.id == tmp.id).length != 1) {
        variants.add(tmp);
      }
    }
    return variants;
  }

  List<String> getOption(List<dynamic> variants, int level) {
    List<String> ret = [];
    for (var item in variants) {
      if (level == 1) {
        if (!ret.contains(item.getVariantName1(Get.locale!.languageCode))) {
          ret.add(item.getVariantName1(Get.locale!.languageCode));
        }
      }
      if (level == 2) {
        if (!ret.contains(item..getVariantName2(Get.locale!.languageCode))) {
          ret.add(item..getVariantName2(Get.locale!.languageCode));
        }
      }
    }
    return ret;
  }

  // Future<void> loadCatlogue() async {
  //   //
  //   CatalogueReady.value = false;
  //   ResponseHttpRequest response = await CallApi.RequestHttp(
  //     global.productsList,
  //   );
  //   print(response.data);
  //   if (response.status == "SUCCESS") {
  //     listCatalogue = [];
  //     for (var element in response.data) {
  //       listCatalogue.add(Product.fromMap(element));
  //     }
  //     CatalogueReady.value = true;
  //   }
  // }
}

class PromoShow {
  final String description;
  final String product;
  final String image;
  final double discount;

  PromoShow(
      {required this.description,
      required this.image,
      required this.discount,
      required this.product});
}
