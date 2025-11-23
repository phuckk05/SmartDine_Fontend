// file: screens/screen_restaurant_detail.dart
// ĐÃ CẬP NHẬT: Nhận model Branch thay vì Map

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Import các file tab con
import '_tab_info_restaurant.dart';
import '_tab_staff_management.dart';
import 'screen_order_list.dart'; 
// SỬA: Import model
import 'package:mart_dine/models_owner/branch.dart'; 

class ScreenRestaurantDetail extends ConsumerStatefulWidget {
  final Branch branchData; 

  const ScreenRestaurantDetail({super.key, required this.branchData});

  @override
  ConsumerState<ScreenRestaurantDetail> createState() => _ScreenRestaurantDetailState();
}

class _ScreenRestaurantDetailState extends ConsumerState<ScreenRestaurantDetail> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy ID chi nhánh để truyền xuống
    final currentBranchId = widget.branchData.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... (AppBar style giữ nguyên)
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        title: Text(
          widget.branchData.name, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Thông tin"), // Rút gọn tên tab
            Tab(text: "Nhân viên"), // Rút gọn tên tab
            Tab(text: "Đơn hàng"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Thông tin (Không đổi)
          TabInfoRestaurant(branchData: widget.branchData), 
          
          // Tab 2: Nhân viên - Truyền branchId
          TabStaffManagement(branchId: currentBranchId), 
          
          // Tab 3: Đơn hàng - Truyền branchId
          ScreenOrderList(branchId: currentBranchId), 
        ],
      ),
    );
  }
}