import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:me_talk/features/connect/screens/screen_connect.dart';
import 'package:me_talk/features/home/screen/screen_home.dart';
import 'package:me_talk/features/notification/screen/screen_notification.dart';
import 'package:me_talk/features/profile/screen/screen_profile.dart';
import 'package:me_talk/features/to_match/screen/screen_tomatch.dart';
import 'package:me_talk/providers/mode_provider.dart';
import 'package:me_talk/widgets/list_post.dart';

class ScreenBottomNavigation extends ConsumerStatefulWidget {
  const ScreenBottomNavigation({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScreenBottomNavigationState();
}

//Các provider sẽ được định nghĩa ở đây nếu cần thiết

final _selectedIndexProvider = StateProvider<int>((ref) => 0);

class _ScreenBottomNavigationState
    extends ConsumerState<ScreenBottomNavigation> {
  //Các Screen sẽ được định nghĩa ở đây
  final List<Widget> _screens = [
    const ScreenHome(),
    const ScreenTomatch(),
    const ScreenConnect(),
    const ScreenNotification(),
    const ScreenProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    //lấy stateproviders
    final isScroll = ref.watch(isScrollProvider);
    return Scaffold(
      body: SafeArea(child: _screens[ref.watch(_selectedIndexProvider)]),

      bottomNavigationBar:AnimatedSlide(
        offset: isScroll ? const Offset(0, 1) : Offset.zero,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
        child: AnimatedOpacity(
          opacity: isScroll ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
          child:!isScroll? BottomNavigationBar(
            currentIndex: ref.watch(_selectedIndexProvider),
            onTap: (index) {
              ref.read(_selectedIndexProvider.notifier).state = index;
            },
            selectedItemColor: ref.watch(modeProvider) ? Colors.white : Colors.black,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ref.watch(modeProvider) ? Colors.white : Colors.black,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: ref.watch(modeProvider) ? Colors.white70 : Colors.black54,
            ),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Trang chủ',
                activeIcon: Icon(Icons.home, color: Colors.blue),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Ghép đôi',
                activeIcon: Icon(Icons.favorite, color: Colors.red),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Kết nối',
                activeIcon: Icon(Icons.group, color: Colors.green),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Thông báo',
                activeIcon: Icon(Icons.notifications, color: Colors.orange),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Hồ sơ',
                activeIcon: Icon(Icons.person, color: Colors.blue),
              ),
            ],
          ): BottomNavigationBar(
            currentIndex: ref.watch(_selectedIndexProvider),
            onTap: (index) {
              ref.read(_selectedIndexProvider.notifier).state = index;
            },
            selectedItemColor: ref.watch(modeProvider) ? Colors.white : Colors.black,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ref.watch(modeProvider) ? Colors.white : Colors.black,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: ref.watch(modeProvider) ? Colors.white70 : Colors.black54,
            ),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Trang chủ',
                activeIcon: Icon(Icons.home, color: Colors.blue),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Ghép đôi',
                activeIcon: Icon(Icons.favorite, color: Colors.red),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Kết nối',
                activeIcon: Icon(Icons.group, color: Colors.green),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Thông báo',
                activeIcon: Icon(Icons.notifications, color: Colors.orange),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Hồ sơ',
                activeIcon: Icon(Icons.person, color: Colors.blue),
              ),
            ],
          )
        ),
      )
    );
  }
}
