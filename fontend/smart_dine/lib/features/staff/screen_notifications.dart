import 'package:flutter/material.dart';

// Enum to represent the different states of a notification
enum NotificationStatus { ready, waiting, outOfStock }

class ScreenNotifications extends StatelessWidget {
  const ScreenNotifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Thông báo món', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tất cả thông báo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationItem(
                    itemName: 'Bánh mỳ',
                    time: '12:53',
                    table: 'B-3',
                    status: NotificationStatus.ready,
                  ),
                  _buildNotificationItem(
                    itemName: 'Bánh mỳ',
                    time: '12:53',
                    table: 'B-3',
                    status: NotificationStatus.waiting,
                  ),
                  _buildNotificationItem(
                    itemName: 'Bánh mỳ 2',
                    time: '12:53',
                    table: 'B-3',
                    status: NotificationStatus.outOfStock,
                  ),
                  _buildNotificationItem(
                    itemName: 'Bánh mỳ',
                    time: '12:53',
                    table: 'B-3',
                    status: NotificationStatus.ready,
                  ),
                   _buildNotificationItem(
                    itemName: 'Bánh mỳ',
                    time: '12:53',
                    table: 'B-3',
                    status: NotificationStatus.waiting,
                  ),
                  _buildNotificationItem(
                    itemName: 'Bánh mỳ 2',
                    time: '12:53',
                    table: 'B-3',
                    status: NotificationStatus.outOfStock,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a single notification item
  Widget _buildNotificationItem({
    required String itemName,
    required String time,
    required String table,
    required NotificationStatus status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Item info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Giờ tạo: $time'),
              const SizedBox(height: 4),
              Text('Bàn: $table'),
            ],
          ),
          // Status button
          _buildStatusButton(status),
        ],
      ),
    );
  }

  // Helper widget to build the status button based on the notification status
  Widget _buildStatusButton(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.ready:
        return ElevatedButton(
          onPressed: () {},
          child: const Text('Xác Nhận Lấy Món'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        );
      case NotificationStatus.waiting:
        return ElevatedButton(
          onPressed: null, // Disabled button
          child: const Text('Chờ Lấy Món'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[600],
          ),
        );
      case NotificationStatus.outOfStock:
        return ElevatedButton(
          onPressed: null, // Disabled button
          child: const Text('Món Hết Nguyên Liệu'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        );
    }
  }
}