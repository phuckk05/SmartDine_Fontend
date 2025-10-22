import 'notification_model.dart';
import '../../models/kitchen_order.dart';
import 'kitchen_order_status.dart';
import 'kitchen_mock_data.dart';

class NotificationMockData {
  /// Lấy tất cả notifications
  static List<OrderNotification> getAllNotifications() {
    final now = DateTime.now();
    final notifications = <OrderNotification>[];

    // Lấy orders từ KitchenMockData
    final allOrders = KitchenMockData.getAllKitchenOrders();

    // Tạo notifications cho các orders pending (món mới)
    final pendingOrders =
        allOrders.where((o) => o.status == KitchenOrderStatus.pending).toList();

    for (var order in pendingOrders) {
      notifications.add(
        OrderNotification.fromKitchenOrder(
          order: order,
          type: NotificationType.newOrder,
        ),
      );
    }

    // Tạo notifications cho các orders completed (món đã xong)
    final completedOrders =
        allOrders
            .where((o) => o.status == KitchenOrderStatus.completed)
            .toList();

    for (var order in completedOrders) {
      notifications.add(
        OrderNotification.fromKitchenOrder(
          order: order,
          type: NotificationType.orderReady,
        ),
      );
    }

    // Tạo notifications cho các orders out of stock (món hết)
    final outOfStockOrders =
        allOrders
            .where((o) => o.status == KitchenOrderStatus.outOfStock)
            .toList();

    for (var order in outOfStockOrders) {
      notifications.add(
        OrderNotification.fromKitchenOrder(
          order: order,
          type: NotificationType.orderOutOfStock,
        ),
      );
    }

    // Sắp xếp theo thời gian mới nhất
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return notifications;
  }

  /// Lọc notifications chưa đọc
  static List<OrderNotification> getUnreadNotifications() {
    return getAllNotifications().where((n) => !n.isRead).toList();
  }

  /// Đếm notifications chưa đọc
  static int getUnreadCount() {
    return getUnreadNotifications().length;
  }

  /// Lọc theo type
  static List<OrderNotification> getNotificationsByType(NotificationType type) {
    return getAllNotifications().where((n) => n.type == type).toList();
  }

  /// Đánh dấu tất cả đã đọc
  static List<OrderNotification> markAllAsRead(
    List<OrderNotification> notifications,
  ) {
    return notifications.map((n) => n.markAsRead()).toList();
  }
}
