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


// StateProvider để giữ ID chi nhánh đang chọn (0 = Tổng quan)
final _selectedBranchIdProvider = StateProvider<int>((ref) => 0);

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

  // SỬA: _restaurantCards dùng Provider `topBranchesProvider`
  Widget _restaurantCards(WidgetRef ref) {
    
    // Watch API Top 4
    final topBranchesAsync = ref.watch(topBranchesProvider);
    // Watch API lấy TẤT CẢ chi nhánh (để lấy tên)
    final allBranchesAsync = ref.watch(branchListProvider);
    
    // Watch state ID đang chọn
    final selectedBranchId = ref.watch(_selectedBranchIdProvider);

    // Hàm xử lý tap
    void handleBranchTap(int tappedBranchId) {
      final notifier = ref.read(_selectedBranchIdProvider.notifier);
      // Nếu nhấn lại chính nó, set về 0 (Tổng quan)
      notifier.state = (selectedBranchId == tappedBranchId) ? 0 : tappedBranchId;
    }

    return topBranchesAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator())),
      error: (err, stack) => Center(child: Text("Lỗi tải Top 4: $err", style: const TextStyle(color: Colors.red))),
      data: (top4Data) { // SỬA 1: Đổi tên tham số 'top4' thành 'top4Data'
        
        // Dùng `allBranchesAsync` để lấy tên chi nhánh
        final allBranches = ref.watch(branchListProvider).value ?? [];
        String getBranchName(int branchId) {
          try {
            return allBranches.firstWhere((b) => b.id == branchId).name;
          } catch (e) {
            return "Chi nhánh $branchId"; // Fallback
          }
        }

        // Helper để tránh lỗi "RangeError"
        BranchRevenueComparison getTopBranch(int index) {
          // SỬA 1: Dùng 'top4Data'
          return top4Data.length > index ? top4Data[index] : BranchRevenueComparison(branchId: -index, totalRevenue: 0.0);
        }

        final top1 = getTopBranch(0);
        final top2 = getTopBranch(1);
        final top3 = getTopBranch(2);
        // SỬA 1: Đổi tên biến 'top4' thành 'topBranch4' để tránh xung đột
        final topBranch4 = getTopBranch(3);

        return Column(
          children: [
            // SỬA: Bọc Row trong IntrinsicHeight để đảm bảo các box có cùng chiều cao
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Đảm bảo các box kéo dài bằng nhau
                children: [
                  Expanded(child: _restaurantBox(top1.totalRevenue, getBranchName(top1.branchId), top1.branchId,
                      isSelected: selectedBranchId == top1.branchId,
                      onTap: () => handleBranchTap(top1.branchId))),
                  const SizedBox(width: 10),
                  Expanded(child: _restaurantBox(top2.totalRevenue, getBranchName(top2.branchId), top2.branchId,
                      isSelected: selectedBranchId == top2.branchId,
                      onTap: () => handleBranchTap(top2.branchId))),
                ],
              ),
            ),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _restaurantBox(top3.totalRevenue, getBranchName(top3.branchId), top3.branchId,
                      isSelected: selectedBranchId == top3.branchId,
                      onTap: () => handleBranchTap(top3.branchId))),
                  const SizedBox(width: 10),
                  Expanded(child: _restaurantBox(topBranch4.totalRevenue, getBranchName(topBranch4.branchId), topBranch4.branchId,
                      isSelected: selectedBranchId == topBranch4.branchId,
                      onTap: () => handleBranchTap(topBranch4.branchId))),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // _restaurantBox (Widget này giữ nguyên như code bạn cung cấp, chỉ hiển thị Doanh thu)
  Widget _restaurantBox(double revenue, String name, int branchId,
   {bool isSelected = false, VoidCallback? onTap}) {

  final value = formatCurrency(revenue); // Dùng helper

    // Vô hiệu hóa tap nếu doanh thu = 0
    final effectiveOnTap = revenue > 0 ? onTap : null;

  return GestureDetector(
   onTap: effectiveOnTap,
   child: ShadowCus(
    borderRadius: 15, // ShadowCus mặc định baseColor là Colors.white
    child: Container(
     padding: const EdgeInsets.all(12),
     decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(15),
       border: isSelected 
                ? Border.all(color: Colors.blue, width: 2) 
                : Border.all(color: Colors.grey.shade200),
   ),
     // SỬA: Loại bỏ Expanded, Column sẽ tự lấp đầy Container.
     child: Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       // 1. Tên chi nhánh
       Text(
        name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        maxLines: 1, overflow: TextOverflow.ellipsis,
       ),
       const SizedBox(height: 6),
   
       // 2. Số tiền doanh thu
       Text(
        revenue > 0 ? value : "Chưa có dữ liệu",
        style: TextStyle(
                fontSize: revenue > 0 ? 16 : 14, 
                fontWeight: FontWeight.bold, 
                color: revenue > 0 ? Colors.black : Colors.black45,
                fontStyle: revenue > 0 ? FontStyle.normal : FontStyle.italic,
              )
       ),
      ],
     ),
    ),
   ),
  );
 }


  // SỬA: _doanhThu dùng Provider `revenueChartProvider`
  Widget _doanhThu(WidgetRef ref) {
    // State cho Filter (Tuan/Thang/Nam)
    final revenueFilter = ref.watch(_revenueFilterProvider);
    // Watch API
    // SỬA 2: Truyền 'revenueFilter' (đã được import)
    final chartDataAsync = ref.watch(revenueChartProvider(revenueFilter));

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
    // SỬA 2: Truyền 'orderFilter' (đã được import)
    final chartDataAsync = ref.watch(orderChartProvider(orderFilter));

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
              _restaurantCards(ref),
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