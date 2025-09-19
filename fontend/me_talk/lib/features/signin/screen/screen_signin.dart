import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:me_talk/core/constrats.dart';
import 'package:me_talk/core/style.dart';
import 'package:me_talk/features/forgot_passwork/screen/screen_findaccuont.dart';
import 'package:me_talk/features/signup/screen/screen_signup.dart';
import 'package:me_talk/providers/signin_provider.dart';
import 'package:me_talk/routes.dart';
import 'package:me_talk/widgets/loading.dart';

class ScreenSignIn extends ConsumerStatefulWidget {
  const ScreenSignIn({super.key});
  @override
  ConsumerState<ScreenSignIn> createState() => _ScreenSignInState();
}

final _obscureText = StateProvider<bool>((ref) => true);
final _isLoadingProvider = StateProvider<bool>((ref) => false);

class _ScreenSignInState extends ConsumerState<ScreenSignIn> {
  final Constrats constrats = Constrats();
  // State to toggle password visibility

  //method to handle login logic

  // void toSignUp() {
  //   //show sign-up modal
  //   showModalBottomSheet(
  //     isScrollControlled: true, // Allow full screen height
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(180),
  //         topRight: Radius.circular(180),
  //       ),
  //     ),
  //     builder:
  //         (context) =>
  //             FractionallySizedBox(heightFactor: 0.8, child: ScreenSignup()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Background color
      backgroundColor: Style.backgroundColor,
      //Body
      body:
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center, // Center content horizontally
                    children: [
                      _logo(),
                      const SizedBox(height: 20),
                      _textFiledName(),
                      const SizedBox(height: 15), // Space between inputs
                      _textFiledPass(),
                      const SizedBox(height: 10), // Space before buttons
                      _forgot_signup(),
                      const SizedBox(height: 10), // Space before buttons
                      _signinButton(),
                    ],
                  ),
                ),
                       
                    ),
            ),
          ),
    );
  }

  //Phần button đăng nhập
  Widget _signinButton() {
    final isLoading = ref.watch(_isLoadingProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: ShadowCus(
        borderRadius: 20.0,
        baseColor: Style.buttonBackgroundColor, // Button's distinct color
        padding: EdgeInsets.zero, // Padding handled by MaterialButton
        child: MaterialButton(
          onPressed: () {
            ref.read(_isLoadingProvider.notifier).state = true;
            Future.delayed(
              Duration(seconds: 5),
              () => ref.read(_isLoadingProvider.notifier).state = false,
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
          child:
              isLoading
                  ? Loading()
                  : Text('Đăng nhập', style: Style.TextButton),
        ),
      ),
    );
  }

  //Phần logo app và tên app
  Widget _logo() {
    return Column(
      children: [
        Hero(
          tag: 'appImage',
          child: Image.asset(
            'assets/images/LogoApp2.png', // Replace with your logo path
            width: 80,
            height: 80,
          ),
        ),
         Hero(
          tag: 'appName',
           child: Text(
            'Metalk',
            style: TextStyle(
              fontSize: Style.headingFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Use a distinct color for emphasis
              fontFamily: Style.fontFamily,
            ),
                   ),
         ),
      ],
    );
  }
  //Phân tên đăng nhập

  Widget _textFiledName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ShadowCus(
        isConcave: true, // Concave effect for input
        borderRadius: 10.0,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Hero(
          tag: 'tendangnhap',
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
            onSubmitted:
                (value) => ref.read(userProvider.notifier).updateName(value),
            style: const TextStyle(color: kTextColorDark),
          ),
        ),
      ),
    );
  }

  //Phần mật khẩu
  Widget _textFiledPass() {
    final _isObscureText = ref.watch(_obscureText);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ShadowCus(
        isConcave: true, // Concave effect for input
        borderRadius: 10.0,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: TextField(
          obscureText: _isObscureText, // Toggle visibility
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
                _isObscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () {
                ref.read(_obscureText.notifier).state = !_isObscureText;
              },
            ),
          ),
          onSubmitted:
              (value) => ref.read(userProvider.notifier).updateAge(value),
          style: const TextStyle(color: kTextColorDark),
        ),
      ),
    );
  }

  //Phần  quên mật khẩu và đăng kí
  Widget _forgot_signup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Routes.pushRightLeft(context, ScreenFindAccuont());
          },
          child: Text(
            'Quên mật khẩu?',
            style: TextStyle(color: Style.kTextColorMedium),
          ),
        ),
        Text('Hoặc', style: TextStyle(color: Style.kTextColorMedium)),
        TextButton(
          onPressed: ()=> Routes.pushBottomTop(context, ScreenSignup()),
          child: Text(
            'Đăng kí',
            style: TextStyle(
              color: Colors.blue, // Distinct color for Sign Up
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
