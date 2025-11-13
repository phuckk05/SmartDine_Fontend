import 'package:flutter/material.dart';
import 'package:mart_dine/features/branch_management/screen/branch_dashboard.dart';
import 'package:mart_dine/features/branch_management/screen/employee_management_screen.dart';
import 'package:mart_dine/features/branch_management/screen/table_management_screen.dart';
import 'package:mart_dine/features/branch_management/screen/branch_reports_screen.dart';
import 'package:mart_dine/features/branch_management/screen/settings_screen.dart';

class BranchManagementNavigation extends StatefulWidget {
  const BranchManagementNavigation({super.key});
  
  @override
  State<BranchManagementNavigation> createState() => _BranchManagementNavigationState();
}

class _BranchManagementNavigationState extends State<BranchManagementNavigation> {
  int _selectedIndex = 0;
  
  // Các màn hình của Branch Management - 5 tabs chính
  final List<Widget> _screens = [
    const BranchDashboardScreen(),
    const EmployeeManagementScreen(showBackButton: false),
    const TableManagementScreen(showBackButton: false),
    const BranchReportsScreen(showBackButton: false),
    const SettingsScreen(showBackButton: false),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 8,
        items: _buildNavigationItems(),
      ),
    );
  }
  
  List<BottomNavigationBarItem> _buildNavigationItems() {
    final Color activeColor = Theme.of(context).primaryColor;
    
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard, color: activeColor),
        label: 'Dashboard',
        tooltip: 'Tổng quan chi nhánh',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people, color: activeColor),
        label: 'Nhân viên',
        tooltip: 'Quản lý nhân viên',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.table_restaurant_outlined),
        activeIcon: Icon(Icons.table_restaurant, color: activeColor),
        label: 'Bàn ăn',
        tooltip: 'Quản lý bàn ăn',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics, color: activeColor),
        label: 'Báo cáo',
        tooltip: 'Thống kê và báo cáo',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings_outlined),
        activeIcon: Icon(Icons.settings, color: activeColor),
        label: 'Cài đặt',
        tooltip: 'Cài đặt và hồ sơ',
      ),
    ];
  }
}
