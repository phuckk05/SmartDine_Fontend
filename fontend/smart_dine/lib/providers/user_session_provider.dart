import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_session.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

// Provider cho UserSession
final userSessionProvider = StateNotifierProvider<UserSessionNotifier, UserSession>((ref) {
  return UserSessionNotifier();
});

// Provider để lấy branchId hiện tại
final currentBranchIdProvider = Provider<int?>((ref) {
  final session = ref.watch(userSessionProvider);
  return session.currentBranchId;
});

// Provider để kiểm tra authentication
final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(userSessionProvider);
  return session.isAuthenticated;
});

class UserSessionNotifier extends StateNotifier<UserSession> {
  static const String _sessionKey = 'user_session';
  final AuthService _authService = AuthService();
  
  UserSessionNotifier() : super(UserSession.guest()) {
    _loadSession();
  }

  // Tải session từ SharedPreferences
  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson != null) {
        final sessionMap = json.decode(sessionJson) as Map<String, dynamic>;
        state = UserSession.fromJson(sessionMap);
      }
    } catch (e) {
      print('Error loading user session: $e');
      // Giữ trạng thái guest nếu có lỗi
    }
  }

  // Lưu session vào SharedPreferences
  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = json.encode(state.toJson());
      await prefs.setString(_sessionKey, sessionJson);
    } catch (e) {
      print('Error saving user session: $e');
    }
  }

  // Đăng nhập user
  Future<void> login({
    required int userId,
    required String userName,
    required String userRole,
    required List<int> branchIds,
    int? defaultBranchId,
  }) async {
    // Chọn branch mặc định
    final currentBranchId = defaultBranchId ?? 
        (branchIds.isNotEmpty ? branchIds.first : null);
    
    state = UserSession(
      userId: userId,
      userName: userName,
      userRole: userRole,
      branchIds: branchIds,
      currentBranchId: currentBranchId,
      loginTime: DateTime.now(),
      isAuthenticated: true,
    );
    
    await _saveSession();
  }

  // Đăng xuất
  Future<void> logout() async {
    state = UserSession.guest();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // Chuyển đổi chi nhánh
  Future<void> switchBranch(int branchId) async {
    if (state.hasAccessToBranch(branchId)) {
      state = state.copyWith(currentBranchId: branchId);
      await _saveSession();
    } else {
      throw Exception('User không có quyền truy cập chi nhánh $branchId');
    }
  }

  // Cập nhật thông tin user
  Future<void> updateUserInfo({
    String? userName,
    String? userRole,
    List<int>? branchIds,
  }) async {
    state = state.copyWith(
      userName: userName,
      userRole: userRole,
      branchIds: branchIds,
    );
    await _saveSession();
  }

  // Real login thông qua AuthService (sẵn sàng khi có backend)
  Future<void> authenticateLogin(String username, String password) async {
    try {
      final session = await _authService.login(username, password);
      state = session;
      await _saveSession();
    } catch (e) {
      rethrow;
    }
  }

  // Mock login cho development/testing
  // TODO: Replace bằng authenticateLogin khi có login screen
  Future<void> mockLogin({int? branchId}) async {
    final session = await _authService.mockLogin(
      username: 'Admin Demo',
      role: AppConfig.mockUserRole,
      branchIds: AppConfig.mockUserBranches,
    );
    
    state = session.copyWith(
      currentBranchId: branchId ?? AppConfig.defaultBranchId
    );
    await _saveSession();
  }

  // Login với loại tài khoản cụ thể (cho testing)
  Future<void> mockLoginByAccountType(String accountType) async {
    try {
      final session = await _authService.mockLoginByAccount(accountType);
      state = session;
      await _saveSession();
    } catch (e) {
      throw Exception('Lỗi đăng nhập: ${e.toString()}');
    }
  }

  // Kiểm tra quyền truy cập branch
  bool canAccessBranch(int branchId) {
    return state.hasAccessToBranch(branchId);
  }

  // Lấy danh sách branch user có quyền
  List<int> get accessibleBranchIds => state.branchIds;

  // Lấy branch hiện tại
  int? get currentBranchId => state.currentBranchId;

  // Kiểm tra có phải admin không
  bool get isAdmin => state.isAdmin;

  // Kiểm tra có phải manager không
  bool get isManager => state.isManager;
}