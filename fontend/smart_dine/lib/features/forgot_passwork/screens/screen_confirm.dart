import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/forgot_passwork/screens/screen_updatedpasswork.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/icon_back.dart';

class ScreenConfirm extends ConsumerStatefulWidget {
  final String? email;
  const ScreenConfirm({super.key, this.email});
  @override
  ConsumerState<ScreenConfirm> createState() => _ScreenConfirmState();
}

//Các provider để quản lý trạng thái
final textCodeEditTextProvider = StateProvider<TextEditingController>(
  (ref) => TextEditingController(),
);
final isCheckvalueProvider = StateProvider<bool>((ref) => false);

class _ScreenConfirmState extends ConsumerState<ScreenConfirm> {
  //Các biến

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  //Initialize state
  @override
  void initState() {
    //Gọi sau khi build xong để focus vào trường đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
    super.initState();
  }

  //Dispose các controller và focus node
  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Appbar
      appBar: AppBar(
        leading: IconBack.back(context),
        title: Text('Xác nhận tài khoản', style: Style.fontTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      //Background color
      backgroundColor: Style.backgroundColor,

      //Body
      body: _body(),
    );
  }

  //Body
  Widget _body() {
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
                _textFiledCode(),
                const SizedBox(height: 30),
                _buttonConfirm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Dòng chữ
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                'Kiểm tra hộp thư ',
                style: TextStyle(
                  fontSize: Style.defaultFontSize,
                  color: Style.textColorGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

  //Textflied "Nhập mã"
  Widget _textFiledCode() {
    final isCheck = ref.watch(isCheckvalueProvider);
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
                //Sử lý sự kiện khi người dùng nhấn nút xóa
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
                decoration: InputDecoration(
                  counterText: "",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 20,
                  ),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isCheck ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  // If the input is not empty, move to the next field
                  if (value.isNotEmpty &&
                      index < 5 &&
                      int.tryParse(value) != null) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    // If the input is empty, move back to the previous field
                    _focusNodes[index - 1].requestFocus();
                  }
                  // Update the textCode provider with the current input
                  String code = _controllers.map((c) => c.text).join();
                  ref.read(textCodeEditTextProvider.notifier).state.text = code;
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

  //Nút button xác nhânj

  Widget _buttonConfirm() {
    return ShadowCus(
      borderRadius: 20.0,
      baseColor: Style.buttonBackgroundColor, // Button's distinct color
      padding: EdgeInsets.zero, // Padding handled by MaterialButton
      child: MaterialButton(
        onPressed: () {
          Routes.pushRightLeftConsumerFul(context, ScreenUpdatedpasswork());
        },

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
    );
  }
}
