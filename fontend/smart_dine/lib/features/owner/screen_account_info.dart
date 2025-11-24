// file: lib/features/owner/screen_account_info.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart' show kTextColorDark, kTextColorLight;
import 'package:mart_dine/providers_owner/role_provider.dart' show formatDate;
import 'package:mart_dine/providers_owner/system_stats_provider.dart';

/// Màn hình hiển thị thông tin chi tiết của tài khoản đang đăng nhập.
class ScreenAccountInfo extends ConsumerWidget {
  const ScreenAccountInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy dữ liệu của chủ sở hữu từ provider
    final ownerAsync = ref.watch(ownerProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thông tin tài khoản',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Xử lý các trạng thái của provider (loading, error, data)
      body: ownerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải thông tin: $err')),
        data: (owner) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tên đầy đủ
                Text(
                  owner.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kTextColorDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Vai trò
                Text(
                  'Chủ sở hữu', // Vai trò được xác định trong luồng của Owner
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),

                // Card chứa thông tin chi tiết
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.email_outlined, 'Email', owner.email),
                      const Divider(),
                      _buildInfoRow(Icons.phone_outlined, 'Số điện thoại', owner.phone),
                      const Divider(),
                      _buildInfoRow(Icons.cake_outlined, 'Ngày tham gia', formatDate(owner.createdAt)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Phần thông tin CCCD
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Thông tin định danh',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTextColorDark),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Giả định model User có trường `fontImage`
                    _buildIdCardImage('Mặt trước CCCD', owner.fontImage),
                    const SizedBox(width: 16),
                    // Giả định model User có trường `backImage`
                    _buildIdCardImage('Mặt sau CCCD', owner.backImage),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  /// Widget con để hiển thị một hàng thông tin (icon, label, value).
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: kTextColorLight, size: 22),
          const SizedBox(width: 15),
          // SỬA: Bỏ Spacer và dùng Expanded để giá trị có thể tự xuống dòng
          Text(
            '$label:',
            style: const TextStyle(fontSize: 15, color: kTextColorLight),
          ),
          const SizedBox(width: 10), // Thêm khoảng cách nhỏ
          Expanded(
            child: Text(value,
                textAlign: TextAlign.end, // Căn phải giá trị
                style: const TextStyle(fontSize: 15, color: kTextColorDark, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  /// Widget con để hiển thị ảnh CCCD.
  Widget _buildIdCardImage(String title, String? imageUrl) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: kTextColorLight)),
          const SizedBox(height: 8),
          AspectRatio(
            aspectRatio: 1.58, // Tỷ lệ của thẻ CCCD ~ 85.6mm / 53.98mm
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: (imageUrl?.isNotEmpty == true)
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      errorBuilder: (context, error, stack) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 30),
                            SizedBox(height: 4),
                            Text("Lỗi ảnh", style: TextStyle(fontSize: 12, color: Colors.red)),
                          ],
                        );
                      },
                    )
                  : const Center(child: Icon(Icons.image_not_supported_outlined, color: kTextColorLight, size: 40)),
            ),
          ),
        ],
      ),
    );
  }
}