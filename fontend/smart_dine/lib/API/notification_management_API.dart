import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart' as model;

final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api';

class NotificationManagementAPI {
  // Get all notifications from real API
  Future<List<model.Notification>?> getAllNotifications(String branchId, String companyId) async {
    try {
      // Return empty list until notification endpoints are implemented
      return [];
    } catch (e) {
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
            return false;
    }
  }
}

final notificationManagementApiProvider = Provider<NotificationManagementAPI>((ref) {
  return NotificationManagementAPI();
});