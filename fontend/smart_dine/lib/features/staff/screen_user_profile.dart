import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/provider_staff/user_provider.dart';
import 'package:mart_dine/providers/user_session_provider.dart';

class ScreenUserProfile extends ConsumerWidget {
  const ScreenUserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    final session = ref.watch(userSessionProvider);

    final fullName =
        _firstNonEmpty([user?.fullName, session.userName, session.name]) ??
        'Chưa cập nhật';
    final email =
        _firstNonEmpty([user?.email, session.email]) ?? 'Chưa cập nhật';
    final phone =
        _firstNonEmpty([user?.phone, session.phone]) ?? 'Chưa cập nhật';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Hồ sơ người dùng',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card thông tin
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin người dùng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoDisplay(label: 'Họ và tên', value: fullName),
                  const SizedBox(height: 16),
                  _buildInfoDisplay(label: 'Email', value: email),
                  const SizedBox(height: 16),
                  _buildInfoDisplay(label: 'Số điện thoại', value: phone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper hiển thị thông tin ở dạng chỉ đọc
  Widget _buildInfoDisplay({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
