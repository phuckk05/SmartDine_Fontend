import 'package:flutter/material.dart';
import 'package:me_talk/core/style.dart';
import 'package:me_talk/widgets/icon_back.dart';

class AppBarCus extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const AppBarCus({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconBack.back(context),
      backgroundColor: Colors.transparent,
      // title:  Text(title!, style: Style.fontTitleDark,));
    );
  }
    @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}