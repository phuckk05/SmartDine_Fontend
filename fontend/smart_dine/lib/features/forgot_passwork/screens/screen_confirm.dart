import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/verification_code_API.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/core/utils/email_sender.dart';
import 'package:mart_dine/core/utils/verification_code.dart';
import 'package:mart_dine/features/forgot_passwork/screens/screen_updatedpasswork.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/icon_back.dart';
import 'package:mart_dine/widgets/loading.dart';

final _confirmLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _confirmCodeValidProvider = StateProvider.autoDispose<bool?>(
  (ref) => null,
);
final _confirmSecondsProvider = StateProvider.autoDispose<int>((ref) => 60);

class ScreenConfirm extends ConsumerStatefulWidget {
  final String email;
  final int? userId;
  final int? index;
  const ScreenConfirm({
    super.key,
    required this.email,
    required this.userId,
    this.index,
  });

  @override
  ConsumerState<ScreenConfirm> createState() => _ScreenConfirmState();
}

class _ScreenConfirmState extends ConsumerState<ScreenConfirm> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    ref.read(_confirmLoadingProvider.notifier).state = false;
    ref.read(_confirmCodeValidProvider.notifier).state = null;
    ref.read(_confirmSecondsProvider.notifier).state = 60;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
    });
    _handleSubmit();
    _startTimer();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = widget.email;
    try {
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
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(_confirmLoadingProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconBack.back(context),
        title: Text('Xác nhận tài khoản', style: Style.fontTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Style.backgroundColor,
      body: Stack(children: [_body(ref), if (isLoading) const Loading()]),
    );
  }

  Widget _body(WidgetRef ref) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dongChu(),
                const SizedBox(height: 30),
                _textFiledCode(ref),
                const SizedBox(height: 20),
                _resendButton(ref),
                const SizedBox(height: 20),
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
      alignment: Alignment.center,
      child: SizedBox(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kiểm tra hộp thư ',
                style: TextStyle(
                  fontSize: Style.defaultFontSize,
                  color: Style.textColorGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.email} !',
                style: TextStyle(
                  fontSize: Style.defaultFontSize,
                  color: Style.textColorBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFiledCode(WidgetRef ref) {
    final codeStatus = ref.watch(_confirmCodeValidProvider);
    final borderColor =
        codeStatus == null
            ? Colors.grey.shade400
            : codeStatus
            ? Colors.green
            : Colors.red;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (value) {
                if (value.isKeyPressed(LogicalKeyboardKey.backspace) &&
                    index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              },
              child: TextField(
                textAlign: TextAlign.center,
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 20,
                  ),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty &&
                      index < 5 &&
                      int.tryParse(value) != null) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  final notifier = ref.read(_confirmCodeValidProvider.notifier);
                  if (notifier.state != null) {
                    notifier.state = null;
                  }
                },
                style: const TextStyle(
                  color: Style.textColorGray,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _resendButton(WidgetRef ref) {
    final secondsRemaining = ref.watch(_confirmSecondsProvider);
    final canResend = secondsRemaining == 0;
    final label =
        canResend ? 'Gửi lại mã' : 'Gửi lại mã (${secondsRemaining}s)';
    return ShadowCus(
      borderRadius: 20.0,
      baseColor: Colors.white,
      padding: EdgeInsets.zero,
      child: MaterialButton(
        onPressed: canResend ? _handleResend : null,
        color: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        disabledColor: Colors.transparent,
        splashColor: Colors.white.withOpacity(0.2),
        minWidth: double.infinity,
        height: 45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(label, style: Style.fontCaption),
      ),
    );
  }

  Widget _buttonConfirm() {
    return ShadowCus(
      borderRadius: 20.0,
      baseColor: Style.buttonBackgroundColor,
      padding: EdgeInsets.zero,
      child: MaterialButton(
        onPressed: _verifyCode,
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
    );
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      Constrats.showThongBao(context, 'Vui lòng nhập đủ 6 chữ số.');
      return;
    }

    final loadingNotifier = ref.read(_confirmLoadingProvider.notifier);
    loadingNotifier.state = true;
    try {
      final api = ref.read(verificationCodeApiProvider);
      final success = await api.verify(email: widget.email, code: code);
      if (!mounted) return;
      if (!success) {
        ref.read(_confirmCodeValidProvider.notifier).state = false;
        Constrats.showThongBao(
          context,
          'Mã xác minh không hợp lệ hoặc đã hết hạn.',
        );
        return;
      }
      ref.read(_confirmCodeValidProvider.notifier).state = true;
      if (!mounted) return;
      if (widget.index != null && widget.index == 1) {
        Navigator.pop(context, true);
      } else {
        Routes.pushRightLeftConsumerFul(
          context,
          ScreenUpdatedpasswork(
            userId: widget.userId ?? 0,
            email: widget.email,
          ),
        );
      }
    } finally {
      loadingNotifier.state = false;
    }
  }

  Future<void> _handleResend() async {
    final loadingNotifier = ref.read(_confirmLoadingProvider.notifier);
    loadingNotifier.state = true;
    try {
      final code = generateVerificationCode();
      final expiresAt = DateTime.now().add(const Duration(minutes: 5));
      final api = ref.read(verificationCodeApiProvider);
      final saved = await api.createCode(
        email: widget.email,
        code: code,
        expiresAt: expiresAt,
      );
      if (!mounted) return;
      if (!saved) {
        Constrats.showThongBao(
          context,
          'Không thể tạo mã mới, vui lòng thử lại.',
        );
        return;
      }

      final sender = ref.read(emailSenderProvider);
      final sent = await sender.sendVerificationEmail(
        recipient: widget.email,
        code: code,
      );
      if (!mounted) return;
      if (!sent) {
        Constrats.showThongBao(
          context,
          'Không thể gửi email xác minh. Vui lòng kiểm tra cấu hình và thử lại.',
        );
        return;
      }
      Constrats.showThongBao(context, 'Đã gửi lại mã xác minh.');
      _startTimer(reset: true);
    } finally {
      loadingNotifier.state = false;
    }
  }

  void _startTimer({bool reset = false}) {
    if (reset) {
      _timer?.cancel();
    }
    final secondsNotifier = ref.read(_confirmSecondsProvider.notifier);
    secondsNotifier.state = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final current = secondsNotifier.state;
      if (current <= 1) {
        timer.cancel();
        secondsNotifier.state = 0;
      } else {
        secondsNotifier.state = current - 1;
      }
    });
  }
}
