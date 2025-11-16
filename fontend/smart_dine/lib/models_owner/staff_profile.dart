// file: models/staff_profile.dart
import 'package:mart_dine/models_owner/user.dart';
import 'package:mart_dine/models_owner/role.dart';

// Đây là một "View Model", kết hợp User và Role cho UI
class StaffProfile {
  final User user;
  final Role role;

  StaffProfile({
    required this.user,
    required this.role,
  });

  StaffProfile copyWith({
    User? user,
    Role? role,
  }) {
    return StaffProfile(
      user: user ?? this.user,
      role: role ?? this.role,
    );
  }
}