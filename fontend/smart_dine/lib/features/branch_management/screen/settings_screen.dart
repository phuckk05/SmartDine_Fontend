import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';

class SettingsScreen extends StatelessWidget {
  final bool showBackButton;
  
  const SettingsScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: showBackButton 
        ? AppBarCus(
            title: 'Cài đặt',
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Cài đặt', style: Style.fontTitle),
            automaticallyImplyLeading: false,
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hồ sơ nhà hàng
            Text(
              'Hồ sơ nhà hàng',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin chi nhánh',
                    style: Style.fontNormal.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Restaurant NHOM7 - Chi nhánh chính',
                    style: Style.fontTitleMini.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(Icons.email, 'luonghaha@gmail.com', textColor),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.phone, '0345245345', textColor),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.location_on, 'USA 234234', textColor),
                  const SizedBox(height: 8),
                  _buildInfoItem(Icons.calendar_today, '28-04-2025', textColor, label: 'Ngày thành lập'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Hệ thống & hoạt động
            Text(
              'Hệ thống & hoạt động',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    'Tổng số nhân viên',
                    '43',
                    Icons.people,
                    textColor,
                    () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    'Đơn dịch vụ đang vận hành',
                    'free',
                    Icons.workspace_premium,
                    textColor,
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Giấy phép kinh doanh
            Text(
              'Giấy phép kinh doanh',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Giấy phép kinh doanh của nhánh G6M',
              style: Style.fontCaption.copyWith(color: Style.textColorGray),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLicenseCard(cardColor),
                const SizedBox(width: 12),
                _buildLicenseCard(cardColor),
              ],
            ),
            const SizedBox(height: 24),

            // Dịch vụ chúng tôi
            Text(
              'Dịch vụ chúng tôi',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trạng thái dịch vụ',
                    style: Style.fontNormal.copyWith(color: textColor),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'Đang hoạt động',
                      style: Style.fontCaption.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Button Đăng xuất
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Đăng xuất',
                  style: Style.fontButton.copyWith(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color textColor, {String? label}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Style.textColorGray),
        const SizedBox(width: 8),
        if (label != null) ...[
          Text(
            '$label: ',
            style: Style.fontCaption.copyWith(color: Style.textColorGray),
          ),
        ],
        Expanded(
          child: Text(
            text,
            style: Style.fontNormal.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String value,
    IconData icon,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: Style.fontNormal.copyWith(color: textColor),
      ),
      trailing: Text(
        value,
        style: Style.fontNormal.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLicenseCard(Color cardColor) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.description,
            size: 48,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã đăng xuất')),
              );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
