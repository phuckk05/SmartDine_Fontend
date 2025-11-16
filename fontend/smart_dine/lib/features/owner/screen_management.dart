// file: screens/screen_management.dart
// ĐÃ CẬP NHẬT: Hiển thị tên quản lý

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart' show ShadowCus;
import 'screen_restaurant_detail.dart'; 
import 'screen_approve_branch.dart'; // THÊM: Import màn hình duyệt
import 'screen_add_restaurant.dart';
import 'package:mart_dine/providers_owner/target_provider.dart'; 
import 'package:mart_dine/models_owner/branch.dart'; 
import 'package:mart_dine/providers_owner/user_provider.dart'; 
import 'package:mart_dine/providers_owner/staff_profile_provider.dart'; // <<< SỬA: Thêm import
import 'package:mart_dine/providers_owner/branch_provider.dart'; // THÊM: Để invalidate pendingBranchesProvider
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/models_owner/user.dart'; 

class ScreenManagement extends ConsumerStatefulWidget {
 const ScreenManagement({super.key});
 @override
 ConsumerState<ScreenManagement> createState() => _ScreenManagementState();
}

class _ScreenManagementState extends ConsumerState<ScreenManagement> {
 final TextEditingController _searchController = TextEditingController();
 bool _isSearching = false;

 @override
 void initState() {
  super.initState();
 }

 @override
 void dispose() {
  _searchController.dispose();
  super.dispose();
 }

 // Hàm này chỉ trigger rebuild để lọc lại danh sách trong hàm build
 void _filterBranches() { setState(() {}); }

 // Hàm tắt chế độ tìm kiếm
 void _stopSearching() {
  setState(() {
   _isSearching = false;
   _searchController.clear();
   // Không cần gọi _filterBranches() vì build sẽ tự lọc lại khi _searchController rỗng
  });
 }

 // Widget xây dựng tiêu đề AppBar (có thể tìm kiếm hoặc tiêu đề tĩnh)
 Widget _buildAppBarTitle() {
  if (_isSearching) {
   return Container(
    height: 38,
    padding: const EdgeInsets.symmetric(vertical: 0),
    child: TextField(
     controller: _searchController,
     autofocus: true,
     textInputAction: TextInputAction.search,
     onSubmitted: (_) => _filterBranches(), // Tìm khi bấm Enter
     onChanged: (_) => _filterBranches(), // Tìm kiếm real-time
     style: const TextStyle(color: Colors.black, fontSize: 18),
     decoration: InputDecoration(
      hintText: 'Tìm kiếm chi nhánh...',
      hintStyle: TextStyle(color: Colors.grey.shade600),
      fillColor: Colors.grey.shade200,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      border: OutlineInputBorder(
       borderRadius: BorderRadius.circular(8),
       borderSide: BorderSide.none,
      ),
     ),
    ),
   );
  } else {
   return const Text(
    "Quản lý",
    style: TextStyle(
     color: Colors.black,
     fontWeight: FontWeight.bold,
     fontSize: 24,
    ),
   );
  }
 }

 @override
 Widget build(BuildContext context) {
  // SỬA: Lấy thông tin chủ sở hữu (owner) để có companyId
  final ownerAsync = ref.watch(ownerProfileProvider);

  return Scaffold(
   backgroundColor: Colors.white,
   appBar: AppBar(
    title: _buildAppBarTitle(),
    backgroundColor: Colors.white,
    elevation: 0,
    // SỬA: Tách actions ra widget riêng để xử lý companyId bất đồng bộ
    actions: _buildAppBarActions(ownerAsync),
   ),
   body: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
      const Text("Các chi nhánh", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 15),
      Expanded(
        // SỬA: Bọc danh sách trong RefreshIndicator
        child: RefreshIndicator(
          onRefresh: () async {
            print("[Pull-to-Refresh] Làm mới dữ liệu chi nhánh...");
            // Lấy companyId một cách an toàn
            final owner = ref.read(ownerProfileProvider).value;
            if (owner?.companyId != null) {
              // Invalidate các provider để chúng tự tải lại dữ liệu mới
              ref.invalidate(branchListProvider);
              ref.invalidate(pendingBranchesProvider);
            }
          },
          child: _BranchList(
            ownerAsync: ownerAsync,
            searchQuery: _searchController.text,
          ),
        ),
      ),
     ],
    ),
   ),
  );
 }
 
 List<Widget> _buildAppBarActions(AsyncValue<User> ownerAsync) {
  return [
   if (_isSearching)
    IconButton(icon: const Icon(Icons.search, size: 28, color: Colors.blue), onPressed: _filterBranches)
   else
    IconButton(icon: const Icon(Icons.search, size: 28, color: Colors.black), onPressed: () => setState(() => _isSearching = true)),
   
   if (_isSearching)
    IconButton(icon: const Icon(Icons.close, size: 28, color: Colors.black), onPressed: _stopSearching)
   else
    IconButton(
      icon: const Icon(Icons.add, size: 28, color: Colors.black),
      onPressed: () async {
       // Chỉ cho phép thêm nếu đã có companyId
       final companyId = ownerAsync.value?.companyId;
       if (companyId != null) {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenAddRestaurant()));
        // Refresh lại danh sách chi nhánh sau khi thêm
        ref.invalidate(branchesByCompanyProvider(companyId));
       }
      }
    ),
   // THÊM: Nút điều hướng đến màn hình duyệt
   IconButton(
      icon: const Icon(Icons.fact_check_outlined, size: 28, color: Colors.black),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ScreenApproveBranch()));
      },
    ),
   const SizedBox(width: 8),
  ];
 }
}

// SỬA: Widget con để xử lý logic tải và hiển thị danh sách chi nhánh
class _BranchList extends ConsumerWidget {
 final AsyncValue<User> ownerAsync;
 final String searchQuery;

 const _BranchList({required this.ownerAsync, required this.searchQuery});

  // SỬA: Tách _branchCard ra thành một widget riêng (hoặc static)
  // để ListView.builder có thể gọi
  Widget _branchCard(Branch branchData, String managerName, BuildContext context) {
   return GestureDetector(
   onTap: () {
    // Chuyển sang màn hình chi tiết, truyền đối tượng Branch
    Navigator.push(
     context,
     MaterialPageRoute(
      builder: (context) => ScreenRestaurantDetail(branchData: branchData),
     ),
    );
   },
   child: Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
     color: Colors.grey.shade100,
     borderRadius: BorderRadius.circular(15),
     boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3)) ],
    ),
    child: Row(
     mainAxisAlignment: MainAxisAlignment.spaceBetween,
     children: [
      Expanded(
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Text(branchData.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
         const SizedBox(height: 2),
         Text(branchData.address, style: const TextStyle(fontSize: 13, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
         Text(managerName, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
       ),
      ),
      const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black54),
     ],
    ),
   ),
  );
 }


 @override
 Widget build(BuildContext context, WidgetRef ref) {
  return ownerAsync.when(
   loading: () => const Center(child: CircularProgressIndicator()),
   error: (err, stack) => Center(child: Text('Lỗi tải thông tin người dùng: $err', style: const TextStyle(color: Colors.red))),
   data: (owner) {
    final companyId = owner.companyId;
    if (companyId == null) {
     return const Center(child: Text("Lỗi: Người dùng không thuộc công ty nào."));
    }

    // Khi đã có companyId, watch các provider liên quan
    final branchListAsync = ref.watch(branchesByCompanyProvider(companyId));
        // SỬA: Lấy tất cả user (staff) từ staffProfileProvider
    final staffListAsync = ref.watch(staffProfileProvider);

    // Xử lý .when() lồng nhau cho 2 provider còn lại
    return branchListAsync.when(
     loading: () => const Center(child: CircularProgressIndicator()),
     error: (err, stack) => Center(child: Text('Lỗi tải chi nhánh: $err', style: const TextStyle(color: Colors.red))),
     data: (allBranches) {
      return staffListAsync.when( // SỬA: Đổi tên provider
       loading: () => const Center(child: CircularProgressIndicator()),
       error: (err, stack) => Center(child: Text('Lỗi tải người dùng: $err', style: const TextStyle(color: Colors.red))),
       data: (allStaffProfiles) { // SỬA: Đổi tên biến
                
                // SỬA: Lọc theo statusId = 1 (Đã duyệt), dựa trên CSDL
                final approvedBranches = allBranches.where((branch) => branch.statusId == 1).toList();

        final query = searchQuery.toLowerCase();
        final filteredBranches = query.isEmpty
          ? approvedBranches // SỬA: Dùng danh sách đã duyệt
          : approvedBranches.where((branch) => // SỬA: Dùng danh sách đã duyệt
            branch.name.toLowerCase().contains(query) ||
            branch.address.toLowerCase().contains(query)).toList();

        if (filteredBranches.isEmpty) {
         return Center(child: Text(query.isEmpty ? "Công ty này chưa có chi nhánh nào." : "Không tìm thấy chi nhánh."));
        }

                // SỬA: Tạo map từ staffProfileProvider
        final userMap = {for (var profile in allStaffProfiles) profile.user.id: profile.user};

        return ListView.builder(
         itemCount: filteredBranches.length,
         itemBuilder: (context, index) {
          final branch = filteredBranches[index];
          final managerName = userMap[branch.managerId]?.fullName ?? "QL ID: ${branch.managerId}";
          // SỬA: Gọi hàm _branchCard đã tách
          return _branchCard(branch, managerName, context);
         },
        );
       },
      );
     },
    );
   },
  );
 }
}