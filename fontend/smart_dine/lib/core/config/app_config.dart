/// Configuration cho SmartDine App
/// Quản lý API endpoints, network settings và các cấu hình khác
class AppConfig {
  // API Configuration
  static const String baseApiUrl = 'https://smartdine-backend-oq2x.onrender.com/api';
  
  // Alternative local development URL (uncomment if testing locally)
  // static const String baseApiUrl = 'http://10.0.2.2:8080/api'; // Android Emulator
  // static const String baseApiUrl = 'http://localhost:8080/api'; // Web/iOS Simulator
  
  // Network Configuration
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const bool enableNetworkLogs = true;
  
  // App Configuration
  static const String appName = 'SmartDine';
  static const String version = '1.0.0';
  
  // Mobile-specific configurations
  static const bool allowHttpInDebug = true; // Cho phép HTTP trong debug mode
  static const bool useNetworkSecurityConfig = true; // Sử dụng network security config cho Android
  
  // Branch Management Configuration  
  static const int defaultBranchId = 1;
  static const List<int> availableBranchIds = [1, 2, 3];
  
  // Mock User Configuration (for development without login)
  static const Map<String, dynamic> mockUser = {
    'userId': 1,
    'userName': 'Branch Manager Demo',
    'userRole': 'manager',
    'branchIds': [1, 2, 3],
    'defaultBranchId': 1,
  };
  
  // Network troubleshooting helpers
  static String get diagnosticInfo => '''
📱 SmartDine Network Configuration
API Base URL: $baseApiUrl
Timeout: ${networkTimeout.inSeconds}s
Max Retries: $maxRetries
Logs Enabled: $enableNetworkLogs

📋 Troubleshooting:
1. Kiểm tra internet connection
2. Xác nhận server đang hoạt động
3. Kiểm tra firewall/security settings
4. Thử chuyển từ HTTPS sang HTTP (chỉ development)
''';
}

/// Network utility functions
class NetworkUtils {
  /// Check if URL is HTTPS
  static bool isHttps(String url) {
    return url.startsWith('https://');
  }
  
  /// Convert HTTPS to HTTP (chỉ dùng cho development)
  static String toHttp(String httpsUrl) {
    if (isHttps(httpsUrl)) {
      return httpsUrl.replaceFirst('https://', 'http://');
    }
    return httpsUrl;
  }
  
  /// Get appropriate URL based on platform and environment
  static String getPlatformApiUrl() {
    // Có thể tùy chỉnh theo platform nếu cần
    return AppConfig.baseApiUrl;
  }
}