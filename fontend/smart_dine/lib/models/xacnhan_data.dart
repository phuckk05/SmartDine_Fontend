import 'xacnhan_model.dart';

class UserRequestMockData {
  // Generate mock user requests
  static List<UserRequest> generateMockUserRequests() {
    return [
      UserRequest(
        id: '1',
        userName: 'Người Dùng 1',
        role: UserRole.branchManager,
        fullName: 'Nguyễn Văn A',
        address: 'Chi nhánh Quận 1, TP.HCM',
        phone: '0123456789',
        requestDate: DateTime(2025, 9, 29),
        email: 'nguyenvana@restaurant.com',
      ),
      UserRequest(
        id: '2',
        userName: 'Người Dùng 2',
        role: UserRole.cashier,
        fullName: 'Trần Thị B',
        address: 'Chi nhánh Quận 2, TP.HCM',
        phone: '0987654321',
        requestDate: DateTime(2025, 9, 28),
        email: 'tranthib@restaurant.com',
      ),
      UserRequest(
        id: '3',
        userName: 'Người Dùng 3',
        role: UserRole.branchManager,
        fullName: 'Lê Văn C',
        address: 'Chi nhánh Quận 3, TP.HCM',
        phone: '0912345678',
        requestDate: DateTime(2025, 9, 27),
        email: 'levanc@restaurant.com',
      ),
      UserRequest(
        id: '4',
        userName: 'Người Dùng 4',
        role: UserRole.employee,
        fullName: 'Phạm Thị D',
        address: 'Chi nhánh Quận 4, TP.HCM',
        phone: '0898765432',
        requestDate: DateTime(2025, 9, 26),
        email: 'phamthid@restaurant.com',
      ),
      UserRequest(
        id: '5',
        userName: 'Người Dùng 5',
        role: UserRole.employee,
        fullName: 'Hoàng Văn E',
        address: 'Chi nhánh Quận 5, TP.HCM',
        phone: '0901234567',
        requestDate: DateTime(2025, 9, 25),
        email: 'hoangvane@restaurant.com',
      ),
    ];
  }

  // Generate custom mock user requests
  static List<UserRequest> generateCustomMockRequests(int count) {
    return List.generate(count, (index) {
      final roles = UserRole.values;
      return UserRequest(
        userName: 'Người Dùng ${index + 1}',
        role: roles[index % roles.length],
        fullName: 'Nhân viên ${index + 1}',
        address: 'Chi nhánh Quận ${(index % 12) + 1}, TP.HCM',
        phone: '090${1000000 + index}',
        requestDate: DateTime.now().subtract(Duration(days: index)),
        email: 'user${index + 1}@restaurant.com',
      );
    });
  }

  // Generate user request with specific role
  static List<UserRequest> generateMockRequestsByRole(
    UserRole role,
    int count,
  ) {
    return List.generate(count, (index) {
      return UserRequest(
        userName: '${role.displayName} ${index + 1}',
        role: role,
        fullName: 'Nhân viên ${index + 1}',
        address: 'Chi nhánh Quận ${(index % 12) + 1}, TP.HCM',
        phone: '090${1000000 + index}',
        requestDate: DateTime.now().subtract(Duration(days: index)),
        email: 'user${index + 1}@restaurant.com',
      );
    });
  }

  // Generate pending requests only
  static List<UserRequest> generatePendingRequests(int count) {
    return generateCustomMockRequests(count);
  }

  // Generate confirmed requests
  static List<UserRequest> generateConfirmedRequests(int count) {
    return generateCustomMockRequests(
      count,
    ).map((req) => req.copyWith(status: RequestStatus.confirmed)).toList();
  }
}
