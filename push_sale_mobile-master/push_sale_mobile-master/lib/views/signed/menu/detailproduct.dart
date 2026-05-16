// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:get/get.dart';
// import 'package:synergy/controllers/variantcontroller.dart';
// import 'package:synergy/models/product.dart';

// class ProductDetail extends StatelessWidget {
//   PageController _pageController = PageController(initialPage: 1);
//   VariantController varcontroller = Get.put(VariantController());

//   Product product;
//   ProductDetail({required this.product});

//   @override
//   Widget build(BuildContext context) {
//     return ShowVariant(
//       product: product,
//     );
//   }
// }

// class LoadingPage extends StatelessWidget {
//   const LoadingPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Image.asset("assets/images/loading.gif"),
//     );
//   }
// }

// class ShowVariant extends StatelessWidget {
//   VariantController varcontroller = Get.put(VariantController());

//   Product product;
//   ShowVariant({required this.product});
//   @override
//   Widget build(BuildContext context) {
//     return ListView(physics: NeverScrollableScrollPhysics(), children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             margin: EdgeInsets.only(left: 3, top: 5),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Image.asset(
//                 "assets/images/synergy_blue.png",
//                 width: Get.width / 4,
//               ),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               border:
//                   Border.all(width: 1, color: Color.fromARGB(255, 6, 33, 182)),
//               image: DecorationImage(
//                   image: AssetImage(
//                 "assets/images/avatar.png",
//               )),
//             ),
//           )
//         ],
//       ),
//       Obx(() {
//         return Container(
//           color: Color.fromARGB(255, 243, 249, 255),
//           height: Get.height - 80 - 30 - 40 - 28,
//           child: ListView(
//             physics: BouncingScrollPhysics(),
//             children: [
//               Container(
//                 height: Get.height / 4,
//                 margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: CachedNetworkImage(
//                   cacheManager: CacheManager(
//                     Config(
//                       varcontroller.index.value >= 0
//                           ? "v-" + varcontroller.variant!.id.toString()
//                           : "p-" + product.id.toString(),
//                       stalePeriod: const Duration(days: 7),
//                     ),
//                   ),
//                   imageUrl: varcontroller.index.value >= 0
//                       ? varcontroller.variant!.image
//                       : product.image,
//                   placeholder: (context, url) =>
//                       Center(child: Image.asset("assets/images/loading.gif")),
//                   errorWidget: (context, url, error) => Icon(Icons.error),
//                 ),
//               ),
//               Container(
//                 height: Get.height / 10,
//                 margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
//                 child: Text(
//                   product
//                       .long_description_fr, // <------------------------- long description
//                 ),
//               ),
//               Container(
//                 height: 50,
//                 margin: EdgeInsets.symmetric(horizontal: 20),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Color.fromARGB(255, 16, 9, 85)),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Container(
//                       child: Text(
//                         "Product rating ", // <------------------------- price
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color.fromARGB(255, 255, 255, 255)),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.star,
//                           color: Colors.white,
//                         ),
//                         Icon(
//                           Icons.star,
//                           color: Colors.white,
//                         ),
//                         Icon(
//                           Icons.star,
//                           color: Colors.white,
//                         ),
//                         Icon(
//                           Icons.star,
//                           color: Color.fromARGB(255, 104, 104, 104),
//                         ),
//                         Icon(
//                           Icons.star,
//                           color: Color.fromARGB(255, 104, 104, 104),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Divider(
//                 height: 10,
//                 endIndent: 40,
//                 indent: 40,
//               ),
//               Container(
//                 width: Get.width - 60,
//                 height: 45,
//                 margin: EdgeInsets.symmetric(horizontal: 40),
//                 child: GridView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: product.variants!.length,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 1,
//                         mainAxisSpacing: 10,
//                         childAspectRatio: 0.4),
//                     itemBuilder: (context, index) {
//                       return Container(
//                         margin: EdgeInsets.symmetric(vertical: 3),
//                         child: MaterialButton(
//                           color: varcontroller.index.value >= 0 &&
//                                   varcontroller.variant!.id ==
//                                       product.variants![index].id
//                               ? Color.fromARGB(255, 225, 232, 255)
//                               : null,
//                           shape: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           onPressed: () {
//                             varcontroller.changeTovariant(
//                                 product.variants![index], index);
//                           },
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 product.variants![index]
//                                     .variant1_fr, // <------------------------- Variant option
//                                 style: TextStyle(fontSize: 12),
//                               ),
//                               Text(
//                                 "${product.variants![index].sale_price} DA",
//                                 style: TextStyle(
//                                     color: Color.fromARGB(255, 253, 57, 221)),
//                               )
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 40),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Container(
//                         child: Text(
//                           "Quantité : ",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         IconButton(
//                             onPressed: () {},
//                             icon: Icon(
//                               Icons.remove_circle_outline,
//                               color: Colors.grey[400],
//                             )),
//                         Text("01"),
//                         IconButton(
//                             onPressed: () {},
//                             icon: Icon(
//                               Icons.add_circle_sharp,
//                               color: Colors.grey[400],
//                             )),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               Divider(
//                 height: 10,
//                 endIndent: 40,
//                 indent: 40,
//               ),
//               Align(
//                   alignment: Alignment.centerLeft,
//                   child: Container(
//                       margin: EdgeInsets.symmetric(horizontal: 40),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Montant :",
//                             style: TextStyle(
//                                 fontSize: 25, fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             "250 DA",
//                             style: TextStyle(
//                                 fontSize: 25,
//                                 color: Color.fromARGB(255, 253, 57, 221),
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ))),
//               SizedBox(
//                 height: 15,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   MaterialButton(
//                     textColor: Colors.white,
//                     shape: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     height: 40,
//                     minWidth: 150,
//                     color: Color.fromARGB(255, 24, 64, 151),
//                     onPressed: () {
//                       Get.back();
//                     },
//                     child: Text("Retour"),
//                   ),
//                   SizedBox(
//                     width: 10,
//                   ),
//                   MaterialButton(
//                     textColor: Colors.white,
//                     shape: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     height: 40,
//                     minWidth: 150,
//                     color: Color.fromARGB(255, 207, 43, 180),
//                     onPressed: () {},
//                     child: Text("Ajouter au panier"),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 40,
//               )
//             ],
//           ),
//         );
//       })
//     ]);
//   }
// }
