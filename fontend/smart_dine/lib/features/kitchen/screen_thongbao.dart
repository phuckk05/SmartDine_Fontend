// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/style.dart';
// import '../../models/item.dart';
// import '../../providers/thongbao_provider.dart';
// import '../../providers/kitchen_amthanh_providers.dart';

// class NotificationScreen extends ConsumerWidget {
//   const NotificationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final notifications = ref.watch(notificationsProvider);
//     final unreadCount = ref.watch(unreadCountProvider);

//     final screenWidth = MediaQuery.of(context).size.width;
//     final isWeb = screenWidth > 600;

//     return Scaffold(
//       backgroundColor: Style.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.blue[700],
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             Text(
//               'Thông báo món',
//               style: Style.fontTitle.copyWith(
//                 color: Style.textColorWhite,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             if (unreadCount > 0) ...[
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '$unreadCount',
//                   style: Style.fontCaption.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//         actions: [
//           if (unreadCount > 0)
//             TextButton(
//               onPressed: () {
//                 ref.read(markAllAsReadProvider)();
//               },
//               child: Text(
//                 'Đánh dấu tất cả',
//                 style: Style.fontNormal.copyWith(
//                   color: Colors.white,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Header với count
//           Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: isWeb ? 20 : Style.paddingPhone,
//               vertical: 12,
//             ),
//             color: Style.colorLight,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Tất cả thông báo',
//                   style: Style.fontTitleSuperMini.copyWith(
//                     fontSize: isWeb ? 16 : 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[700],
//                     borderRadius: BorderRadius.circular(Style.borderRadius),
//                   ),
//                   child: Text(
//                     '${notifications.length}',
//                     style: Style.fontTitleSuperMini.copyWith(
//                       color: Style.textColorWhite,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // List
//           Expanded(
//             child:
//                 notifications.isEmpty
//                     ? _buildEmptyState()
//                     : ListView.builder(
//                       padding: EdgeInsets.all(isWeb ? 20 : Style.paddingPhone),
//                       itemCount: notifications.length,
//                       itemBuilder: (context, index) {
//                         return _buildNotificationCard(
//                           ref,
//                           notifications[index],
//                           isWeb,
//                         );
//                       },
//                     ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ==================== BUILD METHODS ====================

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: Style.spacingMedium),
//           Text(
//             'Không có thông báo',
//             style: Style.fontTitleMini.copyWith(color: Style.textColorGray),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotificationCard(
//     WidgetRef ref,
//     OrderNotification notification,
//     bool isWeb,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(isWeb ? 16 : 14),
//       decoration: BoxDecoration(
//         color: notification.isRead ? Colors.grey[100] : Style.colorLight,
//         borderRadius: BorderRadius.circular(Style.cardBorderRadius),
//         border: Border.all(
//           color: notification.isRead ? Colors.grey[300]! : Colors.blue[200]!,
//           width: notification.isRead ? 1 : 2,
//         ),
//         boxShadow: [
//           if (!notification.isRead)
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header: Tên món + bàn
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       notification.dishName,
//                       style: Style.fontTitleMini.copyWith(
//                         fontSize: isWeb ? 16 : 15,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Text(
//                           'Giờ tạo: ${notification.createdTime}',
//                           style: Style.fontCaption.copyWith(
//                             fontSize: isWeb ? 13 : 12,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Text(
//                           'Bàn: ${notification.tableNumber}',
//                           style: Style.fontCaption.copyWith(
//                             fontSize: isWeb ? 13 : 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[700],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               if (!notification.isRead)
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: const BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//             ],
//           ),

//           if (notification.note != null && notification.note!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Text(
//               'Ghi chú: ${notification.note}',
//               style: Style.fontCaption.copyWith(
//                 fontSize: isWeb ? 13 : 12,
//                 color: Colors.orange[700],
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ],

//           const SizedBox(height: 12),

//           // Actions
//           _buildNotificationActions(ref, notification, isWeb),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotificationActions(
//     WidgetRef ref,
//     OrderNotification notification,
//     bool isWeb,
//   ) {
//     // Món mới - 2 buttons
//     if (notification.type == NotificationType.newOrder) {
//       return Row(
//         children: [
//           Expanded(
//             child: _buildActionButton(
//               label: notification.type.actionText,
//               color: notification.type.getActionColor(),
//               onPressed: () => _handleConfirmOrder(ref, notification),
//               isWeb: isWeb,
//             ),
//           ),
//           // Bỏ nút "Hết Nguyên Liệu"
//         ],
//       );
//     }

//     // Món đã xong - 2 buttons
//     if (notification.type == NotificationType.orderReady) {
//       return Row(
//         children: [
//           const SizedBox(width: 8),
//           Expanded(
//             child: _buildActionButton(
//               label: notification.type.secondaryActionText,
//               color: notification.type.getSecondaryActionColor(),
//               onPressed: () => _handlePickupOrder(ref, notification),
//               isWeb: isWeb,
//             ),
//           ),
//         ],
//       );
//     }

//     // Món hết - 1 button disabled
//     if (notification.type == NotificationType.orderOutOfStock) {
//       return _buildActionButton(
//         label: notification.type.actionText,
//         color: Colors.grey[400]!,
//         onPressed: () {},
//         isWeb: isWeb,
//         enabled: false,
//       );
//     }

//     return const SizedBox.shrink();
//   }

//   Widget _buildActionButton({
//     required String label,
//     required Color color,
//     required VoidCallback onPressed,
//     required bool isWeb,
//     bool enabled = true,
//   }) {
//     return ElevatedButton(
//       onPressed: enabled ? onPressed : null,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         disabledBackgroundColor: Colors.grey[300],
//         padding: EdgeInsets.symmetric(
//           horizontal: isWeb ? 20 : 16,
//           vertical: isWeb ? 14 : 12,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(Style.buttonBorderRadius),
//         ),
//         elevation: 0,
//       ),
//       child: Text(
//         label,
//         style: Style.fontButton.copyWith(
//           fontSize: isWeb ? 15 : 14,
//           color: enabled ? Colors.white : Colors.grey[600],
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   // ==================== HANDLERS ====================

//   void _handleConfirmOrder(WidgetRef ref, OrderNotification notification) {
//     // Đánh dấu notification đã đọc
//     ref.read(markAsReadProvider)(notification.id);

//     _showSnackBar(
//       ref,
//       'Đã xác nhận làm món ${notification.dishName}',
//       Colors.green,
//     );
//   }

//   void _handlePickupOrder(WidgetRef ref, OrderNotification notification) {
//     // Đánh dấu notification đã đọc
//     ref.read(markAsReadProvider)(notification.id);

//     // Xóa order khỏi tab "Đã làm" trong Kitchen
//     if (notification.orderDetails != null) {
//       ref.read(pickupOrderProvider(notification.orderDetails!.id))();
//     }

//     // Xóa notification
//     ref.read(removeNotificationProvider)(notification.id);

//     _showSnackBar(
//       ref,
//       'Đã xác nhận lấy món ${notification.dishName}',
//       Colors.green,
//     );
//   }

//   void _showSnackBar(WidgetRef ref, String message, Color backgroundColor) {
//     final context = ref.context;
//     if (!context.mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: Style.fontNormal.copyWith(color: Colors.white),
//         ),
//         backgroundColor: backgroundColor,
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }
