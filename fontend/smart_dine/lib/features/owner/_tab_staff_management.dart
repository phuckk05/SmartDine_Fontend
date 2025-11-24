// file: widgets/_tab_staff_management.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/staff_profile.dart';
import 'package:mart_dine/providers_owner/staff_profile_provider.dart';
import 'package:mart_dine/providers_owner/role_provider.dart';
import 'package:mart_dine/features/owner/screen_staff_detail.dart';
import 'package:mart_dine/providers/user_session_provider.dart'; // <<< THÊM IMPORT NÀY

class TabStaffManagement extends ConsumerWidget {
  final int branchId;
  const TabStaffManagement({super.key, required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffListAsync = ref.watch(staffProfileProvider);
    final staffBranchRelationsAsync = ref.watch(userBranchRelationProvider);
    
    // Theo dõi notifier để rebuild khi có thay đổi (thêm/xóa/sửa)
    ref.watch(staffProfileUpdateNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Dùng .when() lồng nhau để xử lý
          staffListAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi tải nhân viên: $err', style: TextStyle(color: Colors.red))),
            data: (allStaffProfiles) {
              // Khi list user đã tải xong, kiểm tra list quan hệ
              return staffBranchRelationsAsync.when(
                 loading: () => const Center(child: CircularProgressIndicator()),
                 error: (err, stack) => Center(child: Text('Lỗi tải quan hệ NV-CN: $err', style: TextStyle(color: Colors.red))),
                 data: (relationsMap) {
                    // SỬA: Lọc danh sách nhân viên có branchId khớp với chi nhánh hiện tại
                    final branchStaffList = allStaffProfiles.where((profile) {
                      final assignedBranchId = relationsMap[profile.user.id];
                      return assignedBranchId == branchId;
                    }).toList();

                    // Hiển thị ListView hoặc thông báo
                    return branchStaffList.isEmpty
                        ? const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text("Chi nhánh này chưa có nhân viên."),
                          ))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: branchStaffList.length,
                            itemBuilder: (context, index) {
                              final profile = branchStaffList[index];
                              return _buildStaffAccountCard(context, ref, profile);
                            },
                          );
                 }
              );
            }
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStaffAccountCard(BuildContext context, WidgetRef ref, StaffProfile profile) {
    final user = profile.user;
    final roleName = profile.role.name;
    String statusName = getStatusName(user.statusId);
    bool isLocked = user.statusId == 2;
    Color statusColor = isLocked ? Colors.grey.shade600 : Colors.green;
    Color statusBgColor = isLocked ? Colors.grey.shade300 : Colors.green.shade100;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ScreenStaffDetail(profile: profile),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)) ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text(roleName, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(statusName, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                  onSelected: (String result) {
                    if (result == 'toggle_lock') {
                      ref
                          .read(staffProfileUpdateNotifierProvider.notifier)
                          .toggleUserStatus(user);
                    } else if (result == 'unassign') {
                      // SỬA: Gọi hàm xóa khỏi chi nhánh chỉ với userId
                      ref
                          .read(staffProfileUpdateNotifierProvider.notifier)
                          .unassignStaffFromBranch(user.id!);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(value: 'toggle_lock', child: Text(isLocked ? 'Mở khóa' : 'Khóa tài khoản')),
                    const PopupMenuItem<String>(value: 'unassign', child: Text('Xóa khỏi chi nhánh')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}