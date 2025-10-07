import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/icon_back.dart';

class AppBarCus extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const AppBarCus({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconBack.back(context),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(title!, style: Style.fontTitle),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
