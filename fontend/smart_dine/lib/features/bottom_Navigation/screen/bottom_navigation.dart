// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mart_dine/features/kitchen/screen_caidat.dart';
// import 'package:mart_dine/features/kitchen/screen_lichsu.dart';
// import 'package:mart_dine/features/kitchen/screen_phongbep.dart';
// import 'package:mart_dine/features/admin/screen_dashboard.dart';
// import 'package:mart_dine/features/admin/screen_qlcuahang.dart';
// import 'package:mart_dine/features/admin/screen_qlxacnhan.dart';

// // Các state provider
// final currentIndexProvider = StateProvider<int>((ref) => 0);

// class ScreenBottomNavigation extends ConsumerStatefulWidget {
//   final int? index;
//   const ScreenBottomNavigation({super.key, this.index});

//   @override
//   ConsumerState<ScreenBottomNavigation> createState() {
//     return _BottomNavigationState();
//   }
// }

// class _BottomNavigationState extends ConsumerState<ScreenBottomNavigation> {
//   // Danh sách các màn hình cho Kitchen (index = 1)
//   final List<Widget> _kitchenScreens = [
//     const KitchenScreen(),
//     const HistoryScreen(),
//     const SettingsScreen(),
//   ];

//   // Danh sách các màn hình cho Admin (index = 2)
//   final List<Widget> _adminScreens = [
//     const DashboardScreen(),
//     const ConfirmManagementScreen(), // screen_qlxacnhan.dart
//     const StoreManagementScreen(), // screen_qlcuahang.dart
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final currentIndex = ref.watch(currentIndexProvider);

//     // Xác định màn hình nào sẽ hiển thị dựa trên widget.index
//     final screens = widget.index == 2 ? _adminScreens : _kitchenScreens;

//     return Scaffold(
//       body: IndexedStack(index: currentIndex, children: screens),
//       bottomNavigationBar:
//           widget.index == 1
//               ? BottomNavigationBar(
//                 currentIndex: currentIndex,
//                 onTap: (index) {
//                   ref.read(currentIndexProvider.notifier).state = index;
//                 },
//                 type: BottomNavigationBarType.fixed,
//                 selectedItemColor: Colors.blue[700],
//                 unselectedItemColor: Colors.grey[600],
//                 selectedFontSize: 12,
//                 unselectedFontSize: 12,
//                 items: const [
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.kitchen_outlined),
//                     activeIcon: Icon(Icons.kitchen),
//                     label: 'Phòng bếp',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.history_outlined),
//                     activeIcon: Icon(Icons.history),
//                     label: 'Lịch sử',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.settings_outlined),
//                     activeIcon: Icon(Icons.settings),
//                     label: 'Cài đặt',
//                   ),
//                 ],
//               )
//               : widget.index == 2
//               ? BottomNavigationBar(
//                 currentIndex: currentIndex,
//                 onTap: (index) {
//                   ref.read(currentIndexProvider.notifier).state = index;
//                 },
//                 type: BottomNavigationBarType.fixed,
//                 selectedItemColor: Colors.blue[700],
//                 unselectedItemColor: Colors.grey[600],
//                 selectedFontSize: 12,
//                 unselectedFontSize: 12,
//                 items: const [
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.dashboard_outlined),
//                     activeIcon: Icon(Icons.dashboard),
//                     label: 'Dashboard',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.check_circle_outline),
//                     activeIcon: Icon(Icons.check_circle),
//                     label: 'Xác nhận',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.store_outlined),
//                     activeIcon: Icon(Icons.store),
//                     label: 'Cửa hàng',
//                   ),
//                 ],
//               )
//               : const SizedBox(),
//     );
//   }
// }
