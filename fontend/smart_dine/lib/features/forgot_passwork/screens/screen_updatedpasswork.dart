import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/forgot_passwork/screens/screen_updated_success.dart';
import 'package:mart_dine/providers/user_provider.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/icon_back.dart';
import 'package:mart_dine/widgets/loading.dart';

final _resetLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _resetObscurePasswordProvider = StateProvider.autoDispose<bool>(
  (ref) => true,
);
final _resetObscureConfirmProvider = StateProvider.autoDispose<bool>(
  (ref) => true,
);

class ScreenUpdatedpasswork extends ConsumerStatefulWidget {
  final int userId;
  final String email;
  const ScreenUpdatedpasswork({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  ConsumerState<ScreenUpdatedpasswork> createState() =>
      _ScreenUpdatedpassworkState();
}

class _ScreenUpdatedpassworkState extends ConsumerState<ScreenUpdatedpasswork> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_resetLoadingProvider);
    final obscurePassword = ref.watch(_resetObscurePasswordProvider);
    final obscureConfirm = ref.watch(_resetObscureConfirmProvider);

    return Scaffold(
      backgroundColor: Style.backgroundColor,
      appBar: AppBar(
        leading: IconBack.back(context),
        title: Text('Đặt lại mật khẩu', style: Style.fontTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          _buildBody(
            obscurePassword: obscurePassword,
            obscureConfirm: obscureConfirm,
          ),
          if (isLoading) const Loading(),
        ],
      ),
    );
  }

  Widget _buildBody({
    required bool obscurePassword,
    required bool obscureConfirm,
  }) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _dongChu(),
                const SizedBox(height: 30),
                _passwordField(
                  controller: _passwordController,
                  hint: 'Mật khẩu mới',
                  obscure: obscurePassword,
                  onToggle: _togglePasswordVisibility,
                ),
                const SizedBox(height: 15),
                _passwordField(
                  controller: _confirmController,
                  hint: 'Xác nhận mật khẩu',
                  obscure: obscureConfirm,
                  onToggle: _toggleConfirmVisibility,
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

  Widget _dongChu() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tài khoản: ${widget.email}', style: Style.fontCaption),
          const SizedBox(height: 6),
          Text(
            'Mật khẩu càng mạnh độ bảo càng cao.',
            style: TextStyle(
              fontSize: Style.defaultFontSize,
              color: Style.textColorGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return ShadowCus(
      isConcave: true,
      borderRadius: 10.0,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
          hintText: hint,
          hintStyle: const TextStyle(color: Style.textColorGray),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(
            left: 0,
            top: 12,
            bottom: 12,
            right: 0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: onToggle,
          ),
        ),
        style: const TextStyle(color: Style.textColorGray),
      ),
    );
  }

  Widget _buttonConfirm() {
    return ShadowCus(
      borderRadius: 20.0,
      baseColor: Style.buttonBackgroundColor,
      padding: EdgeInsets.zero,
      child: MaterialButton(
        onPressed: _handleUpdatePassword,
        color: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        splashColor: Colors.white.withOpacity(0.2),
        minWidth: double.infinity,
        height: 50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text('Xác nhận', style: Style.TextButton),
      ),
    );
  }

  Future<void> _handleUpdatePassword() async {
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Constrats.showThongBao(context, 'Vui lòng nhập đầy đủ mật khẩu.');
      return;
    }
    if (newPassword.length < 6) {
      Constrats.showThongBao(context, 'Mật khẩu cần ít nhất 6 ký tự.');
      return;
    }
    if (newPassword != confirmPassword) {
      Constrats.showThongBao(context, 'Mật khẩu xác nhận không khớp.');
      return;
    }

    final loadingNotifier = ref.read(_resetLoadingProvider.notifier);
    loadingNotifier.state = true;
    try {
      final updated = await ref
          .read(userNotifierProvider.notifier)
          .updateUserInfor(widget.userId, newPassword);
      if (!mounted) return;
      if (!updated) {
        Constrats.showThongBao(
          context,
          'Không thể cập nhật mật khẩu. Vui lòng thử lại.',
        );
        return;
      }
      Routes.pushRightLeftConsumerLess(context, const ScreenUpdatedSuccess());
    } finally {
      loadingNotifier.state = false;
    }
  }

  void _togglePasswordVisibility() {
    final notifier = ref.read(_resetObscurePasswordProvider.notifier);
    notifier.state = !notifier.state;
  }

  void _toggleConfirmVisibility() {
    final notifier = ref.read(_resetObscureConfirmProvider.notifier);
    notifier.state = !notifier.state;
  }
}
