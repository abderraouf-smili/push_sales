// import 'package:get/get.dart';
// import 'package:synergy/api/synergyapi.dart';
// import 'package:synergy/models/category.dart';
// import 'package:synergy/models/product.dart';
// import 'package:synergy/models/variant.dart';

// class CategoryController extends GetxController {
//   RxBool isReady = false.obs;
//   RxInt page = 0.obs;
//   SynergyApi api = SynergyApi();
//   List<Category> Categories = [];
//   //
//   //
//   //
//   //
//   getCategories() async {
//     var responseApi = await api.getCategories();
//     if (responseApi[0]["status"] == null) {
//       for (var item in responseApi) {
//         Category cat = Category.fromMap(item);
//         List<Product> products = [];
//         for (var _pro in item["products"]) {
//           Product _p = Product.fromMap(_pro);
//           List<Variant> variants = [];
//           for (var _var in _pro["variants"]) {
//             variants.add(Variant.fromMap(_var));
//           }
//           _p.variants = variants;
//           products.add(_p);
//         }
//         cat.products = products;
//         Categories.add(cat);
//       }
//       // } else {
//       // print(responseApi);
//     }
//   }

//   @override
//   void onInit() async {
//     await getCategories();
//     print(Categories[1].products![0].short_description_fr);
//     isReady.value = true;
//     super.onInit();
//   }
// }
