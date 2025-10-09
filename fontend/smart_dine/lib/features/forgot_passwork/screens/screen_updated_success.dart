import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/signin/screen/screen_signin.dart';
import 'package:mart_dine/routes.dart';

class ScreenUpdatedSuccess extends ConsumerWidget {
  const ScreenUpdatedSuccess({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _icon(),
                SizedBox(height: 10),
                _updated(context),
                SizedBox(height: 20),
                _signinButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Widget con
  Widget _icon() {
    return Icon(Icons.check, size: 100, color: Colors.green);
  }

  Widget _updated(BuildContext context) {
    return Center(
      child: Text('Đã cập nhật thành công mật khẩu', style: Style.fontCaption),
    );
  }

  Widget _signinButton(BuildContext context) {
    // final isLoading = ref.watch(_isLoadingProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: ShadowCus(
        borderRadius: 20.0,
        baseColor: Style.buttonBackgroundColor, // Button's distinct color
        padding: EdgeInsets.zero, // Padding handled by MaterialButton
        child: MaterialButton(
          onPressed: () {
            Routes.pushRightLeftConsumerFul(context, ScreenSignIn());
          },
          // Set button color to transparent so NeumorphicContainer's color shows
          color: Colors.transparent,
          elevation: 0, // Remove default elevation
          highlightElevation: 0, // Remove highlight elevation
          splashColor: Colors.white.withOpacity(0.2), // Splash effect
          minWidth: double.infinity,
          height: 50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),

          // child: Text('Đăng nhập', style: Style.TextButton),
          child: Text('Đăng nhập ngay', style: Style.TextButton),
        ),
      ),
    );
  }
}
