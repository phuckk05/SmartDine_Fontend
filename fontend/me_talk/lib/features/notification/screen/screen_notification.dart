import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:me_talk/core/style.dart';

class ScreenNotification extends ConsumerStatefulWidget {
  const ScreenNotification({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScreenNotificationState();
}

class _ScreenNotificationState extends ConsumerState<ScreenNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  iconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),

                  pinned: false,
                  elevation: 0,
                  centerTitle: false,
                  toolbarHeight: 50,
                  title: Text('Thông báo', style: Style.fontTitle),
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
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Gần đây', style: Style.fontTitleSuperMini),
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (context, index) {
              return _notification_bar(index);
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone,vertical: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Trước Đây', style: Style.fontTitleSuperMini),
            ),
          ),
           ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 10,
            itemBuilder: (context, index) {
              return _notification_bar(index);
            },
          ),
        ],
      ),
    );
  }
  
  final selectProvider = StateProvider<bool>((ref) => false);
  //Thanh thông báo
  Widget _notification_bar(int index) {
    final select = ref.watch(selectProvider);
    return InkWell(
      onTap: () {
        ref.read(selectProvider.notifier).state = true;
      },
      onLongPress: () {},
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: select? Colors.transparent : Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0),side: BorderSide.none),
        child: Padding(
          padding: const EdgeInsets.only(
            left: Style.paddingPhone,
            top: 0,
            bottom: 0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(radius: 30),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ffffffffffffffffffffffffffffffffggggggggggggggggggggggfh',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0, right: 2.0),
                          child: Text(
                            '2 giờ trước',
                            style: Style.fontCaption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: IconButton(
                      constraints: BoxConstraints(),
                      padding: EdgeInsets.all(2),
                      onPressed: () {},
                      icon: Icon(Icons.more_horiz),
                    ),
                  ),
                ],
              ),
              index % 2 == 0 ? _connectFriends() : SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _connectFriends() {
    return Padding(
      padding: const EdgeInsets.only(right: Style.paddingPhone),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                minimumSize: Size(100, 35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Chấp nhận', style: Style.fontButton),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: Size(100, 35),
                backgroundColor: Colors.black38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Xóa', style: Style.fontButton),
            ),
          ),
        ],
      ),
    );
  }
}
