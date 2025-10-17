import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/icon_back.dart';

class AppBarCus extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? isCanpop;
  const AppBarCus({super.key, this.title, this.isCanpop});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isCanpop ?? true,
      child: AppBar(
        leading: IconBack.back(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(title!, style: Style.fontTitle),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
