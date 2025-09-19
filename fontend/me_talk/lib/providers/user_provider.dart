import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:me_talk/models/user.dart';
import 'package:me_talk/repository/user_repository.dart';

class UserNotifier extends StateNotifier<List<User>> {
  final UserRepository repository;

  UserNotifier(this.repository) : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await repository.fetchUsers();
      state = user;
    } catch (e) {
      // Có thể log hoặc giữ state mặc định
      print('❌ Lỗi khi fetch user: $e');
    }
  }

  Future<void> updateUserById(int id, String name, String email) async {
    try {
      final updated = await repository.updateUser(id, name, email);
      state =
          state
              .map((u) => u.id == id ? updated : u)
              .toList(); // cập nhật trong danh sách
    } catch (e) {
      print('❌ Lỗi khi cập nhật user: $e');
    }
  }

  // void updateName(String n) => state = state.copyWith(name: n);
  // void updateEmail(String e) => state = state.copyWith(email: e);
}

final userRepositoryProvider = Provider((ref) => UserRepository());

final userProvider = StateNotifierProvider<UserNotifier, List<User>>((ref) {
  final repo = ref.read(userRepositoryProvider);
  return UserNotifier(repo);
});
