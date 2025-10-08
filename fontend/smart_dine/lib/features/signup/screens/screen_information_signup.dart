import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/widgets/loading.dart';

//Các state provider
final _isLoadingProvider = StateProvider<bool>((ref) => false);
final _obscureText1Provider = StateProvider<bool>((ref) => true);
final _obscureText2Provider = StateProvider<bool>((ref) => true);

//Giao diện đăng kí thông tin cá nhân
class ScreenInformationSignup extends ConsumerWidget {
  final String? title;
  final int index;
  ScreenInformationSignup({super.key, this.title, required this.index});

  //Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Xem các state
    final _obscureText1 = ref.watch(_obscureText1Provider);
    final _obscureText2 = ref.watch(_obscureText2Provider);

    //Build giao diện
    return Scaffold(
      appBar: AppBarCus(title: title ?? ''),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
            child: Column(
              children: [
                // _label("Tên đăng nhập*"),
                // _textFiled(
                //   Icon(Icons.person, color: Colors.grey[600]),
                //   "",
                //   _usernameController,
                // ),
                SizedBox(height: 10),
                _label("Số điện thoại*"),
                _textFiled(
                  null,
                  Icon(Icons.phone, color: Colors.grey[600]),
                  null,
                  _phoneController,
                  null,
                ),
                SizedBox(height: 10),
                _label("Email*"),
                _textFiled(
                  null,
                  Icon(Icons.email, color: Colors.grey[600]),
                  null,
                  _emailController,
                  null,
                ),
                SizedBox(height: 10),
                _label("Mật khẩu*"),
                _textFiled(
                  _obscureText1,
                  Icon(Icons.password, color: Colors.grey[600]),
                  null,
                  _passwordController1,
                  IconButton(
                    icon:
                        _obscureText1
                            ? Icon(
                              Icons.visibility_off,
                              color: Colors.grey[600],
                            )
                            : Icon(Icons.visibility, color: Colors.grey[600]),
                    onPressed: () {
                      //Thay đổi trạng thái ẩn hiện mật khẩu
                      ref.read(_obscureText1Provider.notifier).state =
                          !_obscureText1;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _label("Xác nhận mật khẩu*"),
                _textFiled(
                  _obscureText2,
                  Icon(Icons.password, color: Colors.grey[600]),
                  null,
                  _passwordController2,
                  IconButton(
                    icon:
                        _obscureText2
                            ? Icon(
                              Icons.visibility_off,
                              color: Colors.grey[600],
                            )
                            : Icon(Icons.visibility, color: Colors.grey[600]),
                    onPressed: () {
                      //Thay đổi trạng thái ẩn hiện mật khẩu
                      ref.read(_obscureText2Provider.notifier).state =
                          !_obscureText2;
                    },
                  ),
                ),
                SizedBox(height: 10),
                _label("Căn cước công dân*"),
                _getCCCD(),
                SizedBox(height: 30),
                _signinButton(context, ref),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Các widget
  //label
  Widget _label(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: Style.fontContent),
    );
  }

  //Textfield
  Widget _textFiled(
    bool? isObscureText,
    Icon icon,
    String? hintText,
    TextEditingController controller,
    IconButton? suffixIcon,
  ) {
    return ShadowCus(
      isConcave: true, // Concave effect for input
      borderRadius: 24.0,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        obscureText: isObscureText ?? false,
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon,
          hintText: hintText ?? '', // Use hintText instead of labelText
          hintStyle: const TextStyle(color: kTextColorLight),
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

  //Phần Lấy CCCD
  Widget _getCCCD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: ShadowCus(
              isConcave: true, // Concave effect for input
              borderRadius: 10.0,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.credit_card, color: Colors.grey[600]),
                  hintText: 'Số CCCD', // Use hintText
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
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // Handle button press
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Style.buttonBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          child: Text('Lấy CCCD', style: Style.TextButton),
        ),
      ],
    );
  }

  //Phần button tiếp tục
  Widget _signinButton(BuildContext context, WidgetRef ref) {
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
            Constrats.showThongBao(context, _emailController.text);
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
              isLoading ? Loading() : Text('Tiếp tục', style: Style.TextButton),
        ),
      ),
    );
  }
}
