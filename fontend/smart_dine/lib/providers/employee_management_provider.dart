import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../API/employee_management_API.dart';
import '../models/user.dart';

// Provider cho employee management theo branch
final employeeManagementProvider = StateNotifierProvider.family<EmployeeManagementNotifier, AsyncValue<List<User>>, int>((ref, branchId) {
  return EmployeeManagementNotifier(
    ref.read(employeeManagementApiProvider),
    branchId,
  );
});

class EmployeeManagementNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final EmployeeManagementAPI _api;
  final int _branchId;

  EmployeeManagementNotifier(this._api, this._branchId) : super(const AsyncValue.loading()) {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    try {
      state = const AsyncValue.loading();
      final employees = await _api.getEmployeesByBranch(_branchId);
      
      if (employees != null) {
        state = AsyncValue.data(employees);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<User?> getEmployeeById(int employeeId) async {
    try {
      return await _api.getEmployeeById(employeeId);
    } catch (error) {
      print('Error getting employee by id: $error');
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
      print('Error updating employee: $error');
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
      print('Error deleting employee: $error');
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
      print('Error adding employee: $error');
      return false;
    }
  }
}

// Provider cho một employee cụ thể
final employeeDetailProvider = FutureProvider.family<User?, int>((ref, employeeId) async {
  final api = ref.read(employeeManagementApiProvider);
  return api.getEmployeeById(employeeId);
});