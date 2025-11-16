import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/admin/screen_settingdashboard.dart';
import 'package:mart_dine/features/kitchen/screen_caidat.dart';
import 'package:mart_dine/features/kitchen/screen_kitchen.dart';
import 'package:mart_dine/features/kitchen/screen_lichsu.dart';
import 'package:mart_dine/features/admin/screen_dashboard.dart';
import 'package:mart_dine/features/admin/screen_qlcuahang.dart';
import 'package:mart_dine/features/admin/screen_qlxacnhan.dart';
import 'package:mart_dine/features/kitchen/screen_caidat.dart';
import 'package:mart_dine/features/kitchen/screen_kitchen.dart';
import 'package:mart_dine/features/kitchen/screen_lichsu.dart';
import 'package:mart_dine/providers/branch_provider.dart';

// // Các state provider
final currentIndexProvider = StateProvider<int>((ref) => 0);

class ScreenBottomNavigation extends ConsumerStatefulWidget {
  final int? branchId;
  final int? companyId;
  final int? index;
  final int? userId;
  const ScreenBottomNavigation({
    super.key,
    this.index,
    this.branchId,
    this.companyId,
    this.userId,
  });

  @override
  ConsumerState<ScreenBottomNavigation> createState() {
    return _BottomNavigationState();
  }
}

class _BottomNavigationState extends ConsumerState<ScreenBottomNavigation> {
  int? _branchId;
  int? _companyId;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _branchId = widget.branchId;
    _companyId = widget.companyId;

    if (widget.index == 1 && widget.userId != null) {
      if (_branchId == null || _companyId == null) {
        Future.microtask(_resolveBranchData);
      }
    }
  }

  Future<void> _resolveBranchData() async {
    if (_isResolving || widget.userId == null) return;

    _isResolving = true;

    int? branchId = _branchId;
    int? companyId = _companyId;

    if (branchId == null) {
      branchId = await ref
          .read(branchNotifierProvider.notifier)
          .getBranchIdByUserId(widget.userId!);
    }

    if (branchId != null && companyId == null) {
      companyId = await ref
          .read(branchNotifierProvider.notifier)
          .getCompanyIdByBranchId(branchId);
    }

    if (mounted) {
      setState(() {
        _branchId = branchId ?? _branchId;
        _companyId = companyId ?? _companyId;
      });
    }

    _isResolving = false;
  }

  List<Widget> _buildKitchenScreens() {
    return [
      ScreenKitchen(branch: _branchId, companyId: _companyId),
      ScreenHistory(branch: _branchId, companyId: _companyId),
      ScreenSetting(),
    ];
  }

  //   // Danh sách các màn hình cho Admin (index = 2)
  final List<Widget> _adminScreens = [
    const ScreenDashboard(),
    const ScreenQlXacNhan(),
    const ScreenQlCuaHang(),
    const ScreenSettingDashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentIndexProvider);

    // Xác định màn hình nào sẽ hiển thị dựa trên widget.index
    final screens = widget.index == 2 ? _adminScreens : _buildKitchenScreens();

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar:
          widget.index == 1
              ? BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  ref.read(currentIndexProvider.notifier).state = index;
                },
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.blue[700],
                unselectedItemColor: Colors.grey[600],
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.kitchen_outlined),
                    activeIcon: Icon(Icons.kitchen),
                    label: 'Phòng bếp',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_outlined),
                    activeIcon: Icon(Icons.history),
                    label: 'Hoạt động món ăn',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Cài đặt',
                  ),
                ],
              )
              : widget.index == 2
              ? BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  ref.read(currentIndexProvider.notifier).state = index;
                },
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.blue[700],
                unselectedItemColor: Colors.grey[600],
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline),
                    activeIcon: Icon(Icons.check_circle),
                    label: 'Xác nhận',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.store_outlined),
                    activeIcon: Icon(Icons.store),
                    label: 'Cửa hàng',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Cài đặt',
                  ),
                ],
              )
              : const SizedBox(),
    );
  }
}
