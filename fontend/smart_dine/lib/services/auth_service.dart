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
      return UserSession.fromJson(data);
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
      print('Logout error: $e');
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

  // 📱 Demo/Mock login với các loại tài khoản khác nhau
  Future<UserSession> mockLogin({
    String username = 'admin',
    String role = 'admin', 
    List<int> branchIds = const [1, 2, 3],
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return UserSession(
      userId: _getUserIdFromUsername(username),
      userName: username,
      userRole: role,
      branchIds: branchIds,
      currentBranchId: branchIds.first,
      loginTime: DateTime.now(),
      isAuthenticated: true,
    );
  }

  // 🎭 Mock các loại tài khoản khác nhau cho testing
  Future<UserSession> mockLoginByAccount(String accountType) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    switch (accountType.toLowerCase()) {
      case 'admin':
        return UserSession(
          userId: 1,
          userName: 'Admin Tổng',
          userRole: 'admin',
          branchIds: [1, 2, 3, 4, 5], // Admin thấy tất cả chi nhánh
          currentBranchId: 1,
          loginTime: DateTime.now(),
          isAuthenticated: true,
        );
        
      case 'manager_branch_2':
        return UserSession(
          userId: 2,
          userName: 'Manager Chi Nhánh 2',
          userRole: 'manager',
          branchIds: [2], // Chỉ quản lý chi nhánh 2
          currentBranchId: 2,
          loginTime: DateTime.now(),
          isAuthenticated: true,
        );
        
      case 'staff_branch_3':
        return UserSession(
          userId: 3,
          userName: 'Nhân Viên Chi Nhánh 3',
          userRole: 'staff',
          branchIds: [3], // Chỉ làm việc ở chi nhánh 3
          currentBranchId: 3,
          loginTime: DateTime.now(),
          isAuthenticated: true,
        );
        
      case 'multi_branch_manager':
        return UserSession(
          userId: 4,
          userName: 'Manager Đa Chi Nhánh',
          userRole: 'manager',
          branchIds: [2, 3, 4], // Quản lý nhiều chi nhánh
          currentBranchId: 2,
          loginTime: DateTime.now(),
          isAuthenticated: true,
        );
        
      default:
        // Default guest/demo account
        return UserSession(
          userId: 999,
          userName: 'Demo User',
          userRole: 'staff',
          branchIds: [1],
          currentBranchId: 1,
          loginTime: DateTime.now(),
          isAuthenticated: true,
        );
    }
  }

  // Helper: Tạo userId từ username
  int _getUserIdFromUsername(String username) {
    // Simple hash để tạo consistent userId từ username
    return username.hashCode.abs() % 1000 + 1;
  }
}