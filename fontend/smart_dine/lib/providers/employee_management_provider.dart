import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/employee_management_API.dart';
import '../API/user_approval_API.dart';
import '../models/user.dart';
import 'user_session_provider.dart';
import 'user_approval_provider.dart';

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

class EmployeeManagementNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final EmployeeManagementAPI _api;
  final int _branchId;
  final int _userId;

  EmployeeManagementNotifier(this._api, this._branchId, this._userId) : super(const AsyncValue.loading()) {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    try {
      state = const AsyncValue.loading();
      
      print('🔍 [EMPLOYEE_PROVIDER] Starting load - userId: $_userId, branchId: $_branchId');
      
      // Kiểm tra thông tin cơ bản trước
      if (_userId <= 0 || _branchId <= 0) {
        print('❌ [EMPLOYEE_PROVIDER] Invalid userId or branchId');
        throw Exception('Thông tin người dùng hoặc chi nhánh không hợp lệ');
      }
      
      // Skip permission check, go direct to API
      print('🔍 [EMPLOYEE_PROVIDER] Calling direct API...');
      final fallbackEmployees = await _api.getEmployeesByBranch(_branchId);
      print('🔍 [EMPLOYEE_PROVIDER] API returned: ${fallbackEmployees?.length ?? 0} employees');
      
      if (fallbackEmployees != null) {
        for (var emp in fallbackEmployees) {
          print('👤 Employee: ${emp.fullName} (ID: ${emp.id}, Status: ${emp.statusId})');
        }
      }
      
      final employees = fallbackEmployees ?? [];
      
      // Hiển thị tất cả employees (bao gồm cả pending để có thể approve)
      final allEmployees = employees.where((user) => 
        user.statusId != null && user.statusId != 0  // Chỉ loại bỏ deleted (0)
      ).toList();
      
      print('✅ [EMPLOYEE_PROVIDER] All employees loaded: ${allEmployees.length}');
      for (var emp in allEmployees) {
        print('   - Employee: ${emp.fullName} (ID: ${emp.id}, Status: ${emp.statusId})');
      }
      state = AsyncValue.data(allEmployees);
    } catch (error, stackTrace) {
      print('❌ [EMPLOYEE_PROVIDER] Error loading employees: $error');
      print('❌ [EMPLOYEE_PROVIDER] Stack trace: $stackTrace');
      state = AsyncValue.error(error, stackTrace);
    }
  }

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
        // Refresh the employee list
        await loadEmployees();
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
        // Refresh the employee list
        await loadEmployees();
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
        // Refresh the employee list
        await loadEmployees();
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