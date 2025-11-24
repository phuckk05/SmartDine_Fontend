// file: screens/screen_add_target.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart' show ShadowCus, kTextColorDark, kTextColorLight;
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets_owner/appbar.dart';
import 'package:mart_dine/providers_owner/target_provider.dart';
import 'package:mart_dine/models_owner/target.dart';
// SỬA: Import model Branch
import 'package:mart_dine/models_owner/branch.dart';

// Provider cho loại chỉ tiêu (Năm/Tháng/Tuần)
final _targetTypeProvider = StateProvider<String>((ref) => "Năm");

// Provider cục bộ cho ID chi nhánh được chọn
// Sẽ được cập nhật trong initState (nếu sửa) hoặc build (nếu thêm mới)
final _selectedBranchIdProvider = StateProvider<int?>((ref) => null);


class ScreenAddTarget extends ConsumerStatefulWidget {
  final Target? targetToEdit;

  const ScreenAddTarget({super.key, this.targetToEdit});

  @override
  ConsumerState<ScreenAddTarget> createState() => _ScreenAddTargetState();
}

class _ScreenAddTargetState extends ConsumerState<ScreenAddTarget> {
  final TextEditingController _moneyCtrl = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    final target = widget.targetToEdit;

    // Khởi tạo giá trị ban đầu (chỉ chạy 1 lần sau khi build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // Set loại chỉ tiêu (Năm/Tháng/Tuần)
       ref.read(_targetTypeProvider.notifier).state = target?.targetType ?? "Năm";
       // Set ID chi nhánh (nếu đang ở chế độ sửa)
       ref.read(_selectedBranchIdProvider.notifier).state = target?.branchId;
    });

    // Điền dữ liệu text/date nếu ở chế độ Sửa
    if (target != null) {
      _moneyCtrl.text = target.targetAmount.toStringAsFixed(0);
      startDate = target.startDate;
      endDate = target.endDate;
    }
  }

  @override
  void dispose() {
    _moneyCtrl.dispose();
    super.dispose();
  }

  // Hàm hiển thị DatePicker
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        // Theme cho DatePicker
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: kTextColorDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // Hàm xử lý Thêm hoặc Sửa
  void _saveTarget() {
    // Lấy state từ các provider
    final int? branchId = ref.read(_selectedBranchIdProvider);
    final String targetType = ref.read(_targetTypeProvider);

    // 1. Kiểm tra dữ liệu bắt buộc
    if (startDate == null || endDate == null || _moneyCtrl.text.isEmpty || branchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đủ thông tin.")),
      );
      return;
    }

    // 2. Kiểm tra logic thời gian
    final DateTime today = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, microsecond: 0);
    if (startDate!.isAfter(endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: Ngày bắt đầu phải trước hoặc bằng Ngày kết thúc.")),
      );
      return;
    }
    if (widget.targetToEdit == null && endDate!.isBefore(today)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: Không thể đặt chỉ tiêu có Ngày kết thúc trong quá khứ.")),
      );
      return;
    }

    // 3. Tiến hành lưu (vẫn dùng mock Notifier cho Target)
    final targetAmount = double.tryParse(_moneyCtrl.text) ?? 0.0;
    final Target target;

    if (widget.targetToEdit == null) { // Thêm mới
      target = Target(
        id: 0, // Notifier sẽ tự gán ID
        branchId: branchId,
        targetAmount: targetAmount,
        targetType: targetType,
        startDate: startDate!,
        endDate: endDate!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // TODO: Thay bằng lời gọi API tạo Target
      ref.read(targetListProvider.notifier).addTarget(target);
    } else { // Chỉnh sửa
      target = widget.targetToEdit!.copyWith(
        branchId: branchId,
        targetAmount: targetAmount,
        targetType: targetType,
        startDate: startDate,
        endDate: endDate,
        updatedAt: DateTime.now(),
      );
       // TODO: Thay bằng lời gọi API cập nhật Target
      ref.read(targetListProvider.notifier).updateTarget(target);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Watch các provider cần thiết
    final type = ref.watch(_targetTypeProvider);
    final selectedBranchId = ref.watch(_selectedBranchIdProvider);
    // Watch FutureProvider để lấy AsyncValue
    final branchListAsync = ref.watch(branchListProvider);
    final isEditing = widget.targetToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarCus(title: isEditing ? 'Chỉnh sửa chỉ tiêu' : 'Đặt chỉ tiêu'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // --- Dòng Chọn Chi nhánh (Xử lý AsyncValue) ---
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Chọn chi nhánh', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10), // Thêm khoảng cách nhỏ

                  // <<< SỬA LỖI: Bọc AsyncValue.when trong Flexible >>>
                  Flexible(
                    child: branchListAsync.when(
                      // 1. Trạng thái Đang tải
                      loading: () => const Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      // 2. Trạng thái Lỗi
                      error: (err, stack) => Text('Lỗi tải', style: TextStyle(color: Colors.red.shade700), overflow: TextOverflow.ellipsis),
                      // 3. Trạng thái Thành công (có dữ liệu)
                      data: (allBranches) {
                        // ... (Logic chọn mặc định giữ nguyên) ...
                        if (selectedBranchId == null && allBranches.isNotEmpty && !isEditing) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                             if (ref.read(_selectedBranchIdProvider) == null) {
                                ref.read(_selectedBranchIdProvider.notifier).state = allBranches.first.id;
                             }
                          });
                        }
                        final bool isValidSelection = selectedBranchId != null && allBranches.any((b) => b.id == selectedBranchId);

                        return DropdownButton<int>(
                          value: isValidSelection ? selectedBranchId : null,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          underline: const SizedBox(),
                          // <<< SỬA LỖI: Thêm isExpanded và bọc Text trong Container >>>
                          isExpanded: true, // Cho phép Dropdown mở rộng
                          items: allBranches.map((Branch branch) {
                            return DropdownMenuItem<int>(
                              value: branch.id,
                              child: Container( // Bọc Text trong Container
                                alignment: Alignment.centerRight, // Căn phải
                                child: Text(
                                  branch.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis, // Chống tràn
                                  maxLines: 1,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(_selectedBranchIdProvider.notifier).state = value;
                            }
                          },
                          hint: Text(allBranches.isEmpty ? "Không có CN" : "Chọn", textAlign: TextAlign.right),
                        );
                      },
                    ),
                  ), // <<< KẾT THÚC Flexible
                ],
              ),
              // --- Kết thúc Dòng Chọn Chi nhánh ---
              const SizedBox(height: 20),
              // Dòng Chỉ tiêu (Buttons Năm, Tháng, Tuần)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Chỉ tiêu', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  ...["Năm", "Tháng", "Tuần"].map((e) {
                    final selected = e == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => ref.read(_targetTypeProvider.notifier).state = e,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? Colors.black : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(e, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 20),
              // Nhập số tiền
              const Text('Nhập số tiền', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ShadowCus(
                  isConcave: true, borderRadius: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: TextField(
                      controller: _moneyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          hintText: "",
                          hintStyle: TextStyle(color: kTextColorLight),
                          border: InputBorder.none,
                      ),
                      style: const TextStyle(color: kTextColorDark),
                  ),
              ),
              const SizedBox(height: 20),
              // Thời gian bắt đầu/kết thúc
              Row(
                  children: const [
                      Expanded(child: Text("Thời gian bắt đầu", style: TextStyle(fontWeight: FontWeight.bold, color: kTextColorDark))),
                      SizedBox(width: 10),
                      Expanded(child: Text("Thời gian kết thúc", style: TextStyle(fontWeight: FontWeight.bold, color: kTextColorDark))),
                  ],
                ),
                const SizedBox(height: 10),
              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: ShadowCus(
                        isConcave: true, borderRadius: 10, padding: const EdgeInsets.all(12),
                        child: Text(
                          startDate == null ? "" : "${startDate!.day}-${startDate!.month}-${startDate!.year}",
                          style: const TextStyle(color: kTextColorDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: ShadowCus(
                        isConcave: true, borderRadius: 10, padding: const EdgeInsets.all(12),
                        child: Text(
                          endDate == null ? "" : "${endDate!.day}-${endDate!.month}-${endDate!.year}",
                          style: const TextStyle(color: kTextColorDark),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Button Thêm/Lưu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ShadowCus(
                  borderRadius: 20, baseColor: Colors.blue, padding: EdgeInsets.zero,
                  child: MaterialButton(
                    onPressed: _saveTarget,
                    color: Colors.transparent, elevation: 0, highlightElevation: 0,
                    splashColor: Colors.white.withAlpha(51), minWidth: double.infinity, height: 50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Text(isEditing ? 'Lưu' : 'Thêm', style: Style.TextButton),
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
}

// ----- Các Widget Helper Giả định (Bạn cần có các file này) -----

// Giả định từ: mart_dine/core/constrats.dart
class ShadowCus extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color baseColor;
  final bool isConcave;
  final Border? border; // Thêm border
  const ShadowCus({ super.key, required this.child, this.borderRadius = 0.0, this.padding = EdgeInsets.zero, this.baseColor = Colors.white, this.isConcave = false, this.border});
  @override Widget build(BuildContext context) {
    return Container( padding: padding, decoration: BoxDecoration( color: baseColor, borderRadius: BorderRadius.circular(borderRadius), border: border, boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1))]), child: child );
  }
}
const Color kTextColorDark = Colors.black87;
const Color kTextColorLight = Colors.black54;

// Giả định từ: mart_dine/widgets/appbar.dart
class AppBarCus extends StatelessWidget implements PreferredSizeWidget {
  final String title; final List<Widget>? actions; final bool? isCanpop;
  const AppBarCus({super.key, required this.title, this.actions, this.isCanpop});
  @override Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white, elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: actions, automaticallyImplyLeading: isCanpop ?? true,
    );
  }
  @override Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Giả định từ: mart_dine/core/style.dart
class Style {
  static const double paddingPhone = 16.0;
  static const TextStyle TextButton = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  static const TextStyle fontTitle = TextStyle(fontWeight: FontWeight.bold, fontSize: 18);
}