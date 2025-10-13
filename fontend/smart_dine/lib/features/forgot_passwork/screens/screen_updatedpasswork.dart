import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/forgot_passwork/screens/screen_updated_success.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/icon_back.dart';

class ScreenUpdatedpasswork extends ConsumerStatefulWidget {
  const ScreenUpdatedpasswork({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ScreenUpdatedpassworkState();
  }
}

//Các Provider
final textPass1Provider = StateProvider<TextEditingController>(
  (ref) => TextEditingController(),
);
final textPass2Provider = StateProvider<TextEditingController>(
  (ref) => TextEditingController(),
);

final isCheckShow1Provider = StateProvider<bool>((ref) => true);
final isCheckShow2Provider = StateProvider<bool>((ref) => true);

class _ScreenUpdatedpassworkState extends ConsumerState<ScreenUpdatedpasswork> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar
      backgroundColor: Style.backgroundColor,
      appBar: AppBar(
        leading: IconBack.back(context),
        title: Text('Đặt lại mật khẩu', style: Style.fontTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      //Body
      body: _body(),
    );
  }

  //Phần body
  Widget _body() {
    final isCheckShow1 = ref.watch(isCheckShow1Provider);
    final isCheckShow2 = ref.watch(isCheckShow2Provider);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
            child: Column(
              children: [
                _dongChu(),
                const SizedBox(height: 30),
                ShadowCus(
                  isConcave: true, // Concave effect for input
                  borderRadius: 10.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: TextField(
                    obscureText: isCheckShow1, // Toggle visibility
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                      hintText: 'Mật khẩu', // Use hintText
                      hintStyle: const TextStyle(color: Style.textColorGray),
                      border: InputBorder.none, // Remove default border
                      contentPadding: const EdgeInsets.only(
                        left: 0,
                        top: 12,
                        bottom: 12,
                        right: 0,
                      ), // Adjust padding
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCheckShow1
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          ref.read(isCheckShow1Provider.notifier).state =
                              !isCheckShow1;
                        },
                      ),
                    ),
                    style: const TextStyle(color: Style.textColorGray),
                  ),
                ),
                const SizedBox(height: 15), // Space before buttons
                ShadowCus(
                  isConcave: true, // Concave effect for input
                  borderRadius: 10.0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: TextField(
                    obscureText: isCheckShow2, // Toggle visibility
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                      hintText: 'Xác nhận mật khẩu', // Use hintText
                      hintStyle: const TextStyle(color: Style.textColorGray),
                      border: InputBorder.none, // Remove default border
                      contentPadding: const EdgeInsets.only(
                        left: 0,
                        top: 12,
                        bottom: 12,
                        right: 0,
                      ), // Adjust padding
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCheckShow2
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          ref.read(isCheckShow2Provider.notifier).state =
                              !isCheckShow2;
                        },
                      ),
                    ),
                    style: const TextStyle(color: Style.textColorGray),
                  ),
                ),
                const SizedBox(height: 30),
                _buttonConfirm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Phần dòng chữ
  Widget _dongChu() {
    return Align(
      alignment: Alignment.centerLeft,
      child: const Text(
        'Mật khẩu càng mạnh độ bảo càng cao.',
        style: TextStyle(
          fontSize: Style.defaultFontSize,
          color: Style.textColorGray,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  //Phần button "Xác nhận"
  Widget _buttonConfirm() {
    return ShadowCus(
      borderRadius: 20.0,
      baseColor: Style.buttonBackgroundColor, // Button's distinct color
      padding: EdgeInsets.zero, // Padding handled by MaterialButton
      child: MaterialButton(
        onPressed: () {
          Routes.pushRightLeftConsumerLess(context, ScreenUpdatedSuccess());
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
        child: Text('Xác nhận', style: Style.TextButton),
      ),
    );
  }
}
