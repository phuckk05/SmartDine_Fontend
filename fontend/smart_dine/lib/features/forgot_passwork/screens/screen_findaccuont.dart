import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/user_API.dart';
import 'package:mart_dine/API/verification_code_API.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/core/utils/email_sender.dart';
import 'package:mart_dine/core/utils/verification_code.dart';
import 'package:mart_dine/features/forgot_passwork/screens/screen_confirm.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/widgets/loading.dart';

final _findAccountLoadingProvider = StateProvider.autoDispose<bool>(
  (ref) => false,
);

class ScreenFindaccuont extends ConsumerStatefulWidget {
  const ScreenFindaccuont({super.key});

  @override
  ConsumerState<ScreenFindaccuont> createState() => _ScreenFindaccuontState();
}

class _ScreenFindaccuontState extends ConsumerState<ScreenFindaccuont> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_findAccountLoadingProvider);
    return Scaffold(
      appBar: AppBarCus(
        title: 'Tìm tài khoản',
        isCanpop: true,
        isButtonEnabled: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.paddingPhone,
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Nhập địa chỉ email của bạn'),
                      _textFiled(
                        null,
                        Icon(Icons.email),
                        null,
                        _emailController,
                        null,
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _signinButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading) const Loading(),
        ],
      ),
    );
  }

  Widget _signinButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ShadowCus(
        borderRadius: 20.0,
        baseColor: Style.buttonBackgroundColor,
        padding: EdgeInsets.zero,
        child: MaterialButton(
          onPressed: _handleSubmit,
          color: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          splashColor: Colors.white.withOpacity(0.2),
          minWidth: double.infinity,
          height: 50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text('Tiếp tục', style: Style.TextButton),
        ),
      ),
    );
  }

  Widget _label(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: Style.fontContent),
    );
  }

  Widget _textFiled(
    bool? isObscureText,
    Icon icon,
    String? hintText,
    TextEditingController controller,
    IconButton? suffixIcon,
  ) {
    return ShadowCus(
      isConcave: true,
      borderRadius: 10.0,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        obscureText: isObscureText ?? false,
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          prefixIcon: icon,
          hintText: hintText ?? '',
          hintStyle: const TextStyle(color: Style.textColorGray),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(
            left: 0,
            top: 12,
            bottom: 12,
            right: 0,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Constrats.showThongBao(context, 'Vui lòng nhập email.');
      return;
    }
    if (!EmailValidator.validate(email)) {
      Constrats.showThongBao(context, 'Định dạng email không hợp lệ.');
      return;
    }

    ref.read(_findAccountLoadingProvider.notifier).state = true;
    try {
      final user = await ref.read(userApiProvider).signIn(email);
      if (!mounted) return;
      if (user == null || user.id == null) {
        Constrats.showThongBao(
          context,
          'Không tìm thấy tài khoản với email này.',
        );
        return;
      }

      final code = generateVerificationCode();
      final expiresAt = DateTime.now().add(const Duration(minutes: 5));
      final verificationApi = ref.read(verificationCodeApiProvider);
      final saved = await verificationApi.createCode(
        email: email,
        code: code,
        expiresAt: expiresAt,
      );
      if (!mounted) return;

      if (!saved) {
        Constrats.showThongBao(
          context,
          'Không thể tạo mã xác minh, vui lòng thử lại.',
        );
        return;
      }

      final sender = ref.read(emailSenderProvider);
      final sent = await sender.sendVerificationEmail(
        recipient: email,
        code: code,
      );
      if (!mounted) return;
      if (!sent) {
        Constrats.showThongBao(
          context,
          'Không thể gửi email xác minh. Vui lòng kiểm tra lại cấu hình hoặc thử lại sau.',
        );
      } else {
        Constrats.showThongBao(
          context,
          'Đã gửi mã xác minh, vui lòng kiểm tra email.',
        );
      }

      if (!mounted) return;
      Routes.pushRightLeftConsumerFul(
        context,
        ScreenConfirm(email: email, userId: user.id!),
      );
    } finally {
      ref.read(_findAccountLoadingProvider.notifier).state = false;
    }
  }
}
