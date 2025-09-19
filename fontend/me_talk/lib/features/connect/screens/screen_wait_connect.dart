
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:me_talk/core/style.dart';
import 'package:me_talk/features/connect/screens/screen_viewAll.dart';
import 'package:me_talk/routes.dart';
import 'package:me_talk/widgets/list_connect.dart';

class ScreenWaitConnect extends ConsumerWidget {
  const ScreenWaitConnect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(child: Column(children: [_caption(context), SizedBox(height: 10), ListConnect()])),
    );
  }

  //Caption
  Widget _caption(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              Routes.pushRightLeft(context, ViewAllScreen());
            },
            child: Text(
              'Xem tất cả',
              style: Style.fontCaption.copyWith(color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
