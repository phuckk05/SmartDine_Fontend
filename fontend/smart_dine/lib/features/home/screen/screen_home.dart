import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/providers/mode_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/widgets/drawer_home.dart';

class ScreenHome extends ConsumerStatefulWidget {
  const ScreenHome({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScreenHomeState();
}

//Các trạng thái
final isScrollProvider = StateProvider<bool>((ref) => false);
final isshowBottomProvider = StateProvider<bool>((ref) => false);

class _ScreenHomeState extends ConsumerState<ScreenHome> {
  //Biến
  late ScrollController _scrollController;

  //Method

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    checkScroll();
  }

  //Kiểm tra người dùng có cuộn hay không?
  void checkScroll() {
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      final isScroll = ref.read(isScrollProvider);

      if (direction == ScrollDirection.reverse && !isScroll) {
        ref.read(isScrollProvider.notifier).state = true; // Ẩn
        ref.read(isshowBottomProvider.notifier).state = true;
      } else if (direction == ScrollDirection.forward && isScroll) {
        ref.read(isScrollProvider.notifier).state = false; // Hiện
        ref.read(isshowBottomProvider.notifier).state = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái chế độ sáng tối từ provider
    final isDarkMode = ref.watch(modeProvider);

    // Thiết lập chệ độ sáng tối
    Constrats.Mode(isDarkMode);

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  iconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  pinned: true,
                  elevation: 0,
                  centerTitle: false,
                  toolbarHeight: 50,
                  titleSpacing: 0,
                  title: Text('Metalk', style: Style.fontTitle),
                  // Tự lấy màu theo Theme hệ thống
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  // Ngăn hiệu ứng overlay gây mờ
                  surfaceTintColor: Colors.transparent,
                  actions: [
                    IconButton(
                      icon: Icon(
                        LucideIcons.search,
                        size: 24,
                        // color: Colors.blue.shade700,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],

          body: _body(),
        ),
      ),
      drawer: DrawerHome(),
    );
  }

  //Phần body
  Widget _body() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // SizedBox(height: 10),
          // CreatePost(),
          // SizedBox(height: 10),
          // Divider(),
          // SizedBox(height: 10),
          // _listImage(),
          // SizedBox(height: 10),
          // ListPost(),
        ],
      ),
    );
  }

  Widget _listImage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phù hợp với bạn ', style: Style.fontTitleMini),
              Text('Xem tất cả', style: Style.fontCaption),
            ],
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 260,
          child: ListView.builder(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blueGrey.shade300,
                      width: 1,
                    ),
                  ),
                  width: 150,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/images/logoApp.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  maxLines: 1,
                                  'Phúcffffffffff $index',
                                  style: Style.fontUsername,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                maxLines: 1,
                                ',25',
                                style: Style.fontUsername,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            FluentIcons.location_20_filled,
                            size: 15,
                            color: Colors.red,
                          ),
                          SizedBox(width: 5),
                          Text('Hà Nội', style: Style.fontCaption),
                        ],
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: Colors.blue.shade700,
                          ),
                          onPressed: () {},
                          child: Text('Ghép đôi', style: Style.fontButton),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
