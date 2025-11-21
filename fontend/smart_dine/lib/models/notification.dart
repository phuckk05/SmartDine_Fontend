import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Model representing a notification in the system
class Notification {
  static const _uuid = Uuid();

  /// Unique identifier for the notification
  final String id;
  
  /// Category of the notification (e.g., 'Thanh toán', 'Bàn ăn', 'Đơn hàng')
  final String category;
  
  /// Title or type of the notification
  final String type;
  
  /// Main message content
  final String message;
  
  /// Icon to display with the notification
  final IconData icon;
  
  /// Color for the icon
  final Color iconColor;
  
  /// Whether this is a new/unread notification
  final bool isNew;
  
  /// Priority level (1=low, 2=medium, 3=high)
  final int priority;
  
  /// Date and time when notification was created
  final DateTime createdAt;
  
  /// Reference to the user who triggered this notification (optional)
  final String? userId;
  
  /// Reference to the branch where notification occurred
  final String branchId;
  
  /// Reference to the company
  final String companyId;

  // Relations - loaded separately
  String? userName;

  Notification({
    String? id,
    required this.category,
    required this.type,
    required this.message,
    required this.icon,
    required this.iconColor,
    this.isNew = true,
    this.priority = 2,
    DateTime? createdAt,
    this.userId,
    required this.branchId,
    required this.companyId,
    this.userName,
  }) : id = id ?? _uuid.v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Create Notification from JSON
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      category: json['category'],
      type: json['type'],
      message: json['message'],
      icon: _parseIcon(json['icon']),
      iconColor: _parseColor(json['icon_color']),
      isNew: json['is_new'] ?? true,
      priority: json['priority'] ?? 2,
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      branchId: json['branch_id'],
      companyId: json['company_id'],
      userName: json['user_name'],
    );
  }

  /// Convert Notification to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'type': type,
      'message': message,
      'icon': _iconToString(icon),
      'icon_color': _colorToString(iconColor),
      'is_new': isNew,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'branch_id': branchId,
      'company_id': companyId,
      'user_name': userName,
    };
  }

  /// Get formatted time display (e.g., "2 phút trước")
  String getTimeDisplay() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Get priority name
  String getPriorityName() {
    switch (priority) {
      case 1: return 'Thấp';
      case 3: return 'Cao';
      default: return 'Trung bình';
    }
  }

  /// Check if notification is high priority
  bool isHighPriority() => priority >= 3;

  /// Check if notification is recent (within last hour)
  bool isRecent() {
    final difference = DateTime.now().difference(createdAt);
    return difference.inHours < 1;
  }

  /// Helper methods for icon parsing
  static IconData _parseIcon(String iconString) {
    switch (iconString) {
      case 'payment': return Icons.payment;
      case 'table_restaurant': return Icons.table_restaurant;
      case 'edit_note': return Icons.edit_note;
      case 'cancel': return Icons.cancel;
      case 'add_circle': return Icons.add_circle;
      case 'restaurant_menu': return Icons.restaurant_menu;
      case 'notifications_active': return Icons.notifications_active;
      case 'warning': return Icons.warning;
      case 'check_circle': return Icons.check_circle;
      case 'info': return Icons.info;
      default: return Icons.notifications;
    }
  }

  static Color _parseColor(String colorString) {
    switch (colorString) {
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'orange': return Colors.orange;
      case 'red': return Colors.red;
      case 'purple': return Colors.purple;
      case 'amber': return Colors.amber;
      case 'grey': return Colors.grey;
      default: return Colors.blue;
    }
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.payment) return 'payment';
    if (icon == Icons.table_restaurant) return 'table_restaurant';
    if (icon == Icons.edit_note) return 'edit_note';
    if (icon == Icons.cancel) return 'cancel';
    if (icon == Icons.add_circle) return 'add_circle';
    if (icon == Icons.restaurant_menu) return 'restaurant_menu';
    if (icon == Icons.notifications_active) return 'notifications_active';
    if (icon == Icons.warning) return 'warning';
    if (icon == Icons.check_circle) return 'check_circle';
    if (icon == Icons.info) return 'info';
    return 'notifications';
  }

  static String _colorToString(Color color) {
    if (color == Colors.green) return 'green';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.red) return 'red';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.amber) return 'amber';
    if (color == Colors.grey) return 'grey';
    return 'blue';
  }
}

/// Model for notification categories
class NotificationCategory {
  final String id;
  final String name;
  final String? description;
  final IconData defaultIcon;
  final Color defaultColor;

  NotificationCategory({
    required this.id,
    required this.name,
    this.description,
    required this.defaultIcon,
    required this.defaultColor,
  });

  factory NotificationCategory.fromJson(Map<String, dynamic> json) {
    return NotificationCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      defaultIcon: Notification._parseIcon(json['default_icon']),
      defaultColor: Notification._parseColor(json['default_color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'default_icon': Notification._iconToString(defaultIcon),
      'default_color': Notification._colorToString(defaultColor),
    };
  }
}