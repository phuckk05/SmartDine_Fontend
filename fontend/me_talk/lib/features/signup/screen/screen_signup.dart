import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:me_talk/core/constrats.dart';
import 'package:me_talk/core/style.dart';
import 'package:me_talk/features/input_infor/screen/screen_inputinfor.dart';
import 'package:me_talk/routes.dart';
import 'package:me_talk/widgets/appbar.dart';

class ScreenSignup extends ConsumerStatefulWidget {
  const ScreenSignup({super.key});

  @override
  ConsumerState<ScreenSignup> createState() => _ScreenSignupState();
}

final _obscureText1 = StateProvider<bool>((ref) => true);
final _obscureText2 = StateProvider<bool>((ref) => true);

class _ScreenSignupState extends ConsumerState<ScreenSignup> {
  @override
  Widget build(BuildContext context) {
    // State to toggle password visibility

    return Scaffold(
      backgroundColor: Style.backgroundColor,
      appBar: AppBarCus(
        title: 'Đăng kí',
      ),

      body: SafeArea(
        child: _main(),
      ),
    );
  }

  Widget _main() {
    final isObscureText1 = ref.watch(_obscureText1);
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
          child: Column(
            children: [
            //        Center(
            //   child: InkWell(
            //     onTap: () => Navigator.of(context).pop(),
            //     child: Container(
            //       margin: const EdgeInsets.only(top: 0, bottom: 12),
            //       width: 50,
            //       height: 5,
            //       decoration: BoxDecoration(
            //         color: Colors.black.withOpacity(0.4),
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //   ),
            // ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tạo mới tài khoản',
                  style: Style.fontTitle,
                ),
              ),
              const SizedBox(height: 20), // Space before logo
              _nameTextfiled(),
              const SizedBox(height: 15), // Space between inputs
              _passwork1Texfiled(),
              const SizedBox(height: 15), // Space before buttons
              _passwork2Texfiled(),
              const SizedBox(height: 15),
              _warrning(),
              const SizedBox(height: 15), // Space before buttons
              _signupButton(),
            ],
          ),
        ),
      ),
    );
  }

  //Phần Nhập tên đăng nhập
  Widget _nameTextfiled() {
    return ShadowCus(
      isConcave: true, // Concave effect for input
      borderRadius: 10.0,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: Colors.grey[600]),
          hintText: 'Tên đăng nhập', // Use hintText instead of labelText
          hintStyle: const TextStyle(color: kTextColorLight),
          border: InputBorder.none, // Remove default border
          contentPadding: const EdgeInsets.only(
            left: 0,
            top: 12,
            bottom: 12,
            right: 0,
          ), // Adjust padding
        ),
        style: const TextStyle(color: kTextColorDark),
      ),
    );
  }

  //Phần button đăng kí
  Widget _signupButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ShadowCus(
        borderRadius: 20.0,
        baseColor: Style.buttonBackgroundColor, // Button's distinct color
        padding: EdgeInsets.zero, // Padding handled by MaterialButton
        child: MaterialButton(
          onPressed: () {
            Routes.pushAndRemoveUntil(context, ScreenInputInfor());
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
          child: Text('Đăng kí', style: Style.TextButton),
        ),
      ),
    );
  }

  //Phần thông báo lỗi
  Widget _warrning() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Thông báo lỗi !',
        style: TextStyle(
          color: Colors.red,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  //Phân nhập lại mật khẩu
  Widget _passwork2Texfiled() {
    final isObscureText2 = ref.watch(_obscureText2);
    return ShadowCus(
      isConcave: true, // Concave effect for input
      borderRadius: 10.0,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        obscureText: isObscureText2, // Toggle visibility
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
          hintText: 'Xác nhận mật khẩu', // Use hintText
          hintStyle: const TextStyle(color: kTextColorLight),
          border: InputBorder.none, // Remove default border
          contentPadding: const EdgeInsets.only(
            left: 0,
            top: 12,
            bottom: 12,
            right: 0,
          ), // Adjust padding
          suffixIcon: IconButton(
            icon: Icon(
              isObscureText2 ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () {
              ref.read(_obscureText2.notifier).state = !isObscureText2;
            },
          ),
        ),
        style: const TextStyle(color: kTextColorDark),
      ),
    );
  }

  //Phần nhập passwork lần 1
  Widget _passwork1Texfiled() {
    final isObscureText1 = ref.watch(_obscureText2);
    return ShadowCus(
      isConcave: true, // Concave effect for input
      borderRadius: 10.0,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        obscureText: isObscureText1, // Toggle visibility
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
          hintText: 'Mật khẩu', // Use hintText
          hintStyle: const TextStyle(color: kTextColorLight),
          border: InputBorder.none, // Remove default border
          contentPadding: const EdgeInsets.only(
            left: 0,
            top: 12,
            bottom: 12,
            right: 0,
          ), // Adjust padding
          suffixIcon: IconButton(
            icon: Icon(
              isObscureText1 ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () {
              ref.read(_obscureText1.notifier).state = !isObscureText1;
            },
          ),
        ),
        style: const TextStyle(color: kTextColorDark),
      ),
    );
  }
}
