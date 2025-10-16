import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    // Dữ liệu mẫu thông báo chi tiết
    final allNotifications = [
      {
        'category': 'Thanh toán',
        'icon': Icons.payment,
        'iconColor': Colors.green,
        'type': 'Hà Đức Lương',
        'message': 'đã thanh toán Bàn 05 - 285,000đ',
        'time': '2 phút trước',
        'isNew': true,
      },
      {
        'category': 'Bàn ăn',
        'icon': Icons.table_restaurant,
        'iconColor': Colors.blue,
        'type': 'Phúc',
        'message': 'đã tạo đơn mới cho Bàn 12',
        'time': '5 phút trước',
        'isNew': true,
      },
      {
        'category': 'Thanh toán',
        'icon': Icons.payment,
        'iconColor': Colors.green,
        'type': 'Tú Kiệt',
        'message': 'đã thanh toán Bàn 03 - 180,000đ',
        'time': '10 phút trước',
        'isNew': true,
      },
      {
        'category': 'Bàn ăn',
        'icon': Icons.edit_note,
        'iconColor': Colors.orange,
        'type': 'Hà Đức Lương',
        'message': 'đã cập nhật món cho Bàn 08 (+2 món)',
        'time': '15 phút trước',
        'isNew': false,
      },
      {
        'category': 'Đơn hàng',
        'icon': Icons.cancel,
        'iconColor': Colors.red,
        'type': 'Hệ thống',
        'message': 'Đơn hàng #ĐH006 đã bị hủy',
        'time': '20 phút trước',
        'isNew': false,
      },
      {
        'category': 'Bàn ăn',
        'icon': Icons.add_circle,
        'iconColor': Colors.blue,
        'type': 'Phúc',
        'message': 'đã tạo đơn cho Bàn 15',
        'time': '25 phút trước',
        'isNew': false,
      },
      {
        'category': 'Thanh toán',
        'icon': Icons.payment,
        'iconColor': Colors.green,
        'type': 'Tú Kiệt',
        'message': 'đã thanh toán Bàn 07 - 195,000đ',
        'time': '30 phút trước',
        'isNew': false,
      },
      {
        'category': 'Đơn hàng',
        'icon': Icons.restaurant_menu,
        'iconColor': Colors.purple,
        'type': 'Nhà bếp',
        'message': 'Món "Phở bò" sắp hết (còn 5 suất)',
        'time': '45 phút trước',
        'isNew': false,
      },
      {
        'category': 'Bàn ăn',
        'icon': Icons.notifications_active,
        'iconColor': Colors.amber,
        'type': 'Bàn 12',
        'message': 'đang chờ phục vụ quá 10 phút',
        'time': '1 giờ trước',
        'isNew': false,
      },
      {
        'category': 'Thanh toán',
        'icon': Icons.credit_card,
        'iconColor': Colors.green,
        'type': 'Hà Đức Lương',
        'message': 'đã thanh toán qua thẻ - Bàn 02',
        'time': '1 giờ trước',
        'isNew': false,
      },
    ];

    // Lọc thông báo theo filter
    final notifications = _selectedFilter == 'Tất cả'
        ? allNotifications
        : allNotifications.where((n) => n['category'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Thông báo', style: Style.fontTitle),
      ),
      body: Column(
        children: [
          // Filter buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', _selectedFilter == 'Tất cả', textColor, () {
                    setState(() {
                      _selectedFilter = 'Tất cả';
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Thanh toán', _selectedFilter == 'Thanh toán', textColor, () {
                    setState(() {
                      _selectedFilter = 'Thanh toán';
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Bàn ăn', _selectedFilter == 'Bàn ăn', textColor, () {
                    setState(() {
                      _selectedFilter = 'Bàn ăn';
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đơn hàng', _selectedFilter == 'Đơn hàng', textColor, () {
                    setState(() {
                      _selectedFilter = 'Đơn hàng';
                    });
                  }),
                ],
              ),
            ),
          ),
          
          // Notifications list
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Style.textColorGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có thông báo',
                          style: Style.fontNormal.copyWith(
                            color: Style.textColorGray,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(
                        notification['icon'] as IconData,
                        notification['iconColor'] as Color,
                        notification['type'] as String,
                        notification['message'] as String,
                        notification['time'] as String,
                        notification['isNew'] as bool,
                        cardColor,
                        textColor,
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Style.textColorGray,
          ),
        ),
        child: Text(
          label,
          style: Style.fontNormal.copyWith(
            color: isSelected ? Colors.white : textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    IconData icon,
    Color iconColor,
    String type,
    String message,
    String time,
    bool isNew,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon với background
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Style.fontNormal.copyWith(
                            color: textColor,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: type,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' $message'),
                          ],
                        ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Style.textColorGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: Style.fontCaption.copyWith(
                        color: Style.textColorGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
