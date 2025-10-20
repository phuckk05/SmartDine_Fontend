import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/features/branch_management/screen/order_detail_screen.dart';
import '../../../models/order.dart';
import '../../../services/mock_data_service.dart';

class OrderListScreen extends StatefulWidget {
  final bool showBackButton;
  
  const OrderListScreen({super.key, this.showBackButton = true});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final MockDataService _mockDataService = MockDataService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Order> _orders = [];
  List<OrderStatus> _orderStatuses = [];
  bool _isLoading = true;
  String? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final orders = await _mockDataService.loadOrders();
      final statuses = await _mockDataService.loadOrderStatuses();
      
      // Set relations
      for (final order in orders) {
        order.status = statuses.firstWhere(
          (s) => s.id == order.statusId,
          orElse: () => OrderStatus(id: 'unknown', code: 'UNKNOWN', name: 'Không xác định'),
        );
      }
      
      setState(() {
        _orders = orders;
        _orderStatuses = statuses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: widget.showBackButton 
        ? AppBarCus(
            title: 'Danh sách đơn hàng',
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Danh sách đơn hàng', style: Style.fontTitle),
            automaticallyImplyLeading: false,
          ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOrderListView(isDark, textColor, cardColor),
    );
  }

  Widget _buildOrderListView(bool isDark, Color textColor, Color cardColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header and filters
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tất cả thông tin đơn hàng',
                  style: Style.fontTitleMini.copyWith(color: textColor),
                ),
              ),
              // Status filter dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatusFilter,
                    hint: Text(
                      'Lọc trạng thái',
                      style: Style.fontCaption.copyWith(color: Colors.grey[600]),
                    ),
                    dropdownColor: cardColor,
                    style: Style.fontNormal.copyWith(color: textColor),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ..._orderStatuses.map((status) => DropdownMenuItem(
                        value: status.id,
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
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {}); // Rebuild để apply search filter
            },
            style: Style.fontNormal.copyWith(color: textColor),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm đơn hàng theo mã, bàn, nhân viên...',
              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
              prefixIcon: Icon(Icons.search, color: textColor),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Orders list
          Expanded(
            child: Builder(
              builder: (context) {
                // Apply filters
                List<Order> filteredOrders = _orders.where((order) {
                  // Status filter
                  if (_selectedStatusFilter != null && order.statusId != _selectedStatusFilter) {
                    return false;
                  }
                  
                  // Search filter
                  final searchQuery = _searchController.text.toLowerCase();
                  if (searchQuery.isNotEmpty) {
                    return order.getOrderCode().toLowerCase().contains(searchQuery) ||
                           (order.tableName ?? '').toLowerCase().contains(searchQuery) ||
                           (order.userName ?? '').toLowerCase().contains(searchQuery) ||
                           order.getStatusName().toLowerCase().contains(searchQuery) ||
                           (order.note ?? '').toLowerCase().contains(searchQuery);
                  }
                  
                  return true;
                }).toList();
                
                // Sort by created date (newest first)
                filteredOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                
                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy đơn hàng nào',
                          style: Style.fontTitleMini.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(
                      order,
                      isDark,
                      textColor,
                      cardColor,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isDark, Color textColor, Color cardColor) {
    // Determine status color
    Color statusColor = Colors.grey;
    if (order.isPaid()) {
      statusColor = Colors.green;
    } else if (order.isDone()) {
      statusColor = Colors.orange;
    } else if (order.isCooking()) {
      statusColor = Colors.blue;
    } else if (order.isPending()) {
      statusColor = Colors.amber;
    }

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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(
                orderId: order.getOrderCode(),
                tableName: order.getTableDisplayName(),
                date: order.getFormattedDate(),
                amount: order.getTotalAmount() > 0 
                    ? _formatCurrency(order.getTotalAmount())
                    : '0 đ',
                status: order.getStatusName(),
                statusColor: statusColor,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Order ID
                  Text(
                    order.getOrderCode(),
                    style: Style.fontTitleMini.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.getStatusName(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Details grid
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.table_restaurant_outlined,
                      'Bàn',
                      order.getTableDisplayName(),
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.person_outline,
                      'Nhân viên',
                      order.userName ?? 'Không xác định',
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.access_time_outlined,
                      'Thời gian',
                      order.getFormattedDate(),
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.attach_money_outlined,
                      'Tổng tiền',
                      order.getTotalAmount() > 0 
                          ? _formatCurrency(order.getTotalAmount())
                          : '0 đ',
                      isDark,
                    ),
                  ),
                ],
              ),
              
              // Note if exists
              if (order.note != null && order.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.note!,
                          style: Style.fontCaption.copyWith(
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Style.fontCaption.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: Style.fontNormal.copyWith(
                  color: isDark ? Style.colorLight : Style.colorDark,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )} đ';
  }
}