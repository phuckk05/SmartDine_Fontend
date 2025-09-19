import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:me_talk/core/style.dart';
import 'package:me_talk/widgets/icon_back.dart';
import 'package:me_talk/widgets/list_connect.dart';

class ViewAllScreen extends ConsumerStatefulWidget {
  const ViewAllScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ViewAllScreenState();
}
class _ViewAllScreenState extends ConsumerState<ViewAllScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  iconTheme: IconThemeData(color: Colors.blue.shade700),
                  pinned: true,
                  elevation: 0,
                  leading: IconBack.back(context),
                  centerTitle: true,
                  toolbarHeight: 50,
                  title: Text('Chờ kết nối', style: Style.fontTitleMini),
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
  Widget _body(){
    return SingleChildScrollView(
      child: Column(
      children: [
        _caption(),
        SizedBox(height: 10,),
        ListConnect()
      ],
        
      ),
    );
  }
  //Caption
  Widget _caption() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Chờ kết nối', style: Style.fontTitleMini),
        ],
      ),
    );
  }
}