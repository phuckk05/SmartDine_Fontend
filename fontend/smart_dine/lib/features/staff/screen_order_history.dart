// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:mart_dine/features/staff/screen_order_detail.dart'; // ✅ Import màn hình mới
// import 'package:mart_dine/providers/table_provider.dart';

// class ScreenOrderHistory extends ConsumerWidget {
//   const ScreenOrderHistory({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final completedOrders = ref.watch(completedOrdersProvider);
//     final currencyFormatter = NumberFormat.decimalPattern('vi_VN');
//     final timeFormatter = DateFormat('HH:mm dd/MM/yyyy', 'vi_VN');

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Lịch sử tạo bàn', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         actions: [
//           IconButton(
//             onPressed: () {
//               // TODO: Thêm logic để lọc theo ngày
//             },
//             icon: const Icon(Icons.calendar_today, color: Colors.black),
//             tooltip: 'Lọc theo ngày',
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
//             child: Text(
//               'Tất cả lịch sử lấy món',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: completedOrders.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'Chưa có đơn hàng nào được thanh toán.',
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     itemCount: completedOrders.length,
//                     itemBuilder: (context, index) {
//                       final order = completedOrders[completedOrders.length - 1 - index];
                      
//                       // ✅ Bọc mục danh sách bằng InkWell để có thể nhấn vào
//                       return InkWell(
//                         onTap: () {
//                           // Điều hướng đến màn hình chi tiết và truyền dữ liệu đơn hàng
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ScreenOrderDetail(order: order),
//                             ),
//                           );
//                         },
//                         borderRadius: BorderRadius.circular(12),
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 12.0),
//                           padding: const EdgeInsets.all(16.0),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.grey.shade300),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.check_circle,
//                                 color: Colors.green,
//                                 size: 32,
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Bàn : ${order.tableName}',
//                                       style: const TextStyle(fontWeight: FontWeight.bold),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text('Số món ăn : ${order.items.length}'),
//                                     const SizedBox(height: 4),
//                                     Text('Giá : ${currencyFormatter.format(order.totalAmount)} VNĐ'),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       timeFormatter.format(order.checkoutTime),
//                                       style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }