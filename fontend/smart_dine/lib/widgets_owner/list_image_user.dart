// import 'package:flutter/material.dart';
// import 'package:me_talk/core/style.dart';

// class ListImageUser extends StatelessWidget {
//   const ListImageUser({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
//           child: Align(
//             alignment: Alignment.centerLeft,
//             child: Text('Ảnh', style: Style.fontTitleMini),
//           ),
//         ),
//         SizedBox(
//           height: 120,
//           child: ListView.builder(
//             physics: const AlwaysScrollableScrollPhysics(),
//             shrinkWrap: true,
//             scrollDirection: Axis.horizontal,
//             itemCount: 10,
//             itemBuilder: (context, index) {
//               return Padding(
//                 padding: const EdgeInsets.only(
//                   left: Style.paddingPhone,
//                   right: 0,
//                   top: 5,
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.asset(
//                     'lib/widgets/list_connect.dart assets/images/LogoApp2.png',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
