// file: screens/screen_staff_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import
import 'package:mart_dine/widgets_owner/_charts.dart';
import 'package:mart_dine/widgets_owner/_staff_detail_widgets.dart';
import 'package:mart_dine/features/owner/screen_edit_staff_info.dart';
import 'package:mart_dine/models_owner/staff_profile.dart';
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/providers_owner/staff_profile_provider.dart';
// THÊM: Import provider và model cần thiết
import 'package:mart_dine/providers_owner/order_provider.dart';

class ScreenStaffDetail extends ConsumerStatefulWidget {
  final StaffProfile profile;
  const ScreenStaffDetail({super.key, required this.profile});
  @override
  ConsumerState<ScreenStaffDetail> createState() => _ScreenStaffDetailState();
}

class _ScreenStaffDetailState extends ConsumerState<ScreenStaffDetail> {
  String _selectedChartPeriod = 'Tháng'; // Giữ nguyên state cho filter

  @override
  Widget build(BuildContext context) {
    // Theo dõi Notifier để rebuild khi có cập nhật (Khóa/Mở khóa)
    final stateAsync = ref.watch(staffProfileUpdateNotifierProvider);
    // Theo dõi FutureProvider để lấy dữ liệu user mới nhất
    final profileAsync = ref.watch(staffProfileProvider);
    
    // Tìm profile mới nhất trong list (hoặc dùng profile cũ nếu đang load/lỗi)
    final StaffProfile currentProfile = profileAsync.maybeWhen(
       data: (profiles) {
         try {
           return profiles.firstWhere((p) => p.user.id == widget.profile.user.id);
         } catch(e) { return widget.profile; } // Fallback
       },
       orElse: () => widget.profile, // Dùng profile cũ khi đang loading/error
    );

    final User user = currentProfile.user;
    final String roleName = currentProfile.role.name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("Thông tin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          _buildPopupMenu(context, ref, user), // Truyền user đã cập nhật
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Thông tin nhân viên", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                const SizedBox(height: 15),
                StaffInfoCard(user: user, roleName: roleName), // Truyền User và roleName
                const SizedBox(height: 20),
                // SỬA: Truyền user.id vào để lọc đơn hàng
                _buildOrderChartSection(user.id!),
                const SizedBox(height: 20),
                // SỬA: Truyền staffId vào widget
                StaffOrderList(staffId: user.id!),
                const SizedBox(height: 40),
              ],
            ),
          ),
          // Hiển thị loading overlay
          if (stateAsync.isLoading)
             Container(
               color: Colors.black.withOpacity(0.3),
               child: const Center(child: CircularProgressIndicator()),
             ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref, User user) {
    bool isLocked = user.statusId == 2;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (String result) {
        _handleMenuAction(context, ref, result, user);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'edit', child: Text('Sửa thông tin', style: TextStyle(color: Colors.blue))),
        PopupMenuItem<String>(value: 'toggle_lock', child: Text(isLocked ? 'Mở khóa' : 'Khóa')),
        const PopupMenuItem<String>(value: 'delete', child: Text('Xóa Tài Khoản', style: TextStyle(color: Colors.red))),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, User user) {
    if (action == 'edit') {
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
        ScreenEditStaffInfo(profile: widget.profile), // Truyền profile gốc
      ));
    } else if (action == 'toggle_lock') {
      ref.read(staffProfileUpdateNotifierProvider.notifier).toggleUserStatus(user);
    } else if (action == 'delete') {
      ref.read(staffProfileUpdateNotifierProvider.notifier).deleteUser(user.id!);
      Navigator.pop(context);
    }
  }

  // (Phần biểu đồ giữ nguyên)
  // SỬA: Thêm staffId và dùng dữ liệu thật
  Widget _buildOrderChartSection(int staffId) {
    final allOrdersAsync = ref.watch(allOrdersProvider);

    return allOrdersAsync.when(
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => SizedBox(height: 100, child: Center(child: Text("Lỗi tải dữ liệu biểu đồ: $err"))),
      data: (allOrders) {
        // Lọc đơn hàng của nhân viên này
        final staffOrders = allOrders.where((order) => order.userId == staffId).toList();

        // Xử lý dữ liệu cho biểu đồ dựa trên filter
        Map<String, int> groupedData = {};
        DateTime now = DateTime.now();

        if (_selectedChartPeriod == 'Tuần') {
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          for (int i = 0; i < 7; i++) {
            DateTime day = startOfWeek.add(Duration(days: i));
            String dayKey = "${day.day}/${day.month}";
            groupedData[dayKey] = 0;
          }
          for (var order in staffOrders) {
            if (order.createdAt.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && order.createdAt.isBefore(startOfWeek.add(const Duration(days: 7)))) {
              String dayKey = "${order.createdAt.day}/${order.createdAt.month}";
              groupedData[dayKey] = (groupedData[dayKey] ?? 0) + 1;
            }
          }
        } else if (_selectedChartPeriod == 'Tháng') {
          for (int i = 1; i <= now.day; i++) {
            groupedData["$i/${now.month}"] = 0;
          }
          for (var order in staffOrders) {
            if (order.createdAt.year == now.year && order.createdAt.month == now.month) {
              String dayKey = "${order.createdAt.day}/${now.month}";
              groupedData[dayKey] = (groupedData[dayKey] ?? 0) + 1;
            }
          }
        } else { // Năm
          for (int i = 1; i <= 12; i++) {
            groupedData["T$i"] = 0;
          }
          for (var order in staffOrders) {
            if (order.createdAt.year == now.year) {
              String monthKey = "T${order.createdAt.month}";
              groupedData[monthKey] = (groupedData[monthKey] ?? 0) + 1;
            }
          }
        }

        final chartLabels = groupedData.keys.toList();
        // BarChartPainter nhận List<List<int>>, ta chỉ có 1 cột dữ liệu
        final chartValues = groupedData.values.map((count) => [count]).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Đơn đã tạo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _chartButton("Năm", 'Năm'),
                _chartButton("Tháng", 'Tháng'),
                _chartButton("Tuần", 'Tuần'),
              ],
            ),
            const SizedBox(height: 10),
            if (staffOrders.isEmpty)
              const SizedBox(height: 200, child: Center(child: Text("Nhân viên chưa tạo đơn hàng nào.")))
            else
              SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: BarChartPainter(chartValues, chartLabels),
                  child: Container(),
                ),
              ),
          ],
        );
      },
    );
  }

  // Nút chọn kỳ hạn cho biểu đồ (Không thay đổi)
  Widget _chartButton(String text, String period) {
    bool selected = _selectedChartPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartPeriod = period),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black26),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}