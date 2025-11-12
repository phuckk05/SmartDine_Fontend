// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mart_dine/core/style.dart';
// import 'package:mart_dine/features/staff/screen_choose_table.dart';
// import 'package:mart_dine/features/cashier/screen_payment.dart';
// import 'package:mart_dine/routes.dart';

// class ScreenRoleSelection extends ConsumerWidget {
//   const ScreenRoleSelection({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       backgroundColor: Style.backgroundColor,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Logo và tên app
//               Column(
//                 children: [
//                   Text(
//                     'SmartDine',
//                     style: TextStyle(
//                       fontSize: Style.headingFontSize,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                       fontFamily: Style.fontFamily,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Chọn vai trò của bạn',
//                     style: TextStyle(
//                       fontSize: Style.defaultFontSize,
//                       color: Style.textColorGray,
//                       fontFamily: Style.fontFamily,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 60),

//               // Button Nhân viên
//               _buildRoleButton(
//                 context,
//                 icon: Icons.restaurant_menu,
//                 title: 'Nhân viên',
//                 subtitle: 'Phục vụ và quản lý bàn',
//                 onPressed: () {
//                   Routes.pushRightLeftConsumerFul(
//                     context,
//                         const ScreenChooseTable(role: 1), // Nhân viên
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),

//               // Button Thu ngân
//               _buildRoleButton(
//                 context,
//                 icon: Icons.payment,
//                 title: 'Thu ngân',
//                 subtitle: 'Thanh toán và quản lý hóa đơn',
//                 onPressed: () {
//                   // For now, navigate to table selection for cashier
//                   // Later this can be modified to go to a cashier-specific screen
//                   Routes.pushRightLeftConsumerFul(
//                     context,
//                     const ScreenChooseTable(role: 2), // Thu ngân
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRoleButton(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       width: double.infinity,
//       height: 120,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(icon, size: 30, color: Colors.blue.shade700),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         title,
//                         style: Style.fontTitle.copyWith(
//                           fontSize: 18,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         subtitle,
//                         style: Style.fontNormal.copyWith(
//                           fontSize: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   size: 20,
//                   color: Colors.grey.shade400,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
