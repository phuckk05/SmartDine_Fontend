import '../core/services/http_service.dart';
import '../models/user_session.dart';

class AuthService {
  final HttpService _httpService = HttpService();
  static const String baseUrl = 'https://smartdine-backend-oq2x.onrender.com/api';

  // 🔐 Login API - Sẵn sàng tích hợp khi có backend endpoint
  Future<UserSession> login(String username, String password) async {
    try {
      final response = await _httpService.post(
        '$baseUrl/auth/login',
        body: {
          'username': username,
          'password': password,
        },
      );

      final data = _httpService.handleResponse(response);
      
      // Parse response to UserSession
      return UserSession.fromMap(data);
    } catch (e) {
      throw Exception('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  // 🔓 Logout API
  Future<void> logout(String token) async {
    try {
      await _httpService.post(
        '$baseUrl/auth/logout',
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
            // Không throw error vì logout luôn thành công ở client
    }
  }

  // 🔄 Refresh token
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _httpService.post(
        '$baseUrl/auth/refresh',
        body: {'refreshToken': refreshToken},
      );

      final data = _httpService.handleResponse(response);
      return data['accessToken'];
    } catch (e) {
      throw Exception('Làm mới phiên đăng nhập thất bại');
    }
  }

  // 👤 Get user profile
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await _httpService.get(
        '$baseUrl/auth/profile',
        headers: {'Authorization': 'Bearer $token'},
      );

      return _httpService.handleResponse(response);
    } catch (e) {
      throw Exception('Lỗi lấy thông tin người dùng: ${e.toString()}');
    }
  }

  // 🏢 Get user branches
  Future<List<int>> getUserBranches(String token) async {
    try {
      final response = await _httpService.get(
        '$baseUrl/auth/branches',
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = _httpService.handleResponse(response);
      return List<int>.from(data['branchIds'] ?? []);
    } catch (e) {
      throw Exception('Lỗi lấy danh sách chi nhánh: ${e.toString()}');
    }
  }

  // 🔒 Validate token
  Future<bool> validateToken(String token) async {
    try {
      final response = await _httpService.get(
        '$baseUrl/auth/validate',
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = _httpService.handleResponse(response);
      return data['valid'] ?? false;
    } catch (e) {
      return false;
    }
  }

  // 📱 Demo/Mock login cho development
  Future<UserSession> mockLogin({
    String username = 'admin',
    int role = 1, // 1 = admin, 2 = manager, 3 = staff
    List<int> branchIds = const [1, 2, 3],
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return UserSession(
      userId: 1,
      userName: username,
      userRole: role,
      branchIds: branchIds,
      currentBranchId: branchIds.first,
      loginTime: DateTime.now(),
      isAuthenticated: true,
    );
  }
}