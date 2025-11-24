// file: screens/screen_profile.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart' show ShadowCus, kTextColorLight, kTextColorDark;
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets_owner/appbar.dart';
import 'screen_setting.dart'; 
// SỬA: Import các provider, helper và màn hình cần thiết
import 'package:mart_dine/features/signin/screen_signin.dart';
import 'package:mart_dine/providers_owner/company_provider.dart';
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/providers_owner/role_provider.dart' show formatDate; // Dùng lại hàm formatDate
import 'package:mart_dine/providers/user_session_provider.dart';
// THÊM: Import các provider cần thiết để đếm
import 'package:mart_dine/providers_owner/target_provider.dart' show branchListProvider;
import 'package:mart_dine/providers_owner/staff_profile_provider.dart';

// SỬA: Chuyển thành ConsumerWidget
class ScreenProfile extends ConsumerWidget {
  const ScreenProfile({super.key});

  @override
  // SỬA: Thêm WidgetRef ref
  Widget build(BuildContext context, WidgetRef ref) {
    
    // SỬA: Watch các provider
    final ownerAsync = ref.watch(ownerProfileProvider);
    final companyAsync = ref.watch(companyProvider);
    final statsAsync = ref.watch(systemStatsProvider); // SỬA: Đổi tên để thể hiện đây là AsyncValue
    // THÊM: Watch các provider để đếm
    final allBranchesAsync = ref.watch(branchListProvider);
    final allStaffAsync = ref.watch(staffProfileProvider);
    final loggedInCompanyId = ref.watch(userSessionProvider).companyId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Style tiêu đề giống các tab khác (ví dụ: ScreenManagement)
        title: const Text(
          'Hồ sơ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        // Thêm dòng này để TẮT icon quay lại
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScreenSettings()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Style.paddingPhone),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần 1: Thông tin nhà hàng
            const Text('Thông tin nhà hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextColorDark)),
            const SizedBox(height: 10),
            // SỬA: Truyền dữ liệu động
            // SỬA: Tái cấu trúc để tách biệt logic của Owner và Company
            ShadowCus(
              borderRadius: 12,
              padding: const EdgeInsets.all(15),
              baseColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần 1: Thông tin Company (tên, mã, ngày) - Phụ thuộc companyProvider
                  companyAsync.when(
                    loading: () => _buildCompanyInfoSection("Đang tải...", "Đang tải...", null),
                    error: (err, stack) => Text("Lỗi tải công ty: $err", style: TextStyle(color: Colors.red)),
                    data: (company) => _buildCompanyInfoSection(
                      company?.companyName ?? "Không có tên",
                      company?.companyCode ?? "Không có",
                      company?.createdAt,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Phần 2: Thông tin Owner (email, phone) - Phụ thuộc ownerProfileProvider
                  ownerAsync.when(
                    loading: () => _buildOwnerInfoSection("Đang tải...", "Đang tải..."),
                    error: (err, stack) => Text("Lỗi tải chủ sở hữu: $err", style: TextStyle(color: Colors.red)),
                    data: (owner) => _buildOwnerInfoSection(
                      owner.email,
                      owner.phone,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            // Phần 2: Hệ thống & hoạt động
            const Text('Hệ thống & hoạt động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextColorDark)),
            const SizedBox(height: 10),
            // SỬA: Truyền dữ liệu động
            // SỬA: Dùng companyAsync để lấy thông tin hệ thống của riêng công ty
            // KẾT HỢP 3 PROVIDER ĐỂ TÍNH TOÁN
            allBranchesAsync.when(
              loading: () => _buildSystemInfo("...", "...", "..."),
              error: (err, stack) => _buildRestaurantInfoError(err.toString()),
              data: (branches) {
                final branchCount = branches.length.toString();
                return allStaffAsync.when(
                  loading: () => _buildSystemInfo(branchCount, "...", "..."),
                  error: (err, stack) => _buildRestaurantInfoError(err.toString()),
                  data: (staff) {
                    // Lọc và đếm nhân viên thuộc công ty này
                    final staffCount = staff.where((p) => p.user.companyId == loggedInCompanyId).length.toString();
                    // SỬA: Xử lý statsAsync để lấy Gói dịch vụ
                    return statsAsync.when(
                      loading: () => _buildSystemInfo(branchCount, staffCount, "..."),
                      error: (err, stack) => _buildSystemInfo(branchCount, staffCount, "Lỗi"),
                      data: (stats) => _buildSystemInfo(branchCount, staffCount, stats['service_package'] ?? 'N/A'),
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 25),
            // Phần 3: Giấy phép kinh doanh (Giữ nguyên)
            const Text('Giấy phép kinh doanh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextColorDark)),
            const SizedBox(height: 10),            
            // SỬA: Sửa lại tên thuộc tính để lấy URL ảnh giấy phép kinh doanh
            _buildBusinessLicense(companyAsync.value?.companyImageUrl),
            const SizedBox(height: 25),
            // Phần 4: Dịch vụ chúng tôi
            const Text('Dịch vụ chúng tôi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kTextColorDark)),
            const SizedBox(height: 10),
            // SỬA: Lấy trạng thái từ companyAsync
            _buildServiceStatus(companyAsync.value?.statusId),
            const SizedBox(height: 30),
            // SỬA: Truyền ref vào nút Đăng xuất
            _buildLogoutButton(context, ref),
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  // Widget hiển thị khi đang tải
  Widget _buildRestaurantInfoLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // Widget hiển thị khi có lỗi
  Widget _buildRestaurantInfoError(String error) {
    return ShadowCus(
      borderRadius: 12,
      padding: const EdgeInsets.all(15),
      baseColor: Colors.red.shade50,
      child: Center(
        child: Text('Lỗi tải thông tin: $error', style: TextStyle(color: Colors.red.shade700)),
      ),
    );
  }

  // SỬA: Widget mới chỉ để hiển thị thông tin Company
  Widget _buildCompanyInfoSection(String name, String code, DateTime? joinDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: Style.fontTitle.copyWith(fontSize: 18, color: Colors.black)),
        const SizedBox(height: 10),
        _buildInfoRow(Icons.vpn_key_outlined, code, label: 'Mã nhà hàng'),
        _buildInfoRow(
          Icons.date_range_outlined,
          (joinDate != null ? formatDate(joinDate) : "Không có"),
          label: 'Ngày thành lập',
        ),
      ],
    );
  }

  // SỬA: Widget mới chỉ để hiển thị thông tin Owner
  Widget _buildOwnerInfoSection(String email, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.email_outlined, email, isLabelValue: false),
        _buildInfoRow(Icons.phone_android_outlined, phone, isLabelValue: false),
      ],
    );
  }

  // (Hàm _buildInfoRow giữ nguyên)
  Widget _buildInfoRow(IconData icon, String value, {String? label, bool isLabelValue = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kTextColorDark),
          const SizedBox(width: 8),
          if (isLabelValue && label != null) 
            Text('$label: ', style: const TextStyle(fontSize: 14, color: kTextColorDark, fontWeight: FontWeight.normal)),
          
          Text(
            isLabelValue ? value : (label != null ? '$label: $value' : value), 
            style: const TextStyle(fontSize: 14, color: kTextColorLight),
          ),
        ],
      ),
    );
  }

  // SỬA: Nhận dữ liệu động
  Widget _buildSystemInfo(String branchCount, String staffCount, String package) {
    return ShadowCus(
      borderRadius: 12,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _buildSystemRow('Tổng số chi nhánh hiện tại', branchCount),
          _buildSystemRow('Tổng số nhân viên', staffCount),
          _buildSystemRow('Gói dịch vụ đang sử dụng', package),
        ],
      ),
    );
  }

  // (Hàm _buildSystemRow giữ nguyên)
  Widget _buildSystemRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: kTextColorDark)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextColorDark)),
        ],
      ),
    );
  }

  // (Hàm _buildBusinessLicense giữ nguyên)
  Widget _buildBusinessLicense(String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Giữ lại tiêu đề, hoặc có thể ẩn đi nếu không cần thiết
        // const Text('Giấy phép kinh doanh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTextColorDark)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chỉ hiển thị một ảnh từ URL
            Expanded(
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  // SỬA: Dùng Image.network để tải ảnh từ URL
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          // Hiển thị loading trong khi tải ảnh
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          // Hiển thị icon lỗi nếu không tải được
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.error_outline, color: kTextColorLight, size: 40));
                          },
                        )
                      // Hiển thị placeholder nếu không có URL
                      : const Center(child: Icon(Icons.image_not_supported_outlined, color: kTextColorLight, size: 40)),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Có thể giữ lại khung ảnh thứ 2 nếu bạn có 2 ảnh, hoặc xóa đi
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  // SỬA: Nhận dữ liệu động
  Widget _buildServiceStatus(int? statusId) {
    String statusText;
    Color color;

    switch (statusId) {
      case 1:
        statusText = 'Đang hoạt động';
        color = Colors.green;
        break;
      case 2:
        statusText = 'Bị khóa';
        color = Colors.red;
        break;
      default:
        statusText = 'Đang tải...';
        color = Colors.grey;
    }
    
    return ShadowCus(
      borderRadius: 12,
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Trạng thái dịch vụ', style: TextStyle(fontSize: 14, color: kTextColorDark)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // SỬA: Thêm WidgetRef và triển khai logic đăng xuất
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue, 
        borderRadius: BorderRadius.circular(10),
      ),
      child: MaterialButton(
        onPressed: () async {
          // 2. Xóa phiên làm việc của người dùng (nếu có)
          await ref.read(userSessionProvider.notifier).logout();

          // 3. Điều hướng về màn hình đăng nhập và xóa tất cả các màn hình trước đó
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ScreenSignIn()),
            (Route<dynamic> route) => false,
          );
        },
        child: Text(
          'Đăng xuất',
          style: Style.TextButton.copyWith(color: Colors.white), 
        ),
      ),
    );
  }
}