// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:synergy/controllers/categorycontroller.dart';
// import 'package:synergy/controllers/productcontroller.dart';
// import 'package:synergy/views/signed/widgets/itemcategory.dart';
// import 'package:synergy/views/signed/widgets/itemproduct.dart';

// class Categories extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: ListCategories(),
//     );
//   }
// }

// class ListCategories extends StatelessWidget {
//   CategoryController catController = Get.put(CategoryController());
//   ProductController proController = Get.put(ProductController());
//   PageController pageController = PageController();

//   @override
//   Widget build(BuildContext context) {
//     int i = 0;
//     return Column(
//       children: [
//         Row(
//           children: [
//             Container(
//               height: 40,
//               width: Get.width - 90,
//               margin: EdgeInsets.symmetric(horizontal: 20),
//               child: TextFormField(
//                 style: TextStyle(
//                   color: Color.fromARGB(255, 99, 99, 99),
//                   fontFamily: 'alata',
//                 ),
//                 // controller: mailController,
//                 decoration: InputDecoration(
//                     contentPadding: EdgeInsets.zero,
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none),
//                     filled: true,
//                     fillColor: Color.fromARGB(255, 235, 235, 235),
//                     prefixIcon: Icon(Icons.search_outlined),
//                     hintText: "search".tr,
//                     hintStyle: TextStyle(fontFamily: "alata")),
//                 onSaved: (value) {},
//               ),
//             ),
//             IconButton(
//                 onPressed: () {
//                   catController.page.value = 4;
//                   pageController.jumpToPage(4);
//                 },
//                 icon: Icon(Icons.signal_cellular_alt_outlined))
//           ],
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 20),
//           width: double.infinity,
//           height: 35,
//           child: Obx(
//             () => ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 MaterialButton(
//                   onPressed: () {
//                     catController.page.value = 0;
//                     pageController.jumpToPage(0);
//                   },
//                   child: Text("general".tr,
//                       style: TextStyle(
//                           fontFamily: "alata",
//                           color: catController.page.value == 0
//                               ? Color.fromARGB(255, 48, 48, 48)
//                               : Color.fromARGB(255, 112, 112, 112),
//                           fontSize: 14,
//                           fontWeight: catController.page.value == 0
//                               ? FontWeight.bold
//                               : FontWeight.normal)),
//                 ),
//                 MaterialButton(
//                   onPressed: () {
//                     catController.page.value = 1;
//                     pageController.jumpToPage(1);
//                   },
//                   child: Text("categories".tr,
//                       style: TextStyle(
//                           fontFamily: "alata",
//                           color: catController.page.value == 1
//                               ? Color.fromARGB(255, 48, 48, 48)
//                               : Color.fromARGB(255, 112, 112, 112),
//                           fontSize: 14,
//                           fontWeight: catController.page.value == 1
//                               ? FontWeight.bold
//                               : FontWeight.normal)),
//                 ),
//                 MaterialButton(
//                   onPressed: () {
//                     catController.page.value = 2;
//                     pageController.jumpToPage(2);
//                   },
//                   child: Text("products".tr,
//                       style: TextStyle(
//                           fontFamily: "alata",
//                           fontSize: 14,
//                           color: catController.page.value == 2
//                               ? Color.fromARGB(255, 48, 48, 48)
//                               : Color.fromARGB(255, 112, 112, 112),
//                           fontWeight: catController.page.value == 2
//                               ? FontWeight.bold
//                               : FontWeight.normal)),
//                 ),
//                 MaterialButton(
//                   onPressed: () {
//                     catController.page.value = 3;
//                     pageController.jumpToPage(3);
//                   },
//                   child: Text("bestselling".tr,
//                       style: TextStyle(
//                           fontFamily: "alata",
//                           fontSize: 14,
//                           color: catController.page.value == 3
//                               ? Color.fromARGB(255, 48, 48, 48)
//                               : Color.fromARGB(255, 112, 112, 112),
//                           fontWeight: catController.page.value == 3
//                               ? FontWeight.bold
//                               : FontWeight.normal)),
//                 ),
//                 MaterialButton(
//                   onPressed: () {
//                     catController.page.value = 4;
//                     pageController.jumpToPage(4);
//                   },
//                   child: Text("promotion".tr,
//                       style: TextStyle(
//                           fontFamily: "alata",
//                           fontSize: 14,
//                           color: catController.page.value == 4
//                               ? Color.fromARGB(255, 48, 48, 48)
//                               : Color.fromARGB(255, 112, 112, 112),
//                           fontWeight: catController.page.value == 4
//                               ? FontWeight.bold
//                               : FontWeight.normal)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Container(
//           height: Get.height - 193,
//           child: PageView(
//             controller: pageController,
//             physics: NeverScrollableScrollPhysics(),
//             children: [
//               Container(
//                   margin: EdgeInsets.symmetric(horizontal: 15),
//                   child: Obx(() {
//                     return !catController.isReady.value
//                         ? Center(
//                             child: Container(
//                               height: 60,
//                               child: Image.asset("assets/images/loading.gif"),
//                             ),
//                           )
//                         : ListView(
//                             padding: EdgeInsets.zero,
//                             physics: BouncingScrollPhysics(),
//                             children: List.generate(
//                               catController.Categories.length,
//                               ((index) => Container(
//                                     width: double.infinity,
//                                     height: (Get.height - 193) / 2.6,
//                                     child: Column(children: [
//                                       Container(
//                                         padding: EdgeInsets.only(
//                                             top: 5, left: 10, right: 10),
//                                         height: 35,
//                                         width: double.infinity,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.only(
//                                             topRight: Radius.circular(40),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           catController.Categories[index]
//                                               .short_description_fr,
//                                           style: TextStyle(
//                                               fontFamily: 'kodchasan',
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: double.infinity,
//                                         height: (Get.height - 193) / 3.3,
//                                         child: ListView(
//                                           physics: BouncingScrollPhysics(),
//                                           scrollDirection: Axis.horizontal,
//                                           children: List.generate(
//                                             catController.Categories[index]
//                                                 .products!.length,
//                                             (i) => Container(
//                                               margin: EdgeInsets.symmetric(
//                                                   horizontal: 5),
//                                               width: 180,
//                                               child: itemProduct(catController
//                                                   .Categories[index]
//                                                   .products![i]),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     ]),
//                                   )),
//                             ),
//                           );
//                   })),
//               Obx(() {
//                 return !catController.isReady.value
//                     ? Center(
//                         child: Container(
//                           height: 60,
//                           child: Image.asset("assets/images/loading.gif"),
//                         ),
//                       )
//                     : Container(
//                         height: Get.height - 70,
//                         child: GridView.builder(
//                             physics: BouncingScrollPhysics(),
//                             padding: EdgeInsets.symmetric(horizontal: 10),
//                             itemCount: catController.Categories.length,
//                             gridDelegate:
//                                 SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               childAspectRatio: 0.9,
//                             ),
//                             itemBuilder: (context, index) {
//                               return itemCategory(
//                                   catController.Categories[index]);
//                             }),
//                       );
//               }),
//               Obx(
//                 () {
//                   return !proController.isReady.value
//                       ? Center(
//                           child: Container(
//                             height: 60,
//                             child: Image.asset("assets/images/loading.gif"),
//                           ),
//                         )
//                       : Container(
//                           height: Get.height - 180,
//                           margin: EdgeInsets.only(top: 10),
//                           child: GridView.builder(
//                               physics: BouncingScrollPhysics(),
//                               padding: EdgeInsets.symmetric(horizontal: 10),
//                               itemCount: proController.Products.length,
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 childAspectRatio: 0.9,
//                               ),
//                               itemBuilder: (context, index) {
//                                 return itemProduct(
//                                     proController.Products[index]);
//                               }),
//                         );
//                 },
//               ),
//               Container(
//                 color: Colors.blue,
//               ),
//               Container(
//                 color: Colors.green,
//               ),
//               Container(
//                 color: Colors.orange,
//                 child: Text("Page filtering"),
//               )
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }
