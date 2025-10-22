import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/providers/kitchen_providers.dart';
import '../models/notification_model.dart';
import '../models/kitchen_order_status.dart';
export '../models/notification_model.dart';

/// Trạng thái của notification được quản lý như một state
final notificationsStateProvider =
    StateNotifierProvider<NotificationsNotifier, List<OrderNotification>>((
      ref,
    ) {
      return NotificationsNotifier(ref);
    });

class NotificationsNotifier extends StateNotifier<List<OrderNotification>> {
  final Ref ref;

  NotificationsNotifier(this.ref) : super([]) {
    // Khởi tạo notifications từ kitchen orders
    _initializeNotifications();
  }

  /// Khởi tạo notifications từ các kitchen orders
  void _initializeNotifications() {
    final orders = ref.read(ordersProvider);
    state =
        orders.map((order) {
          switch (order.status) {
            case KitchenOrderStatus.pending:
              return OrderNotification.fromKitchenOrder(
                order: order,
                type: NotificationType.newOrder,
              );
            case KitchenOrderStatus.completed:
              return OrderNotification.fromKitchenOrder(
                order: order,
                type: NotificationType.orderReady,
              );
            case KitchenOrderStatus.outOfStock:
              return OrderNotification.fromKitchenOrder(
                order: order,
                type: NotificationType.orderOutOfStock,
              );
            case KitchenOrderStatus.cancelled:
              return OrderNotification.fromKitchenOrder(
                order: order,
                type: NotificationType.orderCancelled,
              );
          }
        }).toList();
  }

  /// Đánh dấu một notification là đã đọc
  void markAsRead(String notificationId) {
    state =
        state.map((notification) {
          return notification.id == notificationId
              ? notification.markAsRead()
              : notification;
        }).toList();
  }

  /// Đánh dấu tất cả notifications là đã đọc
  void markAllAsRead() {
    state = state.map((notification) => notification.markAsRead()).toList();
  }

  /// Xóa một notification
  void removeNotification(String notificationId) {
    state =
        state
            .where((notification) => notification.id != notificationId)
            .toList();
  }

  /// Thêm một notification mới
  void addNotification(OrderNotification notification) {
    state = [notification, ...state];
  }

  /// Sync notifications từ kitchen orders
  void syncNotificationsFromKitchen() {
    _initializeNotifications();
  }
}

// Provider để đồng bộ hóa thông báo từ kitchen
final syncNotificationsFromKitchenProvider = Provider<void Function()>((ref) {
  final notifier = ref.read(notificationsStateProvider.notifier);
  return () {
    notifier.syncNotificationsFromKitchen();
  };
});

/// Provider chính để quản lý notifications - BẮT ĐẦU RỖNG
final notificationsProvider = StateProvider<List<OrderNotification>>((ref) {
  return []; // Bắt đầu không có notification nào
});

/// Provider đếm số lượng notification chưa đọc
final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

/// Provider lọc notifications chưa đọc
final unreadNotificationsProvider = Provider<List<OrderNotification>>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).toList();
});

/// Provider lọc notifications theo loại
final notificationsByTypeProvider =
    Provider.family<List<OrderNotification>, NotificationType>((ref, type) {
      final notifications = ref.watch(notificationsProvider);
      return notifications.where((n) => n.type == type).toList();
    });

/// Provider đếm notifications theo loại
final notificationCountByTypeProvider = Provider<Map<NotificationType, int>>((
  ref,
) {
  final notifications = ref.watch(notificationsProvider);
  return {
    NotificationType.orderReady:
        notifications
            .where((n) => n.type == NotificationType.orderReady)
            .length,
    NotificationType.orderOutOfStock:
        notifications
            .where((n) => n.type == NotificationType.orderOutOfStock)
            .length,
    NotificationType.orderCancelled:
        notifications
            .where((n) => n.type == NotificationType.orderCancelled)
            .length,
  };
});

/// Provider để đánh dấu một thông báo là đã đọc
final markAsReadProvider = Provider<void Function(String)>((ref) {
  return (String notificationId) {
    final notifications = ref.read(notificationsProvider);
    final updated =
        notifications.map((n) {
          return n.id == notificationId ? n.markAsRead() : n;
        }).toList();
    ref.read(notificationsProvider.notifier).state = updated;
  };
});

/// Provider để đánh dấu tất cả thông báo là đã đọc
final markAllAsReadProvider = Provider<void Function()>((ref) {
  return () {
    final notifications = ref.read(notificationsProvider);
    final updated = notifications.map((n) => n.markAsRead()).toList();
    ref.read(notificationsProvider.notifier).state = updated;
  };
});

/// Provider để xóa một thông báo
final removeNotificationProvider = Provider<void Function(String)>((ref) {
  return (String notificationId) {
    final notifications = ref.read(notificationsProvider);
    final updated = notifications.where((n) => n.id != notificationId).toList();
    ref.read(notificationsProvider.notifier).state = updated;
  };
});
