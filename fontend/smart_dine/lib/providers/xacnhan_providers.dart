import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/xacnhan_model.dart';
import 'package:mart_dine/models/xacnhan_data.dart';

// StateNotifier để quản lý danh sách user requests
class UserRequestListNotifier extends StateNotifier<List<UserRequest>> {
  UserRequestListNotifier()
    : super(UserRequestMockData.generateMockUserRequests());

  // Confirm user request
  void confirmUser(String id) {
    state = [
      for (final request in state)
        if (request.id == id)
          request.copyWith(status: RequestStatus.confirmed)
        else
          request,
    ];
  }

  // Reject user request (remove from list)
  void rejectUser(String id) {
    state = state.where((request) => request.id != id).toList();
  }

  // Add new user request
  void addUserRequest(UserRequest request) {
    if (!request.isValid) {
      throw Exception('Thông tin yêu cầu không hợp lệ');
    }
    state = [...state, request];
  }

  // Update user request
  void updateUserRequest(UserRequest updatedRequest) {
    if (!updatedRequest.isValid) {
      throw Exception('Thông tin yêu cầu không hợp lệ');
    }
    state = [
      for (final request in state)
        if (request.id == updatedRequest.id) updatedRequest else request,
    ];
  }

  // Delete user request
  void deleteUserRequest(String id) {
    state = state.where((request) => request.id != id).toList();
  }

  // Confirm all pending requests
  void confirmAllPending() {
    state = [
      for (final request in state)
        if (request.isPending)
          request.copyWith(status: RequestStatus.confirmed)
        else
          request,
    ];
  }

  // Reject all pending requests
  void rejectAllPending() {
    state = state.where((request) => !request.isPending).toList();
  }

  // Get request by ID
  UserRequest? getRequestById(String id) {
    try {
      return state.firstWhere((request) => request.id == id);
    } catch (e) {
      return null;
    }
  }

  // Reset to mock data
  void resetToMockData() {
    state = UserRequestMockData.generateMockUserRequests();
  }

  // Load custom mock data
  void loadCustomMockData(int count) {
    state = UserRequestMockData.generateCustomMockRequests(count);
  }

  // Get total count
  int get totalRequests => state.length;

  // Check if empty
  bool get isEmpty => state.isEmpty;
}

// Provider cho danh sách user requests
final userRequestListProvider =
    StateNotifierProvider<UserRequestListNotifier, List<UserRequest>>((ref) {
      return UserRequestListNotifier();
    });

// Provider cho search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider cho role filter
final roleFilterProvider = StateProvider<UserRole?>((ref) => null);

// Provider cho status filter
final statusFilterProvider = StateProvider<RequestStatus?>((ref) => null);

// Provider cho danh sách đã được filter và search
final filteredUserRequestsProvider = Provider<List<UserRequest>>((ref) {
  final requests = ref.watch(userRequestListProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final roleFilter = ref.watch(roleFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  return requests.where((request) {
    // Search filter
    final matchesSearch =
        searchQuery.isEmpty ||
        request.userName.toLowerCase().contains(searchQuery) ||
        request.fullName.toLowerCase().contains(searchQuery) ||
        request.role.displayName.toLowerCase().contains(searchQuery) ||
        request.phone.contains(searchQuery);

    // Role filter
    final matchesRole = roleFilter == null || request.role == roleFilter;

    // Status filter
    final matchesStatus =
        statusFilter == null || request.status == statusFilter;

    return matchesSearch && matchesRole && matchesStatus;
  }).toList();
});

// Provider cho pending requests only
final pendingRequestsProvider = Provider<List<UserRequest>>((ref) {
  final requests = ref.watch(userRequestListProvider);
  return requests.where((request) => request.isPending).toList();
});

// Provider cho confirmed requests only
final confirmedRequestsProvider = Provider<List<UserRequest>>((ref) {
  final requests = ref.watch(userRequestListProvider);
  return requests.where((request) => request.isConfirmed).toList();
});

// Provider cho thống kê
final userRequestStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final requests = ref.watch(userRequestListProvider);

  return {
    'total': requests.length,
    'pending': requests.where((r) => r.isPending).length,
    'confirmed': requests.where((r) => r.isConfirmed).length,
    'rejected': requests.where((r) => r.isRejected).length,
    'byRole': {
      for (var role in UserRole.values)
        role.displayName: requests.where((r) => r.role == role).length,
    },
  };
});

// Provider kiểm tra danh sách rỗng
final isUserRequestListEmptyProvider = Provider<bool>((ref) {
  final requests = ref.watch(userRequestListProvider);
  return requests.isEmpty;
});

// Provider đếm pending requests
final pendingRequestCountProvider = Provider<int>((ref) {
  final requests = ref.watch(userRequestListProvider);
  return requests.where((r) => r.isPending).length;
});

// Provider cho filtered count
final filteredRequestCountProvider = Provider<int>((ref) {
  final filteredRequests = ref.watch(filteredUserRequestsProvider);
  return filteredRequests.length;
});
