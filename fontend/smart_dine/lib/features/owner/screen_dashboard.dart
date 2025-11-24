// file: screens/screen_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Thay thế bằng đường dẫn thực tế của bạn
import 'package:mart_dine/core/constrats.dart' show ShadowCus, kTextColorDark, kTextColorLight; 
import 'package:mart_dine/core/style.dart';

// Import các màn hình/file mới
import 'screen_target_list.dart'; 
import 'screen_profile.dart'; 
import 'screen_order_list.dart'; 
import 'screen_management.dart'; 
import 'package:mart_dine/widgets_owner/_custom_bottom_nav_bar.dart';
import 'package:mart_dine/widgets_owner/_charts.dart'; 

// SỬA: Import các API và Provider MỚI
import 'package:mart_dine/providers_owner/target_provider.dart' show branchListProvider; 
import 'package:mart_dine/providers_owner/dashboard_provider.dart';
import 'package:mart_dine/models_owner/branch.dart'; 
import 'package:mart_dine/providers_owner/role_provider.dart' show formatDate, formatCurrency;
import 'package:mart_dine/API_owner/payment_API.dart'; // <<< API DOANH THU
import 'package:mart_dine/API_owner/order_API.dart';
import 'package:mart_dine/features/owner/screen_menu_management.dart';
import 'package:mart_dine/providers_owner/system_stats_provider.dart'; // <<< THÊM IMPORT NÀY


// SỬA: Loại bỏ StateProvider cho việc chọn chi nhánh, vì giờ chỉ hiển thị tổng quan
// final _selectedBranchIdProvider = StateProvider<int>((ref) => 0);

class ScreenDashboard extends ConsumerStatefulWidget {
  const ScreenDashboard({super.key});

  @override
  ConsumerState<ScreenDashboard> createState() => _ScreenDashboardState();
}

class _ScreenDashboardState extends ConsumerState<ScreenDashboard> {
  int _selectedIndex = 0;

  // Danh sách các màn hình cho BottomNavBar
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardView(), // Giao diện Dashboard gốc
    ScreenManagement(),
    ScreenMenuManagement(), // Màn hình Menu placeholder
    ScreenProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SỬA: AppBar được quản lý ở đây, chỉ hiển thị cho tab Dashboard
      appBar: _selectedIndex == 0
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart, color: Colors.black),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenTargetList())),
                )
              ],
            )
          : null,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// SỬA: Widget này giờ chỉ chứa nội dung của tab Dashboard, không có Scaffold/AppBar
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  // SỬA: Widget mới để hiển thị các thẻ thống kê tổng quan
  Widget _summaryCards(WidgetRef ref) {
    // Lấy dữ liệu từ các provider
    final statsAsync = ref.watch(systemStatsProvider); // SỬA: Đổi tên để thể hiện đây là AsyncValue
    final allBranchesAsync = ref.watch(branchListProvider);

    // SỬA: Dùng .when để xử lý trạng thái của systemStatsProvider
    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text("Lỗi tải thống kê: $err"),
      data: (stats) {
        final staffCount = stats['total_staff'] ?? '0';
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _summaryBox(
                    'Tổng doanh thu',
                    // SỬA: Ép kiểu (cast) giá trị sang double để khớp với yêu cầu của formatCurrency
                    formatCurrency((stats['total_revenue'] as num? ?? 0.0).toDouble()),
                    Icons.monetization_on,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryBox(
                    'Tổng đơn hàng',
                    (stats['total_orders'] ?? 0).toString(),
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: allBranchesAsync.when(
                    data: (branches) => _summaryBox(
                      'Tổng chi nhánh',
                      branches.length.toString(),
                      Icons.store,
                      Colors.green,
                    ),
                    loading: () => _summaryBox('Tổng chi nhánh', '...', Icons.store, Colors.green),
                    error: (e, s) => _summaryBox('Tổng chi nhánh', 'Lỗi', Icons.store, Colors.green),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryBox(
                    'Tổng nhân viên',
                    staffCount.toString(),
                    Icons.people,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Widget con cho mỗi thẻ thống kê
  Widget _summaryBox(String title, String value, IconData icon, Color color) {
    return ShadowCus(
      borderRadius: 15,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SỬA: _doanhThu dùng Provider `revenueChartProvider`
  Widget _doanhThu(WidgetRef ref) {
    // State cho Filter (Tuan/Thang/Nam)
    final revenueFilter = ref.watch(_revenueFilterProvider);
    // SỬA: Truyền một tuple (filter, branchId) vào provider.
    // Vì đây là dashboard tổng quan, branchId là null.
    final chartDataAsync = ref.watch(revenueChartProvider((revenueFilter, null)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chartHeader("Doanh thu", revenueFilter, (f) => ref.read(_revenueFilterProvider.notifier).state = f),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SizedBox(
            height: 220,
            // Dùng .when() để xử lý Async
            child: chartDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Lỗi tải biểu đồ: $e", style: TextStyle(color: Colors.red, fontSize: 12))),
              data: (chartData) {
                // Chuyển đổi DTO (ChartData) sang List<int> và List<String>
                final List<int> data = chartData.map((d) => d.value.toInt()).toList();
                final List<String> labels = chartData.map((d) => d.label).toList();
                
                // THÊM: Kiểm tra nếu tất cả dữ liệu bằng 0 để tránh lỗi chia cho 0
                final isAllZero = data.every((d) => d == 0);
                if (isAllZero) {
                  return const Center(child: Text("Không có dữ liệu doanh thu."));
                }

                // Cần xử lý labels (ví dụ: '2025-11-07' -> '07/11')
                // SỬA: Dùng asMap().entries để lấy index và giảm bớt số lượng label
                final formattedLabels = labels.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final String dateStr = entry.value;

                    // Chỉ hiển thị label mỗi 5 ngày (cho filter Tháng) hoặc 2 tháng (cho filter Năm)
                    if ((revenueFilter == ChartFilter.Thang && index % 5 != 0) || (revenueFilter == ChartFilter.Nam && index % 2 != 0)) {
                      return ''; // Trả về chuỗi rỗng để không vẽ label
                    }

                    try {
                      // API (PaymentController) trả về nhiều định dạng (date, month/year)
                      if (dateStr.contains('-')) { // Là 'date'
                        final date = DateTime.parse(dateStr);
                        if (revenueFilter == ChartFilter.Nam) return "T${date.month}";
                        return "${date.day}/${date.month}"; // Lọc theo Tuần/Tháng, backend trả 'daily'
                      }
                      return dateStr; // Là 'month/year'
                    } catch (e) {
                      return dateStr; // Fallback
                    }
                }).toList();

                return CustomPaint(
                  painter: LineChartPainter(data, formattedLabels),
                  child: Container(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
  
  // SỬA: _donHang dùng Provider `orderChartProvider`
  Widget _donHang(WidgetRef ref) {
    final orderFilter = ref.watch(_orderFilterProvider);
    // SỬA: Truyền một tuple (filter, branchId) vào provider.
    // Vì đây là dashboard tổng quan, branchId là null.
    final chartDataAsync = ref.watch(orderChartProvider((orderFilter, null)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chartHeader("Đơn hàng", orderFilter, (f) => ref.read(_orderFilterProvider.notifier).state = f),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SizedBox(
            height: 220,
            child: chartDataAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Lỗi tải biểu đồ: $e", style: TextStyle(color: Colors.red, fontSize: 12))),
              data: (chartData) {
                // Chuyển đổi DTO (OrderCountData)
                final List<List<int>> data = chartData.map((d) {
                    // Giả lập 3 vạch (API của bạn chỉ trả về 1 vạch)
                    return [d.count, 0, 0]; 
                }).toList();
                
                final List<String> labels = chartData.map((d) => d.label).toList();

                // THÊM: Kiểm tra nếu tất cả dữ liệu bằng 0 để tránh lỗi chia cho 0
                final isAllZero = data.every((bar) => bar.every((val) => val == 0));
                if (isAllZero) {
                  return const Center(child: Text("Không có dữ liệu đơn hàng."));
                }
                
                // Cần xử lý labels
                // SỬA: Dùng asMap().entries để lấy index và giảm bớt số lượng label
                final formattedLabels = labels.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final String dateStr = entry.value;

                    // Chỉ hiển thị label mỗi 5 ngày (cho filter Tháng) hoặc 2 tháng (cho filter Năm)
                    if ((orderFilter == ChartFilter.Thang && index % 5 != 0) || (orderFilter == ChartFilter.Nam && index % 2 != 0)) {
                      return ''; // Trả về chuỗi rỗng để không vẽ label
                    }

                    try {
                      // API (OrderController) trả về nhiều định dạng (date, startDate, month/year)
                      if (dateStr.contains('-')) { // Là 'date' hoặc 'startDate'
                        final date = DateTime.parse(dateStr);
                        if (orderFilter == ChartFilter.Nam) return "T${date.month}";
                        return "${date.day}/${date.month}";
                      }
                      return dateStr; // Là 'month/year'
                    } catch (e) {
                      return dateStr; // Fallback
                    }
                }).toList();

                return CustomPaint(
                  painter: BarChartPainter(data, formattedLabels),
                  child: Container(),
                );
              },
            ),
     ),
    ),
   ],
  );
 }

  // _chartHeader và _chartButton (Giữ nguyên)
  Widget _chartHeader(String title, ChartFilter currentFilter, ValueChanged<ChartFilter> onFilterChanged) {
   return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
     Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
     Row(
     children: [
       _chartButton("Năm", selected: currentFilter == ChartFilter.Nam, onTap: () => onFilterChanged(ChartFilter.Nam)),
       _chartButton("Tháng", selected: currentFilter == ChartFilter.Thang, onTap: () => onFilterChanged(ChartFilter.Thang)),
       _chartButton("Tuần", selected: currentFilter == ChartFilter.Tuan, onTap: () => onFilterChanged(ChartFilter.Tuan)),
     ],
     )
    ],
   );
  }
  Widget _chartButton(String text, {required bool selected, required VoidCallback onTap}) {
   return Material( // <<< SỬA: Bọc bằng Material
     color: selected ? Colors.black : Colors.white, // <<< Chuyển màu lên đây
     borderRadius: BorderRadius.circular(10),
     clipBehavior: Clip.antiAlias, // Đảm bảo InkWell bị cắt theo góc tròn
     child: InkWell(
       onTap: onTap, 
       // borderRadius: BorderRadius.circular(10), // Không cần nữa
       child: Container( // <<< Container bây giờ chỉ còn border
         margin: const EdgeInsets.only(left: 5),
         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
         decoration: BoxDecoration( 
           color: Colors.transparent, // <<< Đặt màu trong suốt
           borderRadius: BorderRadius.circular(10), 
           border: Border.all(color: Colors.black12),
         ),
         child: Text(text, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
       ),
     ),
   );
 }

  @override
Widget build(BuildContext context, WidgetRef ref) {
    // SỬA: Loại bỏ Scaffold và AppBar, chỉ giữ lại phần body
    return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryCards(ref), // SỬA: Thay thế bằng widget mới
              const SizedBox(height: 15), // SỬA: Giảm khoảng cách để tránh overflow
              _doanhThu(ref),
              const SizedBox(height: 10), // SỬA: Giảm khoảng cách để tránh overflow
              _donHang(ref),
            ],
          ),
        ),
      );
}
}

// SỬA: Thêm StateProvider cho các filter của biểu đồ
final _revenueFilterProvider = StateProvider<ChartFilter>((ref) => ChartFilter.Thang);
final _orderFilterProvider = StateProvider<ChartFilter>((ref) => ChartFilter.Thang);