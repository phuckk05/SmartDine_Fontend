import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScreenCashierReport extends StatefulWidget {
  const ScreenCashierReport({Key? key}) : super(key: key);

  @override
  State<ScreenCashierReport> createState() => _ScreenCashierReportState();
}

class _ScreenCashierReportState extends State<ScreenCashierReport> {
  final GlobalKey _filterButtonKey = GlobalKey(); // Key để lấy vị trí nút filter
  OverlayEntry? _overlayEntry; // Biến quản lý overlay

  String _selectedFilterText = 'Tất cả'; // Text hiển thị trên nút filter

  // Hàm tạo overlay
  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = _filterButtonKey.currentContext!.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5.0, // Vị trí ngay dưới nút filter
        width: 300, // Chiều rộng của overlay
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Màu nền xám nhạt cho overlay
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Lọc theo thời gian', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap( // Dùng Wrap để các chip tự xuống hàng
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    _buildFilterChip('Ca làm việc', () => _applyFilter('Ca làm việc')),
                    _buildFilterChip('Theo ngày', () => _applyFilter('Theo ngày')),
                    _buildFilterChip('Theo tuần', () => _applyFilter('Theo tuần')),
                    _buildFilterChip('Theo tháng', () => _applyFilter('Theo tháng')),
                    _buildFilterChip('Tùy chọn', () => _applyFilter('Tùy chọn TG')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hàm hiển thị hoặc ẩn overlay
  void _toggleOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    setState(() {}); // Cập nhật trạng thái để icon nút filter thay đổi (nếu cần)
  }

  // Hàm áp dụng filter (hiện tại chỉ đóng overlay và cập nhật text)
  void _applyFilter(String filterText) {
    setState(() {
      _selectedFilterText = filterText; // Cập nhật text trên nút filter
      // TODO: Thêm logic lọc dữ liệu báo cáo dựa trên filterText
    });
    _overlayEntry?.remove(); // Đóng overlay
    _overlayEntry = null;
  }

  // Widget cho một chip lọc trong overlay
  Widget _buildFilterChip(String label, VoidCallback onPressed) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      backgroundColor: Colors.blue[100],
      labelStyle: TextStyle(color: Colors.blue[800]),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove(); // Đảm bảo overlay được xóa khi widget bị hủy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu
    const totalOrders = 120;
    const revenue = 2086588;
    const cancelledOrders = 10;

    final currencyFormatter = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      backgroundColor: Colors.grey[100], // Nền xám nhạt
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Báo cáo thu ngân', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nút Filter
            ActionChip(
              key: _filterButtonKey, // Gán key cho nút
              avatar: const Icon(Icons.filter_list, size: 18),
              label: Text(_selectedFilterText),
              onPressed: _toggleOverlay, // Gọi hàm toggle overlay khi nhấn
              backgroundColor: Colors.blue[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.blue[200]!),
              ),
            ),
            const SizedBox(height: 24),

            // Các số liệu thống kê
            _buildStatCard(
              title: 'Tổng số đơn đã tạo',
              value: totalOrders.toString(),
              subtitle: 'Doanh thu theo ca/ngày/tháng/năm',
              revenue: '${currencyFormatter.format(revenue)}', // Không có đơn vị tiền tệ ở đây
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              title: 'Số lần hủy đơn',
              value: cancelledOrders.toString(),
            ),

            const Spacer(), // Đẩy nút Export PDF xuống dưới

            // Nút Export PDF
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Thêm logic xuất file PDF
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Xuất PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để tạo card thống kê
  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    String? revenue,
  }) {
    return Container(
      width: double.infinity, // Chiếm hết chiều ngang
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đặt value và revenue/subtitle ở 2 đầu
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Title và Value (bên trái)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                value, // Value lên trên
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
               const SizedBox(height: 4),
              Text(
                title, // Title xuống dưới
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),

            ],
          ),
          // Phần Subtitle và Revenue (bên phải, nếu có)
          if (subtitle != null && revenue != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                 Text(
                  revenue,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                 const SizedBox(height: 4),
                 Text(
                  subtitle,
                  textAlign: TextAlign.end,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
