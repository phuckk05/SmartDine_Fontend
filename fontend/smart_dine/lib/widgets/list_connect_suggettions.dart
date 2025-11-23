
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:me_talk/core/style.dart';
// import 'package:me_talk/widgets/modal_bottom_sheet.dart';

// // //providers State
// // final heightProvider = StateProvider<double>((ref) => 40);

// class ListConnectSuggettions extends ConsumerWidget {
//   const ListConnectSuggettions({super.key});

//   //Hiện thị modal
//   void showModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return ModalBottomSheetOfConnect(index: 2);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 10, // Số lượng kết nối giả định
//       itemBuilder: (context, index) {
//         return InkWell(
//           splashColor: Colors.blue.shade100,
//           onTap: () {},
//           child: ListTile(
//             leading: Container(
//               width: 60,
//               height: 60,
//               child: CircleAvatar(
//                 radius: 30,
//                 backgroundImage: AssetImage(
//                   'lib/widgets/list_connect.dart assets/images/LogoApp2.png',
//                 ),
//               ),
//             ),

//             title: Text('Đồng chí x $index', style: Style.fontUsername),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: 5),
//                 SizedBox(
//                   height: 40,
//                   child: TextField(
//                     onTap: () {
//                     },
//                     decoration: InputDecoration(
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       hintText: "Gửi lời kết nối",
//                       hintStyle: Style.fontCaption,
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: const Size(100, 35),
//                           backgroundColor: Colors.blue.shade700,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         onPressed: () {
                         
//                         },
//                         child: Text('Kết nối', style: Style.fontButton),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     OutlinedButton.icon(
//                       onPressed: () {
//                         showModal(context);
//                       },
//                       label: Icon(Icons.more_vert),
//                       style: OutlinedButton.styleFrom(
//                         minimumSize: const Size(35, 35),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ), 
//             onTap: () {},
//           ),
//         );
//       },
//     );
//   }
// }
