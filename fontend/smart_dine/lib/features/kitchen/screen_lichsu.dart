import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTimeFilter = 'today'; // today, week, custom

  // Checkbox filters
  final Map<String, bool> _staffFilter = {
    'Nguyễn Văn A': false,
    'Nguyễn Văn B': false,
    'Nguyễn Văn C': false,
    'Nguyễn Văn D': false,
  };

  final Map<String, bool> _dishFilter = {
    'Món khai vị': false,
    'Món chính': false,
    'Món tráng miệng': false,
  };

  // Dữ liệu cứng - Lịch sử đơn hàng
  final List<Map<String, dynamic>> _historyOrders = [
    {
      'dishName': 'Bánh mì',
      'tableNumber': 'b-5',
      'staffName': 'Nguyễn Văn A',
      'time': '10:42 23/9/2025',
      'dishCategory': 'Món chính',
    },
    {
      'dishName': 'Bánh mì',
      'tableNumber': 'A-2',
      'staffName': 'Nguyễn Văn B',
      'time': '10:42 23/9/2025',
      'dishCategory': 'Món chính',
    },
    {
      'dishName': 'Salad',
      'tableNumber': 'b-5',
      'staffName': 'Nguyễn Văn C',
      'time': '10:42 23/9/2025',
      'dishCategory': 'Món khai vị',
    },
    {
      'dishName': 'Kem',
      'tableNumber': 'b-5',
      'staffName': 'Nguyễn Văn A',
      'time': '10:42 23/9/2025',
      'dishCategory': 'Món tráng miệng',
    },
  ];

  List<Map<String, dynamic>> get _filteredHistory {
    List<Map<String, dynamic>> filtered = _historyOrders;

    // Lọc theo nhân viên
    List<String> selectedStaff =
        _staffFilter.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedStaff.isNotEmpty) {
      filtered =
          filtered.where((order) {
            return selectedStaff.contains(order['staffName']);
          }).toList();
    }

    // Lọc theo món ăn
    List<String> selectedDishes =
        _dishFilter.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    if (selectedDishes.isNotEmpty) {
      filtered =
          filtered.where((order) {
            return selectedDishes.contains(order['dishCategory']);
          }).toList();
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
                ) ||
                order['staffName'].toString().toLowerCase().contains(
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Lịch sử đã lấy món',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar với icon filter
          Container(
            padding: EdgeInsets.all(isWeb ? 20 : 16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    _showFilterDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 20 : 16,
              vertical: 12,
            ),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: Text(
              'Tất cả thông báo',
              style: TextStyle(
                fontSize: isWeb ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          // List
          Expanded(
            child:
                _filteredHistory.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: EdgeInsets.all(isWeb ? 20 : 16),
                      itemCount: _filteredHistory.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryCard(
                          _filteredHistory[index],
                          isWeb,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có lịch sử',
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

  Widget _buildHistoryCard(Map<String, dynamic> order, bool isWeb) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isWeb ? 16 : 14),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.receipt_long, color: Colors.grey[700], size: 24),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên món và bàn
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isWeb ? 15 : 14,
                      color: Colors.black87,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Tên món ăn: ',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: order['dishName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '    '),
                      const TextSpan(
                        text: 'Bàn: ',
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: order['tableNumber'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Đã lấy bởi
                Text(
                  'Đã lấy bởi: ${order['staffName']}',
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),

                // Thời gian
                Text(
                  order['time'],
                  style: TextStyle(
                    fontSize: isWeb ? 13 : 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header với nút X
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tất cả thời',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildTab('Hôm nay', 'today'),
                        const SizedBox(width: 8),
                        _buildTab('Tuần này', 'week'),
                        const SizedBox(width: 8),
                        _buildTabWithIcon('Chọn ngày', 'custom'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nhân viên section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Nhân viên',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nhân viên checkboxes
                  ..._staffFilter.keys.map((staff) {
                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return CheckboxListTile(
                          title: Text(staff),
                          value: _staffFilter[staff],
                          onChanged: (value) {
                            setStateDialog(() {
                              _staffFilter[staff] = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          dense: true,
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 16),

                  // Món ăn section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Món ăn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Món ăn checkboxes
                  ..._dishFilter.keys.map((dish) {
                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return CheckboxListTile(
                          title: Text(dish),
                          value: _dishFilter[dish],
                          onChanged: (value) {
                            setStateDialog(() {
                              _dishFilter[dish] = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          dense: true,
                        );
                      },
                    );
                  }),

                  const SizedBox(height: 20),

                  // Nút Xác Nhận
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // Áp dụng filter
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Xác Nhận',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTab(String label, String value) {
    bool isSelected = _selectedTimeFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[600] : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabWithIcon(String label, String value) {
    bool isSelected = _selectedTimeFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[600] : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
