import 'package:mart_dine/models/menu.dart';

class CompletedOrderModel {
  final String id; // ID duy nhất cho đơn hàng
  final String tableName;
  final int customerCount;
  final List<MenuItemModel> items;
  final double totalAmount;
  final DateTime checkoutTime; // Thời gian thanh toán

  CompletedOrderModel({
    required this.id,
    required this.tableName,
    required this.customerCount,
    required this.items,
    required this.totalAmount,
    required this.checkoutTime,
  });
}