// file: features/owner/screen_edit_staff_info.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/role.dart';
import 'package:mart_dine/models_owner/staff_profile.dart';
import 'package:mart_dine/providers_owner/role_provider.dart';
import 'package:mart_dine/providers_owner/staff_profile_provider.dart';

// StateProvider để giữ Role đang được chọn trong Dropdown
final _selectedRoleProvider = StateProvider<Role?>((ref) => null);

class ScreenEditStaffInfo extends ConsumerStatefulWidget {
  final StaffProfile profile;
  const ScreenEditStaffInfo({super.key, required this.profile});

  @override
  ConsumerState<ScreenEditStaffInfo> createState() => _ScreenEditStaffInfoState();
}

class _ScreenEditStaffInfoState extends ConsumerState<ScreenEditStaffInfo> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị ban đầu cho Dropdown là vai trò hiện tại của nhân viên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_selectedRoleProvider.notifier).state = widget.profile.role;
    });
  }

  // Hàm xử lý khi nhấn nút "Lưu thay đổi"
  void _saveChanges() {
    final selectedRole = ref.read(_selectedRoleProvider);
    final originalUser = widget.profile.user;

    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn một chức vụ.")),
      );
      return;
    }

    // Gọi notifier để cập nhật thông tin
    ref.read(staffProfileUpdateNotifierProvider.notifier)
       .updateUserProfile(originalUser, selectedRole);

    // Quay về màn hình trước đó
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.profile.user;
    final allRolesAsync = ref.watch(roleListProvider);
    final selectedRole = ref.watch(_selectedRoleProvider);
    final stateAsync = ref.watch(staffProfileUpdateNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sửa thông tin nhân viên",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReadOnlyField("Tên nhân viên", user.fullName),
                _buildReadOnlyField("Email", user.email),
                _buildReadOnlyField("Số điện thoại", user.phone),
                
                // Dropdown chọn chức vụ
                const Text("Chức vụ", style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 5),
                allRolesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text("Lỗi tải chức vụ: $err"),
                  data: (allRoles) {
                    // Lọc danh sách chức vụ chỉ bao gồm 'MANAGER', 'STAFF', 'CHEF'
                    final allowedRoles = allRoles.where((role) {
                      final code = role.code.toUpperCase();
                      return code == 'MANAGER' || code == 'STAFF' || code == 'CHEF';
                    }).toList();

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: DropdownButton<Role>(
                        value: selectedRole,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Chọn chức vụ"),
                        items: allowedRoles.map((Role role) {
                          return DropdownMenuItem<Role>(
                            value: role,
                            child: Text(role.name),
                          );
                        }).toList(),
                        onChanged: (newRole) {
                          ref.read(_selectedRoleProvider.notifier).state = newRole;
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Nút Lưu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: stateAsync.isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: stateAsync.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Lưu thay đổi",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
          if (stateAsync.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // Widget helper cho các trường chỉ đọc
  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
