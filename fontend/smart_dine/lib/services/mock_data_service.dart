import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/table.dart';
import '../models/employee.dart';
import '../models/role.dart';
import '../models/order.dart';
import '../models/payment.dart';
import '../models/menu_item.dart';
import '../models/branch.dart';
import '../models/notification.dart';

/// Service class để load và parse mock data từ JSON files
/// Sử dụng để test UI trước khi có API thật
class MockDataService {
  // Singleton pattern
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Cache data để tránh load nhiều lần
  List<Table>? _cachedTables;
  List<TableStatus>? _cachedTableStatuses;
  List<TableType>? _cachedTableTypes;
  
  List<Employee>? _cachedEmployees;
  List<UserStatus>? _cachedUserStatuses;
  List<Role>? _cachedRoles;
  
  List<Order>? _cachedOrders;
  List<OrderStatus>? _cachedOrderStatuses;
  List<OrderItemStatus>? _cachedOrderItemStatuses;
  List<Payment>? _cachedPayments;
  List<MenuItem>? _cachedMenuItems;
  List<Category>? _cachedCategories;
  List<Branch>? _cachedBranches;
  List<BranchStatus>? _cachedBranchStatuses;
  List<Notification>? _cachedNotifications;
  List<NotificationCategory>? _cachedNotificationCategories;

  /// Load tables từ JSON
  Future<List<Table>> loadTables() async {
    if (_cachedTables != null) return _cachedTables!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/tables.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedTables = (jsonData['tables'] as List)
        .map((json) => Table.fromJson(json))
        .toList();

    return _cachedTables!;
  }

  /// Load table statuses từ JSON
  Future<List<TableStatus>> loadTableStatuses() async {
    if (_cachedTableStatuses != null) return _cachedTableStatuses!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/tables.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedTableStatuses = (jsonData['statuses'] as List)
        .map((json) => TableStatus.fromJson(json))
        .toList();

    return _cachedTableStatuses!;
  }

  /// Load table types từ JSON
  Future<List<TableType>> loadTableTypes() async {
    if (_cachedTableTypes != null) return _cachedTableTypes!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/tables.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedTableTypes = (jsonData['types'] as List)
        .map((json) => TableType.fromJson(json))
        .toList();

    return _cachedTableTypes!;
  }

  /// Load employees từ JSON
  Future<List<Employee>> loadEmployees() async {
    if (_cachedEmployees != null) return _cachedEmployees!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/employees.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedEmployees = (jsonData['employees'] as List)
        .map((json) => Employee.fromJson(json))
        .toList();

    return _cachedEmployees!;
  }

  /// Load user statuses từ JSON
  Future<List<UserStatus>> loadUserStatuses() async {
    if (_cachedUserStatuses != null) return _cachedUserStatuses!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/employees.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedUserStatuses = (jsonData['statuses'] as List)
        .map((json) => UserStatus.fromJson(json))
        .toList();

    return _cachedUserStatuses!;
  }

  /// Load roles từ JSON
  Future<List<Role>> loadRoles() async {
    if (_cachedRoles != null) return _cachedRoles!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/employees.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedRoles = (jsonData['roles'] as List)
        .map((json) => Role.fromJson(json))
        .toList();

    return _cachedRoles!;
  }

  /// Load orders từ JSON
  Future<List<Order>> loadOrders() async {
    if (_cachedOrders != null) return _cachedOrders!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/orders.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedOrders = (jsonData['orders'] as List)
        .map((json) => Order.fromJson(json))
        .toList();

    return _cachedOrders!;
  }

  /// Load order statuses từ JSON
  Future<List<OrderStatus>> loadOrderStatuses() async {
    if (_cachedOrderStatuses != null) return _cachedOrderStatuses!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/orders.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedOrderStatuses = (jsonData['order_statuses'] as List)
        .map((json) => OrderStatus.fromJson(json))
        .toList();

    return _cachedOrderStatuses!;
  }

  /// Load order item statuses từ JSON  
  Future<List<OrderItemStatus>> loadOrderItemStatuses() async {
    if (_cachedOrderItemStatuses != null) return _cachedOrderItemStatuses!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/orders.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedOrderItemStatuses = (jsonData['order_item_statuses'] as List)
        .map((json) => OrderItemStatus.fromJson(json))
        .toList();

    return _cachedOrderItemStatuses!;
  }

  /// Load payments từ JSON
  Future<List<Payment>> loadPayments() async {
    if (_cachedPayments != null) return _cachedPayments!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/payments.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedPayments = (jsonData['payments'] as List)
        .map((json) => Payment.fromJson(json))
        .toList();

    return _cachedPayments!;
  }

  /// Load menu items từ JSON
  Future<List<MenuItem>> loadMenuItems() async {
    if (_cachedMenuItems != null) return _cachedMenuItems!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/menu_items.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedMenuItems = (jsonData['menu_items'] as List)
        .map((json) => MenuItem.fromJson(json))
        .toList();

    return _cachedMenuItems!;
  }

  /// Load categories từ JSON
  Future<List<Category>> loadCategories() async {
    if (_cachedCategories != null) return _cachedCategories!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/menu_items.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedCategories = (jsonData['categories'] as List)
        .map((json) => Category.fromJson(json))
        .toList();

    return _cachedCategories!;
  }

  /// Load branches từ JSON
  Future<List<Branch>> loadBranches() async {
    if (_cachedBranches != null) return _cachedBranches!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/branches.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedBranches = (jsonData['branches'] as List)
        .map((json) => Branch.fromJson(json))
        .toList();

    return _cachedBranches!;
  }

  /// Load branch statuses từ JSON
  Future<List<BranchStatus>> loadBranchStatuses() async {
    if (_cachedBranchStatuses != null) return _cachedBranchStatuses!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/branches.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedBranchStatuses = (jsonData['branch_statuses'] as List)
        .map((json) => BranchStatus.fromJson(json))
        .toList();

    return _cachedBranchStatuses!;
  }

  /// Load notifications từ JSON
  Future<List<Notification>> loadNotifications() async {
    if (_cachedNotifications != null) return _cachedNotifications!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/notifications.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedNotifications = (jsonData['notifications'] as List)
        .map((json) => Notification.fromJson(json))
        .toList();

    return _cachedNotifications!;
  }

  /// Load notification categories từ JSON
  Future<List<NotificationCategory>> loadNotificationCategories() async {
    if (_cachedNotificationCategories != null) return _cachedNotificationCategories!;

    final String jsonString = await rootBundle.loadString('assets/mock_data/notifications.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    _cachedNotificationCategories = (jsonData['notification_categories'] as List)
        .map((json) => NotificationCategory.fromJson(json))
        .toList();

    return _cachedNotificationCategories!;
  }

  /// Clear all cached data
  void clearCache() {
    _cachedTables = null;
    _cachedTableStatuses = null;
    _cachedTableTypes = null;
    _cachedEmployees = null;
    _cachedUserStatuses = null;
    _cachedRoles = null;
    _cachedOrders = null;
    _cachedOrderStatuses = null;
    _cachedOrderItemStatuses = null;
    _cachedPayments = null;
    _cachedMenuItems = null;
    _cachedCategories = null;
    _cachedBranches = null;
    _cachedBranchStatuses = null;
    _cachedNotifications = null;
    _cachedNotificationCategories = null;
  }

  /// Reload all data (clear cache và load lại)
  Future<void> reloadAll() async {
    clearCache();
    await Future.wait([
      loadTables(),
      loadTableStatuses(),
      loadTableTypes(),
      loadEmployees(),
      loadUserStatuses(),
      loadRoles(),
      loadOrders(),
      loadOrderStatuses(),
      loadOrderItemStatuses(),
      loadPayments(),
      loadMenuItems(),
      loadCategories(),
      loadBranches(),
      loadBranchStatuses(),
      loadNotifications(),
      loadNotificationCategories(),
    ]);
  }
}
