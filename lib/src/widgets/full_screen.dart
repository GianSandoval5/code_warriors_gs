// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:code_warriors/src/utils/colors.dart';
// import 'package:flutter/material.dart';

// class DetailScreen extends StatelessWidget {
//   final String foto;
//   final String tag;

//   DetailScreen(this.foto, this.tag);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.darkColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.darkColor,
//         centerTitle: true,
//         title: const Text(
//           'Imagen Completa',
//           style: TextStyle(
//             color: Colors.white,
//             fontFamily: "MonB",
//             fontSize: 20,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Center(
//         child: Hero(
//           tag: tag,
//           child: CachedNetworkImage(
//             imageUrl: foto,
//             imageBuilder: (context, imageProvider) => Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(0),
//                 image: DecorationImage(
//                   image: imageProvider,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//             placeholder: (context, url) => ClipRRect(
//               borderRadius: BorderRadius.circular(0),
//               child: Image.asset(
//                 "assets/gif/vertical.gif",
//                 height: 220,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
