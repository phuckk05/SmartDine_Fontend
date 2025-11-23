
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
// import 'package:flutter/material.dart';

// class ModalBottomSheetOfConnect extends StatelessWidget {
//   const ModalBottomSheetOfConnect({
//     super.key,
//     required this.index
//   });

//   final int? index; 
  
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       height: 100,
//       width: double.infinity,
//       child: Column(
//         children: [
//           SizedBox(height: 10),
//           InkWell(
//             onTap: () {
//               Navigator.of(context).pop();
//             },
//             child: Container(
//               height: 5,
//               width: 50,
//               decoration: BoxDecoration(
//                 color: Colors.grey[500],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//           SizedBox(height: 10),
//           ListTile(
//             leading: Icon(FluentIcons.person_delete_24_filled),
//             title: Text(index==1?'Xóa':index==2?'Gỡ':'Hủy kết nối'),
//             onTap: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
