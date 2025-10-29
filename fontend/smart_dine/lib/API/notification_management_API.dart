import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart' as model;

final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api';

class NotificationManagementAPI {
  // Mock method to get all notifications (since we don't have backend endpoint yet)
  Future<List<model.Notification>?> getAllNotifications(String branchId, String companyId) async {
    try {
      // Mock data since backend doesn't have this endpoint yet
      await Future.delayed(const Duration(milliseconds: 200)); // Giảm từ 800ms xuống 200ms
      
      return [
        model.Notification(
          category: 'Đơn hàng',
          type: 'Đơn hàng mới',
          message: 'Có đơn hàng mới tại bàn 5',
          icon: Icons.add_circle,
          iconColor: Colors.green,
          isNew: true,
          priority: 3,
          branchId: branchId,
          companyId: companyId,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        model.Notification(
          category: 'Thanh toán',
          type: 'Thanh toán thành công',
          message: 'Đơn hàng #123 đã được thanh toán',
          icon: Icons.payment,
          iconColor: Colors.blue,
          isNew: false,
          priority: 2,
          branchId: branchId,
          companyId: companyId,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        model.Notification(
          category: 'Menu',
          type: 'Hết món',
          message: 'Món Phở Bò đã hết trong menu',
          icon: Icons.restaurant_menu,
          iconColor: Colors.orange,
          isNew: true,
          priority: 2,
          branchId: branchId,
          companyId: companyId,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        model.Notification(
          category: 'Khách hàng',
          type: 'Feedback',
          message: 'Nhận được đánh giá 5 sao từ khách hàng',
          icon: Icons.star,
          iconColor: Colors.amber,
          isNew: false,
          priority: 1,
          branchId: branchId,
          companyId: companyId,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        model.Notification(
          category: 'Báo cáo',
          type: 'Báo cáo doanh thu',
          message: 'Báo cáo doanh thu tuần đã sẵn sàng',
          icon: Icons.analytics,
          iconColor: Colors.purple,
          isNew: true,
          priority: 2,
          branchId: branchId,
          companyId: companyId,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        model.Notification(
          category: 'Hệ thống',
          type: 'Cảnh báo',
          message: 'Kết nối mạng không ổn định',
          icon: Icons.warning,
          iconColor: Colors.red,
          isNew: true,
          priority: 3,
          branchId: branchId,
          companyId: companyId,
          createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        model.Notification(
          category: 'Bàn ăn',
          type: 'Bàn mới',
          message: 'Khách vừa ngồi vào bàn 12',
          icon: Icons.table_restaurant,
          iconColor: Colors.blue,
          isNew: true,
          priority: 1,
          branchId: branchId,
          companyId: companyId,
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ];
    } catch (e) {
      print('Error getting notifications: $e');
      return null;
    }
  }

  // Mock method to get notification categories
  Future<List<model.NotificationCategory>?> getAllNotificationCategories() async {
    try {
      // Mock data since backend doesn't have this endpoint yet
      await Future.delayed(const Duration(milliseconds: 100)); // Giảm từ 300ms xuống 100ms
      
      return [
        model.NotificationCategory(
          id: '1',
          name: 'Đơn hàng',
          description: 'Thông báo về đơn hàng mới, hủy đơn',
          defaultIcon: Icons.receipt,
          defaultColor: Colors.blue,
        ),
        model.NotificationCategory(
          id: '2',
          name: 'Thanh toán',
          description: 'Thông báo về thanh toán thành công',
          defaultIcon: Icons.payment,
          defaultColor: Colors.green,
        ),
        model.NotificationCategory(
          id: '3',
          name: 'Menu',
          description: 'Thông báo về cập nhật menu, hết món',
          defaultIcon: Icons.restaurant_menu,
          defaultColor: Colors.orange,
        ),
        model.NotificationCategory(
          id: '4',
          name: 'Khách hàng',
          description: 'Thông báo về feedback, đánh giá',
          defaultIcon: Icons.people,
          defaultColor: Colors.purple,
        ),
        model.NotificationCategory(
          id: '5',
          name: 'Báo cáo',
          description: 'Thông báo về báo cáo doanh thu, thống kê',
          defaultIcon: Icons.analytics,
          defaultColor: Colors.grey,
        ),
      ];
    } catch (e) {
      print('Error getting notification categories: $e');
      return null;
    }
  }

  // Mock method to mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 100)); // Giảm từ 500ms xuống 100ms
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mock method to mark all notifications as read
  Future<bool> markAllNotificationsAsRead(String branchId) async {
    try {
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 200)); // Giảm từ 800ms xuống 200ms
      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Mock method to delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // Mock API call
      await Future.delayed(const Duration(milliseconds: 100)); // Giảm từ 500ms xuống 100ms
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }
}

final notificationManagementApiProvider = Provider<NotificationManagementAPI>((ref) {
  return NotificationManagementAPI();
});