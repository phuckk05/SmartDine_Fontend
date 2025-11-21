import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/providers_owner/mode_provider.dart';

// Các provider State

class DrawerHome extends ConsumerWidget {
  const DrawerHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Lấy provider
    final isDarkMode = ref.watch(modeProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 40),
                SizedBox(height: 10),
                Text('Phúc Nguyễn', style: Style.fontTitle),
              ],
            ),
          ),
          ListTile(
            leading: Icon(FluentIcons.home_20_regular),
            title: Text('Trang chủ', style: Style.fontCaption),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SwitchListTile.adaptive(
            value: isDarkMode,
            onChanged:
                (value) => ref.read(modeProvider.notifier).setMode(value),
            title: Text('Chế độ tối', style: Style.fontCaption),
          ),
        ],
      ),
    );
  }
}
