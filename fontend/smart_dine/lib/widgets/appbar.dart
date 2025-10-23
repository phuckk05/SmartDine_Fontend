import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/icon_back.dart';

class AppBarCus extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isCanpop;
  final bool isButtonEnabled;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Color? backgroundColor;
  const AppBarCus({
    super.key,
    this.title,
    required this.isCanpop,
    required this.isButtonEnabled,
    this.actions,
    this.centerTitle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isCanpop,
      child:
          isButtonEnabled
              ? AppBar(
                leading: IconBack.back(context),
                backgroundColor: backgroundColor ?? Colors.transparent,
                elevation: 0,
                centerTitle: centerTitle ?? true,
                title: Text(title!, style: Style.fontTitle),
                actions: actions,
              )
              : AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: backgroundColor ?? Colors.transparent,
                elevation: 0,
                centerTitle: centerTitle ?? true,
                title: Text(title!, style: Style.fontTitle),
                actions: actions,
              ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
