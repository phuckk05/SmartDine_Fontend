/// 🔧 Configuration cho Authentication & HTTP Service
/// 
/// File này chứa các cấu hình để chuyển đổi giữa:
/// - Mock authentication vs Real authentication
/// - Simple HTTP vs Advanced HTTP service
/// - Development vs Production settings

class AppConfig {
  // 🔐 AUTHENTICATION SETTINGS
  static const bool useRealAuthentication = false; // Chuyển thành true khi có login screen
  static const bool requireLogin = false;          // Bắt buộc đăng nhập
  static const bool autoMockLogin = true;          // Tự động mock login cho development
  
  // 🌐 HTTP SERVICE SETTINGS  
  static const bool useSimpleHttpService = false; // true = SimpleHttpService, false = HttpService
  static const bool enableHttpLogs = true;        // Bật logs cho debug
  static const Duration httpTimeout = Duration(seconds: 30);
  
  // 🏢 DEFAULT BRANCH SETTINGS
  static const int defaultBranchId = 1;
  static const List<int> mockUserBranches = [1, 2, 3];
  static const String mockUserRole = 'admin'; // 'admin', 'manager', 'staff'
  
  // 🚀 DEVELOPMENT HELPERS
  static const bool skipSplashScreen = true;      // Bỏ qua màn hình chào
  static const bool showDebugInfo = true;         // Hiển thị thông tin debug
  static const bool enableHotReload = true;       // Cho phép hot reload
  
  // 📱 MOBILE SPECIFIC
  static const bool optimizeForMobile = true;     // Tối ưu cho mobile
  static const bool enableOfflineMode = false;   // Chế độ offline (tương lai)
  
  // 🎯 FEATURE FLAGS
  static const bool enablePushNotifications = false;
  static const bool enableBiometricAuth = false;
  static const bool enableDarkMode = true;
  
  // 🔄 API ENDPOINTS
  static const String baseApiUrl = 'https://smartdine-backend-oq2x.onrender.com/api';
  static const String fallbackApiUrl = 'https://spring-boot-smartdine.onrender.com/api';
  
  // 💾 STORAGE KEYS
  static const String userSessionKey = 'user_session';
  static const String appSettingsKey = 'app_settings';
  static const String cacheKey = 'api_cache';
  
  // 🎨 UI SETTINGS
  static const double defaultPadding = 16.0;
  static const double cardRadius = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  /// Kiểm tra có phải development mode không
  static bool get isDevelopment => useRealAuthentication == false;
  
  /// Kiểm tra có nên tự động login không
  static bool get shouldAutoLogin => isDevelopment && autoMockLogin;
  
  /// Lấy HTTP service phù hợp
  static String get httpServiceType => useSimpleHttpService ? 'Simple' : 'Advanced';
  
  /// Thông tin môi trường
  static Map<String, dynamic> get environmentInfo => {
    'isDevelopment': isDevelopment,
    'useRealAuth': useRealAuthentication,
    'httpService': httpServiceType,
    'autoMockLogin': shouldAutoLogin,
    'mobileOptimized': optimizeForMobile,
  };
}