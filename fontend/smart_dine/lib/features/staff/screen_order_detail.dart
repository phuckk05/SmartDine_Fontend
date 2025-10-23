// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mart_dine/models/completed_order.dart';

// class ScreenOrderDetail extends StatelessWidget {
//   final CompletedOrderModel order;

//   const ScreenOrderDetail({Key? key, required this.order}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final currencyFormatter = NumberFormat.decimalPattern('vi_VN');
//     final timeFormatter = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');

//     // Gom các món ăn giống nhau lại và đếm số lượng
//     final Map<String, dynamic> groupedItems = {};
//     for (var item in order.items) {
//       if (groupedItems.containsKey(item.id)) {
//         groupedItems[item.id]['quantity']++;
//       } else {
//         groupedItems[item.id] = {
//           'item': item,
//           'quantity': 1,
//         };
//       }
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Chi Tiết', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 1,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Thông tin chung
//             Text(
//               'Bàn: ${order.tableName}',
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text('Thời gian in: ${timeFormatter.format(order.checkoutTime)}'),
//             const SizedBox(height: 4),
//             // Lấy 8 ký tự đầu của ID để làm mã đơn cho ngắn gọn
//             Text('Mã đơn: ${order.id.substring(0, 8).toUpperCase()}'),
//             const SizedBox(height: 16),
//             const Divider(),

//             // Danh sách các món ăn
//             Expanded(
//               child: ListView(
//                 children: groupedItems.values.map((data) {
//                   final item = data['item'];
//                   final quantity = data['quantity'];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             'x $quantity  ${item.name}',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                         Text(
//                           '${currencyFormatter.format(item.price * quantity)}đ',
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),

//             // Tổng tiền
//             const Divider(),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Tổng',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${currencyFormatter.format(order.totalAmount)} VNĐ',
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
