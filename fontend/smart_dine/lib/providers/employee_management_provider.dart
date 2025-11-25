import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/employee_management_API.dart';
import '../API/user_approval_API.dart';
import '../models/user.dart';
import '../core/realtime_notifier.dart';
import 'user_session_provider.dart';
import 'user_approval_provider.dart';

// Provider cho danh sách user statuses
final userStatusesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(employeeManagementApiProvider);
  final statuses = await api.getUserStatuses();
  return statuses ?? [
    {'id': 1, 'code': 'ACTIVE', 'name': 'Hoạt động'},
    {'id': 2, 'code': 'INACTIVE', 'name': 'Không hoạt động'},
    {'id': 3, 'code': 'SUSPENDED', 'name': 'Tạm ngừng'},
  ];
});

// Provider cho danh sách roles
final rolesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.read(employeeManagementApiProvider);
  final roles = await api.getRoles();
  return roles ?? [];
});

// Provider cho employee management theo branch
final employeeManagementProvider = StateNotifierProvider.family<EmployeeManagementNotifier, AsyncValue<List<User>>, int>((ref, branchId) {
  final userSession = ref.watch(userSessionProvider);
  return EmployeeManagementNotifier(
    ref.read(employeeManagementApiProvider),
    branchId,
    userSession.userId ?? 0,
  );
});

// Provider cho pending employees - sử dụng user-approval API trực tiếp
final pendingEmployeesProvider = FutureProvider.family<List<User>, int>((ref, branchId) async {
  final api = ref.read(userApprovalApiProvider);
  return await api.getPendingUsersByBranch(branchId);
});

// Realtime provider cho pending employees với auto-refresh
class PendingEmployeesNotifier extends RealtimeNotifier<List<User>> {
  final UserApprovalAPI _api;
  final int _branchId;

  PendingEmployeesNotifier(this._api, this._branchId) : super();

  @override
  Future<List<User>> loadData() async {
    return await _api.getPendingUsersByBranch(_branchId);
  }

  @override
  Duration get pollingInterval => const Duration(seconds: 15); // Check every 15 seconds for new pending users

  @override
  bool get enableRealtime => true;
}

final pendingEmployeesRealtimeProvider = StateNotifierProvider.family<PendingEmployeesNotifier, AsyncValue<List<User>>, int>((ref, branchId) {
  final api = ref.read(userApprovalApiProvider);
  return PendingEmployeesNotifier(api, branchId);
});

// Provider cho active employees (statusId = 1)
final activeEmployeesProvider = Provider.family<AsyncValue<List<User>>, int>((ref, branchId) {
  final employeesAsync = ref.watch(employeeManagementProvider(branchId));
  
  return employeesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
    data: (employees) {
      final activeEmployees = employees.where((user) => user.statusId == 1).toList();
      return AsyncValue.data(activeEmployees);
    },
  );
});

class EmployeeManagementNotifier extends RealtimeNotifier<List<User>> {
  final EmployeeManagementAPI _api;
  final int _branchId;
  final int _userId;

  EmployeeManagementNotifier(this._api, this._branchId, this._userId);

  @override
  Future<List<User>> loadData() async {
    print('[EMPLOYEE_PROVIDER] Starting load - userId: $_userId, branchId: $_branchId');

    // Kiểm tra thông tin cơ bản trước
    if (_userId <= 0 || _branchId <= 0) {
      print('[EMPLOYEE_PROVIDER] Invalid userId or branchId');
      throw Exception('Thông tin người dùng hoặc chi nhánh không hợp lệ');
    }

    // Skip permission check, go direct to API
    print('[EMPLOYEE_PROVIDER] Calling direct API...');
    final fallbackEmployees = await _api.getEmployeesByBranch(_branchId);
    print('[EMPLOYEE_PROVIDER] API returned: ${fallbackEmployees?.length ?? 0} employees');

    if (fallbackEmployees != null) {
      for (var emp in fallbackEmployees) {
        print('Employee: ${emp.fullName} (ID: ${emp.id}, Status: ${emp.statusId})');
      }
    }

    final employees = fallbackEmployees ?? [];

    // Hiển thị employees ở màn hình chính (loại bỏ pending và blocked)
    final activeEmployees = employees.where((user) =>
      user.statusId != null &&
      user.statusId != 0 &&  // Loại bỏ deleted
      user.statusId != 3     // Loại bỏ blocked (chỉ hiển thị ở popup duyệt)
    ).toList();

    print('[EMPLOYEE_PROVIDER] Active employees loaded: ${activeEmployees.length}');
    for (var emp in activeEmployees) {
      print('Employee: ${emp.fullName} (ID: ${emp.id}, Status: ${emp.statusId})');
    }

    return activeEmployees;
  }

  @override
  Duration get pollingInterval => const Duration(seconds: 20); // Update every 20 seconds for employee management

  Future<User?> getEmployeeById(int employeeId) async {
    try {
      return await _api.getEmployeeById(employeeId);
    } catch (error) {
      return null;
    }
  }

  Future<bool> updateEmployee(int employeeId, User employee) async {
    try {
      final updatedEmployee = await _api.updateEmployee(employeeId, employee);
      if (updatedEmployee != null) {
        // Refresh the employee list immediately
        await refresh();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<bool> deleteEmployee(int employeeId) async {
    try {
      final success = await _api.deleteEmployee(employeeId);
      if (success) {
        // Refresh the employee list immediately
        await refresh();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  Future<bool> addEmployee(User employee) async {
    try {
      final success = await _api.addEmployeeToBranch(_branchId, employee);
      if (success) {
        // Refresh the employee list immediately
        await refresh();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}

// Provider cho một employee cụ thể
final employeeDetailProvider = FutureProvider.family<User?, int>((ref, employeeId) async {
  final api = ref.read(employeeManagementApiProvider);
  return api.getEmployeeById(employeeId);
});