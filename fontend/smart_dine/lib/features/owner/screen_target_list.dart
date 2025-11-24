// file: screens/screen_target_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart' show ShadowCus;
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets_owner/appbar.dart';
import 'screen_add_target.dart' hide ShadowCus, AppBarCus, Style;
import 'package:mart_dine/providers_owner/target_provider.dart'; // Chứa cả 2 provider
import 'package:mart_dine/models_owner/target.dart';
import 'package:mart_dine/models_owner/branch.dart'; // Import model Branch

class ScreenTargetList extends ConsumerWidget { // Sửa thành ConsumerWidget
  const ScreenTargetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Thêm ref
    final targets = ref.watch(targetListProvider); // Vẫn dùng mock target
    // <<< SỬA: Watch FutureProvider >>>
    final branchListAsync = ref.watch(branchListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarCus(
        title: 'Các chỉ tiêu',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenAddTarget()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: targets.isEmpty
              ? const Center(child: Text("Không có chỉ tiêu nào được đặt."))
              // <<< SỬA: Dùng .when() để xử lý branchListAsync >>>
              : branchListAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Lỗi tải chi nhánh: $err')),
                  data: (allBranches) {
                    // Dữ liệu chi nhánh đã sẵn sàng, hiển thị ListView
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                      itemCount: targets.length,
                      itemBuilder: (context, index) {
                        final target = targets[index];
                        
                        // Tra cứu tên chi nhánh từ allBranches (List<Branch>)
                        String branchName = "Không rõ";
                        try {
                           branchName = allBranches.firstWhere((b) => b.id == target.branchId).name;
                        } catch (e) { /*...*/ }
                        
                        final dateRange = "${target.startDate.day}/${target.startDate.month}/${target.startDate.year} - ${target.endDate.day}/${target.endDate.month}/${target.endDate.year}";
                        final isPassed = index % 3 == 0;
                        final percent = isPassed ? "+15%" : "-5%";
                        final color = isPassed ? Colors.green : Colors.red;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _targetCard( // Gọi hàm đã sửa lỗi
                            branchName, dateRange, percent, color, target.targetType,
                            () {
                               Navigator.push(context, MaterialPageRoute(builder: (_) => ScreenAddTarget(targetToEdit: target)));
                            }
                          ),
                        );
                      },
                    );
                  }, // <<< Kết thúc data:
                ), // <<< Kết thúc .when()
          ),
        ],
      ),
    );
  }

  // <<< SỬA LỖI OVERFLOW: Thêm Expanded và xử lý tràn văn bản >>>
  Widget _targetCard(String name, String date, String percent, Color color, String period, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ShadowCus(
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // <<< THÊM: Bọc Column trong Expanded
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  name,
                  style: Style.fontTitle.copyWith(fontSize: 16, color: kTextColorDark),
                  maxLines: 1, // <<< THÊM
                  overflow: TextOverflow.ellipsis, // <<< THÊM
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  style: const TextStyle(color: kTextColorLight, fontSize: 13),
                  maxLines: 1, // <<< THÊM
                  overflow: TextOverflow.ellipsis, // <<< THÊM
                ),
              ]),
            ),
            const SizedBox(width: 8), // Thêm khoảng đệm nhỏ
            Row(
              children: [
                Text(percent, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                  child: Text(period, style: const TextStyle(fontWeight: FontWeight.bold, color: kTextColorDark)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}