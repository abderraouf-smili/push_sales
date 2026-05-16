// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:synergy/models/product.dart';

// class itemProduct extends StatelessWidget {
//   final Product product;
//   itemProduct(this.product);
//   @override
//   Widget build(BuildContext context) {
//     final borderColor = [
//       Color.fromARGB(255, 235, 215, 187),
//       Color.fromARGB(255, 214, 179, 176),
//       Color.fromARGB(255, 161, 182, 199),
//       Color.fromARGB(255, 178, 207, 179),
//       Color.fromARGB(255, 196, 173, 196),
//       Color.fromARGB(255, 195, 197, 159),
//       Color.fromARGB(255, 185, 185, 185),
//     ];
//     final boxColor = [
//       Color.fromARGB(255, 255, 252, 247),
//       Color.fromARGB(255, 255, 248, 248),
//       Color.fromARGB(255, 245, 251, 255),
//       Color.fromARGB(255, 236, 252, 236),
//       Color.fromARGB(255, 255, 243, 255),
//       Color.fromARGB(255, 254, 255, 244),
//       Color.fromARGB(255, 243, 243, 243),
//     ];
//     int ind = product.id % borderColor.length;
//     return InkWell(
//       // onTap: () => Get.to(() => ProductDetail(product: product)),
//       child: Container(
//         margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         child: Container(
//           decoration: BoxDecoration(
//             color: boxColor[ind],
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(color: borderColor[ind]),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
//                 height: 150,
//                 decoration: BoxDecoration(
//                   // color: Colors.white,
//                   borderRadius: BorderRadius.circular(5),
//                   image: DecorationImage(
//                     image: CachedNetworkImageProvider(
//                       product.image,
//                       cacheManager: CacheManager(
//                         Config(
//                           product.id.toString(),
//                           stalePeriod: const Duration(days: 7),
//                         ),
//                       ),
//                     ),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//               Container(
//                 child: Text(
//                   product.short_description_fr,
//                   style: TextStyle(fontFamily: "alata", fontSize: 16),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
