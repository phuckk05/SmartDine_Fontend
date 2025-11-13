import 'package:flutter/material.dart';
import 'package:mart_dine/features/branch_management/screen/branch_dashboard.dart';
import 'package:mart_dine/features/branch_management/screen/employee_management_screen.dart';
import 'package:mart_dine/features/branch_management/screen/table_management_screen.dart';
import 'package:mart_dine/features/branch_management/screen/branch_reports_screen.dart';

class BranchManagementNavigation extends StatefulWidget {
  const BranchManagementNavigation({super.key});
  
  @override
  State<BranchManagementNavigation> createState() => _BranchManagementNavigationState();
}

class _BranchManagementNavigationState extends State<BranchManagementNavigation> {
  int _selectedIndex = 0;
  
  // Các màn hình của Branch Management - 4 tabs chính
  final List<Widget> _screens = [
    const BranchDashboardScreen(),
    const EmployeeManagementScreen(showBackButton: false),
              const TableManagementScreen(showBackButton: false),
    const BranchReportsScreen(showBackButton: false),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people, color: Colors.blue),
            label: 'Nhân viên',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant_outlined),
            activeIcon: Icon(Icons.table_restaurant, color: Colors.blue),
            label: 'Bàn ăn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics, color: Colors.blue),
            label: 'Báo cáo',
          ),
        ],
      ),
    );
  }
}
