import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Thông tin tài khoản
            _buildSection(
              title: 'Tài khoản',
              isWeb: isWeb,
              children: [_buildProfileCard(isWeb)],
            ),

            const SizedBox(height: 20),

            // Cài đặt thông báo
            _buildSection(
              title: 'Thông báo',
              isWeb: isWeb,
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: 'Thông báo đẩy',
                  subtitle: 'Nhận thông báo về đơn hàng mới',
                  value: _notificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationEnabled = value;
                    });
                  },
                  isWeb: isWeb,
                ),
                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: 'Âm thanh',
                  subtitle: 'Phát âm thanh khi có đơn mới',
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _soundEnabled = value;
                    });
                  },
                  isWeb: isWeb,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Giao diện
            _buildSection(
              title: 'Giao diện',
              isWeb: isWeb,
              children: [
                _buildSwitchTile(
                  icon: Icons.dark_mode,
                  title: 'Chế độ tối',
                  subtitle: 'Giao diện tối cho mắt',
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                  isWeb: isWeb,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Hệ thống
            _buildSection(
              title: 'Hệ thống',
              isWeb: isWeb,
              children: [
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  subtitle: 'Thoát khỏi tài khoản',
                  onTap: () {
                    _showLogoutDialog();
                  },
                  isWeb: isWeb,
                  textColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required bool isWeb,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: isWeb ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isWeb) {
    return Padding(
      padding: EdgeInsets.all(isWeb ? 20 : 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nguyễn Đình Phúc',
                  style: TextStyle(
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '234234235253325',
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'phuckk3423@gmail.com',
                  style: TextStyle(
                    fontSize: isWeb ? 14 : 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Bếp',
              style: TextStyle(
                fontSize: isWeb ? 14 : 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isWeb,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 20 : 16,
        vertical: 4,
      ),
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isWeb ? 16 : 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: isWeb ? 14 : 13, color: Colors.grey[600]),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isWeb,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 20 : 16,
        vertical: 4,
      ),
      leading: Icon(icon, color: textColor ?? Colors.blue[700]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: isWeb ? 16 : 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: isWeb ? 14 : 13, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                    const SnackBar(
                      content: Text('Đã đăng xuất'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
