import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:me_talk/core/style.dart';
import 'package:me_talk/features/connect/screens/screen_wait_connect.dart';
import 'package:me_talk/providers/mode_provider.dart';
import 'package:me_talk/widgets/list_connect_suggettions.dart';
import 'package:me_talk/widgets/list_connected.dart';

class ScreenConnect extends ConsumerStatefulWidget {
  const ScreenConnect({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenConnectState();
}

class _ScreenConnectState extends ConsumerState<ScreenConnect> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
                  pinned: true,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  centerTitle: false,
                  toolbarHeight: 50,
                  title: Text('Kết nối', style: Style.fontTitle),
                  // Tự lấy màu theo Theme hệ thống
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  // Ngăn hiệu ứng overlay gây mờ
                  surfaceTintColor: Colors.transparent,
                  actions: [
                    IconButton(
                      icon: const Icon(LucideIcons.search, size: 24),
                      onPressed: () {
                        // Thực hiện hành động làm mới kết nối
                      },
                    ),
                  ],
                ),
              ],

          body: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(border: Border(bottom: BorderSide.none)),
            child: TabBar(
              isScrollable: false,
              dividerColor: Colors.transparent,
              labelStyle:TextStyle(fontWeight: FontWeight.bold),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3.0,
                  color: ref.watch(modeProvider)? Colors.white : Colors.black
                ), // Gạch ngang
                borderRadius: BorderRadius.all(Radius.circular(10)),
                insets: EdgeInsets.symmetric(horizontal: 20), 
              ),
              unselectedLabelColor: Colors.grey[500],
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              tabs: [
                Tab(text: 'Chờ kết nối',),
                Tab(text: 'Gợi ý kết nối'),
                Tab(text: 'Đã kết nối'),
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              children: [
                ScreenWaitConnect(),
                ListConnectSuggettions(),
                ListConnected(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
