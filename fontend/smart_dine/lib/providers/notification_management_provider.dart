import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/notification_management_api.dart';
import '../models/notification.dart' as model;

// Provider for the API service
final notificationManagementApiProvider = Provider<NotificationManagementAPI>((ref) {
  return NotificationManagementAPI();
});

// State notifier for notifications
class NotificationManagementNotifier extends StateNotifier<AsyncValue<List<model.Notification>>> {
  final NotificationManagementAPI _api;

  NotificationManagementNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> loadNotifications(String branchId, String companyId) async {
    state = const AsyncValue.loading();
    
    try {
      final notifications = await _api.getAllNotifications(branchId, companyId);
      if (notifications != null) {
        state = AsyncValue.data(notifications);
      } else {
        state = AsyncValue.error('Failed to load notifications', StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentState = state;
    if (currentState is AsyncData<List<model.Notification>>) {
      try {
        final success = await _api.markNotificationAsRead(notificationId);
        if (success) {
          // Update local state to mark notification as read
          final updatedNotifications = currentState.value.map((notification) {
            if (notification.id == notificationId) {
              // Create a new notification with isNew = false
              return model.Notification(
                id: notification.id,
                category: notification.category,
                type: notification.type,
                message: notification.message,
                icon: notification.icon,
                iconColor: notification.iconColor,
                isNew: false, // Mark as read
                priority: notification.priority,
                createdAt: notification.createdAt,
                userId: notification.userId,
                branchId: notification.branchId,
                companyId: notification.companyId,
                userName: notification.userName,
              );
            }
            return notification;
          }).toList();
          
          state = AsyncValue.data(updatedNotifications);
        }
      } catch (error) {
        // Handle error silently or show a toast
              }
    }
  }

  Future<void> markAllAsRead(String branchId) async {
    final currentState = state;
    if (currentState is AsyncData<List<model.Notification>>) {
      try {
        final success = await _api.markAllNotificationsAsRead(branchId);
        if (success) {
          // Update local state to mark all notifications as read
          final updatedNotifications = currentState.value.map((notification) {
            return model.Notification(
              id: notification.id,
              category: notification.category,
              type: notification.type,
              message: notification.message,
              icon: notification.icon,
              iconColor: notification.iconColor,
              isNew: false, // Mark as read
              priority: notification.priority,
              createdAt: notification.createdAt,
              userId: notification.userId,
              branchId: notification.branchId,
              companyId: notification.companyId,
              userName: notification.userName,
            );
          }).toList();
          
          state = AsyncValue.data(updatedNotifications);
        }
      } catch (error) {
              }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final currentState = state;
    if (currentState is AsyncData<List<model.Notification>>) {
      try {
        final success = await _api.deleteNotification(notificationId);
        if (success) {
          // Remove notification from local state
          final updatedNotifications = currentState.value
              .where((notification) => notification.id != notificationId)
              .toList();
          
          state = AsyncValue.data(updatedNotifications);
        }
      } catch (error) {
              }
    }
  }

  // Get unread notification count
  int get unreadCount {
    final currentState = state;
    if (currentState is AsyncData<List<model.Notification>>) {
      return currentState.value.where((notification) => notification.isNew).length;
    }
    return 0;
  }

  // Get notifications by category
  List<model.Notification> getNotificationsByCategory(String category) {
    final currentState = state;
    if (currentState is AsyncData<List<model.Notification>>) {
      return currentState.value
          .where((notification) => notification.category == category)
          .toList();
    }
    return [];
  }

  // Get high priority notifications
  List<model.Notification> getHighPriorityNotifications() {
    final currentState = state;
    if (currentState is AsyncData<List<model.Notification>>) {
      return currentState.value
          .where((notification) => notification.isHighPriority())
          .toList();
    }
    return [];
  }
}

// Provider for the notification state notifier
final notificationManagementProvider = StateNotifierProvider<NotificationManagementNotifier, AsyncValue<List<model.Notification>>>((ref) {
  final api = ref.watch(notificationManagementApiProvider);
  return NotificationManagementNotifier(api);
});

// State notifier for notification categories
class NotificationCategoryNotifier extends StateNotifier<AsyncValue<List<model.NotificationCategory>>> {
  final NotificationManagementAPI _api;

  NotificationCategoryNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    
    try {
      final categories = await _api.getAllNotificationCategories();
      if (categories != null) {
        state = AsyncValue.data(categories);
      } else {
        state = AsyncValue.error('Failed to load notification categories', StackTrace.current);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider for notification categories
final notificationCategoryProvider = StateNotifierProvider<NotificationCategoryNotifier, AsyncValue<List<model.NotificationCategory>>>((ref) {
  final api = ref.watch(notificationManagementApiProvider);
  return NotificationCategoryNotifier(api);
});