import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/forgot_passwork/screens/screen_confirm.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/appbar.dart';

class ScreenFindaccuont extends ConsumerWidget {
  ScreenFindaccuont({super.key});

  //contrllers
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBarCus(title: "Tìm tài khoản"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label("Nhập địa chỉ email của bạn"),
                  _textFiled(
                    1,
                    null,
                    Icon(Icons.email),
                    null,
                    _emailController,
                    null,
                  ),
                  SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _signinButton(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Widget con
  //Phần button tiếp tục
  Widget _signinButton(BuildContext context) {
    // final isLoading = ref.watch(_isLoadingProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: ShadowCus(
        borderRadius: 20.0,
        baseColor: Style.buttonBackgroundColor, // Button's distinct color
        padding: EdgeInsets.zero, // Padding handled by MaterialButton
        child: MaterialButton(
          onPressed: () async {
            Routes.pushRightLeftConsumerFul(
              context,
              ScreenConfirm(email: _emailController.text.toString()),
            );
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
          child: Text('Tiếp tục', style: Style.TextButton),
        ),
      ),
    );
  }

  //label
  Widget _label(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: Style.fontContent),
    );
  }

  // (note widget removed — unused)

  //Textfield
  Widget _textFiled(
    int index,
    bool? isObscureText,
    Icon icon,
    String? hintText,
    TextEditingController controller,
    IconButton? suffixIcon,
  ) {
    return ShadowCus(
      isConcave: true, // Concave effect for input
      borderRadius: 10.0,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        obscureText: isObscureText ?? false,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon,
          hintText: hintText ?? '', // Use hintText instead of labelText
          hintStyle: const TextStyle(color: Style.textColorGray),
          border: InputBorder.none, // Remove default border
          contentPadding: const EdgeInsets.only(
            left: 0,
            top: 12,
            bottom: 12,
            right: 0,
          ), // Adjust padding
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
