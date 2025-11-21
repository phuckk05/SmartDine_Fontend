// import 'package:flutter/material.dart';
// import 'package:me_talk/core/style.dart';
// import 'package:me_talk/widgets/modal_bottom_sheet.dart';

// class ListConnect extends StatelessWidget {
//   const ListConnect({super.key});

//   //Hiện thị modal
//   void showModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return ModalBottomSheetOfConnect(index: 1);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 10, // Số lượng kết nối giả định
//       itemBuilder: (context, index) {
//         return InkWell(
//           splashColor: Colors.blue.shade100,
//           onTap: () {},
//           child: ListTile(
//             // leading: Container(
//             //   width: 60,
//             //   height: 60,
//             //   child: CircleAvatar(
//             //     radius: 30,
//             //     backgroundImage: AssetImage(
//             //       'assets/images/logoApp.png',
//             //     ),
//             //   ),
//             // ),
//             title: Text('Đồng chí x $index', style: Style.fontUsername),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Mô tả kết nối $index', style: Style.fontCaption),
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
//                           // Thực hiện hành động khi nhấn nút kết nối
//                         },
//                         child: Text('Chấp nhận', style: Style.fontButton),
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
