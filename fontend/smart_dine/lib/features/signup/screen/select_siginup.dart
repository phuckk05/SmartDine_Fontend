import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/signup/screen/screen_signup.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/appbar.dart';

class ScreenSelectSiginup extends ConsumerWidget {
  const ScreenSelectSiginup({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBarCus(title: 'Chọn loại tài khoản'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _select(
                context,
                Icon(Icons.business, size: 40, color: Style.textColorWhite),
                'Chủ nhà hàng',
                'Đăng kí để trải nghiệm ứng dụng',
                1,
              ),
              const SizedBox(height: 20),
              _select(
                context,
                Icon(Icons.account_tree, size: 40, color: Style.textColorWhite),
                'Chinh nhánh',
                'Đăng kí để quản lí nhà hàng',
                2,
              ),
              const SizedBox(height: 20),
              _select(
                context,
                Icon(Icons.person, size: 40, color: Style.textColorWhite),
                'Nhân viên',
                'Đăng kí để quản lí nhà hàng',
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _select(
    BuildContext context,
    Icon icon,
    String inputTitle,
    String subtitle,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
      child: ShadowCus(
        isConcave: true,
        baseColor: Style.buttonBackgroundColor,
        borderRadius: 10.0,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ListTile(
          selectedColor: Style.textColorGray,
          leading: icon,
          title: Text(
            inputTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Style.textColorWhite,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Style.textColorGray,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onTap: () {
            if (index == 1) {
              Routes.pushRightLeftConsumerFul(context, ScreenSignup());
            }
          },
        ),
      ),
    );
  }
}
