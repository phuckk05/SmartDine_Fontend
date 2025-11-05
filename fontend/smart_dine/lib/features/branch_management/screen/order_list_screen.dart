import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/branch_management/screen/order_detail_screen.dart';
import '../../../models/order.dart';
import '../../../providers/order_management_provider.dart';

class OrderListScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  
  const OrderListScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedStatusFilter;

  String? _getBranchId() {
    // TODO: Get branchId từ user context thông qua UserBranch
    // For now, return mock branchId
    return '1'; // Mock branch ID as String
  }

  @override
  Widget build(BuildContext context) {
    // Lấy branchId từ route giống như các screen khác
    final branchId = _getBranchId();
    if (branchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Danh sách đơn hàng')),
        body: const Center(child: Text('Không tìm thấy thông tin chi nhánh')),
      );
    }
    
    final branchIdInt = int.tryParse(branchId) ?? 1;
    final ordersAsyncValue = ref.watch(ordersByBranchProvider(branchIdInt));
    final statusesAsyncValue = ref.watch(orderStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Danh sách đơn hàng',
          style: Style.fontTitle,
        ),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Column(
        children: [
          _buildFilters(statusesAsyncValue, isDark),
          Expanded(
            child: ordersAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Lỗi tải dữ liệu: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final branchIdInt = int.tryParse(_getBranchId() ?? '1') ?? 1;
                        // ignore: unused_result
                        ref.refresh(ordersByBranchProvider(branchIdInt));
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (orders) => statusesAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Lỗi tải trạng thái: $error'),
                ),
                data: (statuses) => _buildOrderList(orders, statuses, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AsyncValue<List<OrderStatus>> statusesAsyncValue, bool isDark) {
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Tìm kiếm đơn hàng',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          // Status filter
          statusesAsyncValue.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => Text('Lỗi: $error'),
            data: (statuses) => DropdownButtonFormField<String>(
              value: _selectedStatusFilter,
              decoration: InputDecoration(
                labelText: 'Lọc theo trạng thái',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tất cả trạng thái'),
                ),
                ...statuses.map((status) => DropdownMenuItem<String>(
                  value: status.id.toString(),
                  child: Text(status.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatusFilter = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders, List<OrderStatus> statuses, bool isDark) {
    // Set status relations
    for (final order in orders) {
      order.status = statuses.firstWhere(
        (s) => s.id == order.statusId,
        orElse: () => OrderStatus(id: -1, code: 'UNKNOWN', name: 'Không xác định'),
      );
    }

    // Apply filters
    List<Order> filteredOrders = orders.where((order) {
      final matchesSearch = _searchController.text.isEmpty ||
          order.id.toString().contains(_searchController.text) ||
          (order.userName?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
      
      final matchesStatus = _selectedStatusFilter == null ||
          order.statusId == _selectedStatusFilter;

      return matchesSearch && matchesStatus;
    }).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hàng nào',
              style: Style.fontContent.copyWith(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final branchIdInt = int.tryParse(_getBranchId() ?? '1') ?? 1;
        return ref.refresh(ordersByBranchProvider(branchIdInt));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order, isDark);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isDark) {
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(
                orderId: order.id ?? 0,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đơn hàng #${order.id}',
                    style: Style.fontTitle.copyWith(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  _buildStatusChip(order.status!, isDark),
                ],
              ),
              const SizedBox(height: 8),
              if (order.userName != null) ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      order.userName!,
                      style: Style.fontContent.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Row(
                children: [
                  Icon(Icons.table_restaurant, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Bàn ${order.tableId}',
                    style: Style.fontContent.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(order.createdAt),
                    style: Style.fontContent.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng: ${_formatCurrency(order.getTotalAmount())}',
                    style: Style.fontContent.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6200EE),
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${order.items?.length ?? 0} món',
                        style: Style.fontContent.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status, bool isDark) {
    Color backgroundColor;
    Color textColor;

    switch (status.code) {
      case 'PENDING':
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case 'COOKING':
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        break;
      case 'READY':
        backgroundColor = Colors.purple.withOpacity(0.2);
        textColor = Colors.purple;
        break;
      case 'SERVED':
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      case 'PAID':
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        break;
      case 'CANCELLED':
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name,
        style: Style.fontContent.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return '0đ';
    
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}đ';
  }

  Color _getStatusColor(String statusCode) {
    switch (statusCode) {
      case 'PENDING':
        return Colors.orange;
      case 'COOKING':
        return Colors.blue;
      case 'READY':
        return Colors.purple;
      case 'SERVED':
        return Colors.green;
      case 'PAID':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}