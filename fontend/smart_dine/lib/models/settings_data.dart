import 'user_profile_model.dart';
import 'settings_model.dart';
import 'user.dart';
import 'role.dart';

class SettingsMockData {
  /// Mock roles
  static final roles = {
    'KITCHEN_STAFF': Role(
      id: 1,
      code: 'KITCHEN_STAFF',
      name: 'Bếp',
      description: 'Nhân viên bếp',
    ),
    'WAITER': Role(
      id: 2,
      code: 'WAITER',
      name: 'Phục vụ',
      description: 'Nhân viên phục vụ',
    ),
  };

  /// Mock users
  static final users = [
    User(
      id: 1,
      fullName: 'Nguyễn Đình Phúc',
      email: 'phuckk3423@gmail.com',
      phone: '0901234567',
      passworkHash: '\$2a\$10\$abc',
      fontImage: '',
      backImage: '',
      statusId: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
      deletedAt: null,
    ),
    User(
      id: 2,
      fullName: 'Trần Thị B',
      email: 'tranthib@gmail.com',
      phone: '0907654321',
      passworkHash: '\$2a\$10\$def',
      fontImage: '',
      backImage: '',
      statusId: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
      deletedAt: null,
    ),
    User(
      id: 3,
      fullName: 'Lê Văn C',
      email: 'levanc@gmail.com',
      phone: '0909876543',
      passworkHash: '\$2a\$10\$ghi',
      fontImage: '',
      backImage: '',
      statusId: 1,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime.now(),
      deletedAt: null,
    ),
  ];

  /// Lấy user profile mặc định (user hiện tại)
  static UserProfile getCurrentUserProfile() {
    // Giả sử user đăng nhập là Nguyễn Đình Phúc - nhân viên bếp
    final user = users[0];
    final role = roles['KITCHEN_STAFF']!;

    return UserProfile.fromUserAndRole(
      user: user,
      role: role,
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  /// Lấy settings mặc định
  static SettingsModel getDefaultSettings() {
    return const SettingsModel(
      soundEnabled: true,
      darkModeEnabled: false,
      language: 'vi',
      autoRefresh: true,
      refreshInterval: 30,
    );
  }

  /// Lấy user profile theo role
  static UserProfile getUserProfileByRole(String roleCode) {
    final role = roles[roleCode];
    if (role == null) return getCurrentUserProfile();

    User? user;
    switch (roleCode) {
      case 'KITCHEN_STAFF':
        user = users[0];
        break;
      case 'WAITER':
        user = users[1];
        break;
      case 'MANAGER':
      case 'ADMIN':
        user = users[2];
        break;
      default:
        user = users[0];
    }

    return UserProfile.fromUserAndRole(
      user: user,
      role: role,
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  /// Mock danh sách tất cả user profiles
  static List<UserProfile> getAllUserProfiles() {
    return [
      UserProfile.fromUserAndRole(
        user: users[0],
        role: roles['KITCHEN_STAFF']!,
        lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      UserProfile.fromUserAndRole(
        user: users[1],
        role: roles['WAITER']!,
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      UserProfile.fromUserAndRole(
        user: users[2],
        role: roles['MANAGER']!,
        lastLogin: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
