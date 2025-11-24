// file: widgets/_tab_info_restaurant.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/branch.dart'; 
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/providers_owner/role_provider.dart'; // THÊM: Import role_provider
import 'package:mart_dine/providers_owner/mock_user_provider.dart';
import 'package:mart_dine/providers_owner/system_stats_provider.dart'; // THÊM: Import owner_profile_provider
// <<< THÊM IMPORT MÀN HÌNH EDIT >>>
import 'package:mart_dine/features/owner/screen_edit_restaurant_info.dart'; 

class TabInfoRestaurant extends ConsumerWidget {
  final Branch branchData;

  const TabInfoRestaurant({super.key, required this.branchData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    // ... (Logic lấy managerName giữ nguyên) ...
    final allUsers = ref.watch(mockUserListProvider);
    String managerName = "Không rõ";
    try {
      final manager = allUsers.firstWhere((user) => user.id == branchData.managerId);
      managerName = manager.fullName;
    } catch (e) {
      // Không tìm thấy user
    }

    // THÊM: Xác định quyền chỉnh sửa
    final ownerProfileAsync = ref.watch(ownerProfileProvider);
    final roleListAsync = ref.watch(roleListProvider);

    bool isEditable = false;
    ownerProfileAsync.whenData((owner) {
      roleListAsync.whenData((roleList) {
        try {
          final ownerRole = roleList.firstWhere((role) => role.id == owner.role);
          if (ownerRole.code.toUpperCase() == 'OWNER') {
            isEditable = true;
          }
        } catch (e) { /* Bỏ qua lỗi, mặc định không chỉnh sửa được */ }
      });
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (_buildInfoRow giữ nguyên) ...
          _buildInfoRow("Tên chi nhánh", branchData.name),
          _buildInfoRow("Địa chỉ", branchData.address),
          _buildInfoRow("Trạng thái hoạt động", "Đang hoạt động", valueColor: Colors.green),
          _buildInfoRow("Mã chi nhánh", branchData.branchCode),
          _buildInfoRow("Quản lý", managerName), 
          const SizedBox(height: 20),
          const Text(
            "Giấy phép kinh doanh",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          // THÊM: Widget hiển thị ảnh giấy phép kinh doanh
          _buildBusinessLicenseImage(branchData.image),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // <<< SỬA HÀM ONPRESSED NÀY >>>
              onPressed: () {
                // Chuyển sang màn hình Edit
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScreenEditRestaurantInfo(
                      branchToEdit: branchData,
                      isEditable: isEditable, // TRUYỀN CỜ isEditable
                    ),
                  ),
                );
              },
              // <<< KẾT THÚC SỬA ONPRESSED >>>
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Chỉnh sửa",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

 // ... (_buildInfoRow giữ nguyên) ...
 Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1, 
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 10), 
          Flexible(
            flex: 2, 
            child: Text(
              value,
              textAlign: TextAlign.right, 
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // THÊM: Widget để hiển thị ảnh giấy phép kinh doanh
  Widget _buildBusinessLicenseImage(String? imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: (imageUrl != null && imageUrl.isNotEmpty)
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                      child: Icon(Icons.error_outline, color: Colors.red));
                },
              )
            : const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey)),
      ),
    );
  }
}