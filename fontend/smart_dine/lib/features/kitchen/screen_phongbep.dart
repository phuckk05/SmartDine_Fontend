import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({super.key});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  int selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Dữ liệu cứng - Danh sách món ăn (TẤT CẢ BẮT ĐẦU Ở TAB "CHƯA LÀM")
  final List<Map<String, dynamic>> _allOrders = [
    {
      'dishName': 'Bánh mỳ',
      'createdTime': '12:53',
      'tableNumber': 'b-3',
      'status': 'pending', // Tất cả bắt đầu là pending
      'isPickedUp': false,
    },
    {
      'dishName': 'Phở bò',
      'createdTime': '13:15',
      'tableNumber': 'a-5',
      'status': 'pending',
      'isPickedUp': false,
    },
    {
      'dishName': 'Cơm gà',
      'createdTime': '13:20',
      'tableNumber': 'c-2',
      'status': 'pending',
      'isPickedUp': false,
    },
    {
      'dishName': 'Bún chả',
      'createdTime': '11:30',
      'tableNumber': 'a-1',
      'status': 'pending',
      'isPickedUp': false,
    },
    {
      'dishName': 'Bánh xèo',
      'createdTime': '11:45',
      'tableNumber': 'b-7',
      'status': 'pending',
      'isPickedUp': false,
    },
    {
      'dishName': 'Mì xào',
      'createdTime': '12:15',
      'tableNumber': 'c-5',
      'status': 'pending',
      'isPickedUp': false,
    },
    {
      'dishName': 'Hủ tiếu',
      'createdTime': '12:00',
      'tableNumber': 'd-4',
      'status': 'pending',
      'isPickedUp': false,
    },
    {
      'dishName': 'Mì Quảng',
      'createdTime': '12:10',
      'tableNumber': 'c-8',
      'status': 'pending',
      'isPickedUp': false,
    },
    {
      'dishName': 'Gỏi cuốn',
      'createdTime': '10:50',
      'tableNumber': 'b-2',
      'status': 'pending',
      'isPickedUp': false,
    },
    {
      'dishName': 'Bún bò Huế',
      'createdTime': '09:30',
      'tableNumber': 'a-8',
      'status': 'pending',
      'isPickedUp': false,
    },
  ];

  // Lọc danh sách theo tab
  List<Map<String, dynamic>> get _filteredOrders {
    String statusFilter;
    switch (selectedTabIndex) {
      case 0:
        statusFilter = 'pending'; // Chưa làm
        break;
      case 1:
        statusFilter = 'completed'; // Đã làm
        break;
      case 2:
        statusFilter = 'out_of_stock'; // Hết món
        break;
      case 3:
        statusFilter = 'cancelled'; // Đã hủy
        break;
      default:
        statusFilter = 'pending';
    }

    List<Map<String, dynamic>> filtered =
        _allOrders.where((order) => order['status'] == statusFilter).toList();

    // Nếu đang ở tab "Đã làm", chỉ hiển thị món chưa lấy
    if (selectedTabIndex == 1) {
      filtered =
          filtered.where((order) => order['isPickedUp'] == false).toList();
    }

    // Lọc theo search
    if (_searchController.text.isNotEmpty) {
      filtered =
          filtered.where((order) {
            return order['dishName'].toString().toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                order['tableNumber'].toString().toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );
          }).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Xử lý khi nhấn nút "Xong" - CHỈ HOẠT ĐỘNG Ở TAB "CHƯA LÀM"
  void _handleComplete(Map<String, dynamic> order) {
    // Kiểm tra xem món có đang ở trạng thái "pending" không
    if (order['status'] != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ có thể xử lý món ở tab "Chưa làm"'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      order['status'] = 'completed';
      order['isPickedUp'] = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã hoàn thành món ${order['dishName']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Xử lý khi nhấn nút "Hết" - CHỈ HOẠT ĐỘNG Ở TAB "CHƯA LÀM"
  void _handleOutOfStock(Map<String, dynamic> order) {
    // Kiểm tra xem món có đang ở trạng thái "pending" không
    if (order['status'] != 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ có thể xử lý món ở tab "Chưa làm"'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      order['status'] = 'out_of_stock';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Món ${order['dishName']} đã hết'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    final maxWidth = isWeb ? 1200.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Phòng bếp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '23-01-2025',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Không có thông báo mới')),
              );
            },
            tooltip: 'Thông báo',
          ),
          if (isWeb) const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              // Search bar
              Container(
                padding: EdgeInsets.all(isWeb ? 20 : 16),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm món ăn hoặc bàn...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // Tabs
              Container(
                color: Colors.white,
                child:
                    isWeb
                        ? _buildWebTabs()
                        : Row(
                          children: [
                            _buildTab('Chưa làm', 0),
                            _buildTab('Đã làm', 1),
                            _buildTab('Hết món', 2),
                            _buildTab('Đã hủy', 3),
                          ],
                        ),
              ),

              // Header với số lượng
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 20 : 16,
                  vertical: 12,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Danh sách các món*',
                      style: TextStyle(
                        fontSize: isWeb ? 18 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_filteredOrders.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List of dishes
              Expanded(
                child:
                    _filteredOrders.isEmpty
                        ? _buildEmptyState()
                        : (isWeb ? _buildWebList() : _buildMobileList()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có món nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Web tabs with better spacing
  Widget _buildWebTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab('Chưa làm', 0, minWidth: 150),
        _buildTab('Đã làm', 1, minWidth: 150),
        _buildTab('Hết món', 2, minWidth: 150),
        _buildTab('Đã hủy', 3, minWidth: 150),
      ],
    );
  }

  Widget _buildTab(String title, int index, {double? minWidth}) {
    final isSelected = selectedTabIndex == index;
    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth ?? 0),
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedTabIndex = index;
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.blue[700]! : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue[700] : Colors.grey[600],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Mobile list view
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        return _buildDishCard(_filteredOrders[index], false);
      },
    );
  }

  // Web grid view
  Widget _buildWebList() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        return _buildDishCard(_filteredOrders[index], true);
      },
    );
  }

  Widget _buildDishCard(Map<String, dynamic> order, bool isWeb) {
    final bool isPending = selectedTabIndex == 0;
    final bool isCompleted = selectedTabIndex == 1;
    final bool isOutOfStock = selectedTabIndex == 2;
    final bool isCancelled = selectedTabIndex == 3;

    return Container(
      margin: isWeb ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isWeb ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Dish info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  order['dishName'],
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Giờ tạo : ${order['createdTime']}',
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bàn : ${order['tableNumber']}',
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Buttons - CHỈ HIỂN THỊ Ở TAB "CHƯA LÀM"
          if (isPending)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  label: 'Xong',
                  color: Colors.blue[600]!,
                  onPressed: () => _handleComplete(order),
                  isWeb: isWeb,
                ),
                _buildActionButton(
                  label: 'Hết',
                  color: Colors.orange[300]!,
                  onPressed: () => _handleOutOfStock(order),
                  isWeb: isWeb,
                ),
              ],
            ),

          // Status "Chờ lấy" - tab "Đã làm"
          if (isCompleted)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 24 : 20,
                vertical: isWeb ? 12 : 10,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Chờ lấy',
                style: TextStyle(
                  fontSize: isWeb ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),

          // Status "Đã hết" - tab "Hết món"
          if (isOutOfStock)
            Text(
              'Đã hết',
              style: TextStyle(
                fontSize: isWeb ? 16 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.orange[600],
              ),
            ),

          // Status "Đã hủy" - tab "Đã hủy"
          if (isCancelled)
            Text(
              'Đã hủy',
              style: TextStyle(
                fontSize: isWeb ? 16 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isWeb,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 28 : 24,
          vertical: isWeb ? 14 : 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withOpacity(0.1);
          }
          return null;
        }),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isWeb ? 16 : 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
