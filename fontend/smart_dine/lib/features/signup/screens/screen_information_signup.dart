import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/signup/screens/screen_manager_signup.dart';
import 'package:mart_dine/features/signup/screens/screen_owner_signup.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';

//Các state provider
final _isLoadingProvider = StateProvider<bool>((ref) => false);
final _obscureText1Provider = StateProvider<bool>((ref) => true);
final _obscureText2Provider = StateProvider<bool>((ref) => true);

final _fontImageProvider = StateProvider<File?>((ref) => null);
final _backImageProvider = StateProvider<File?>((ref) => null);

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
  final TextEditingController _codeBranchController = TextEditingController();

  //Hàm lấy ảnh
  Future<void> _getCCCDImage(StateProvider<File?> _image, WidgetRef ref) async {
    //Khia báo
    final ImagePicker picker = ImagePicker();
    //Lấy ảnh
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      //Cập nhật state
      ref.read(_image.notifier).state = File(pickedFile.path);
    }
  }

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
                SizedBox(height: 10),
                _label("Số điện thoại*"),
                _textFiled(
                  1,
                  null,
                  Icon(Icons.phone, color: Colors.grey[600]),
                  null,
                  _phoneController,
                  null,
                ),
                SizedBox(height: 10),
                _label("Email*"),
                _textFiled(
                  2,
                  null,
                  Icon(Icons.email, color: Colors.grey[600]),
                  null,
                  _emailController,
                  null,
                ),
                SizedBox(height: 10),
                _label("Mật khẩu*"),
                _textFiled(
                  3,
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
                  4,
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
                index == 3
                    ? Column(
                      children: [
                        _label("Nhập mã code chi nhánh*"),
                        _textFiled(
                          5,
                          null,
                          Icon(Icons.code, color: Colors.grey[600]),
                          null,
                          _codeBranchController,
                          null,
                        ),
                        SizedBox(height: 10),
                      ],
                    )
                    : SizedBox(),
                _label("Căn cước công dân*"),
                _getCCCD(ref),
                SizedBox(height: 30),
                index == 3 ? _note() : SizedBox(),
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
        keyboardType:
            index == 1
                ? TextInputType.phone
                : index == 2
                ? TextInputType.emailAddress
                : TextInputType.text,
        inputFormatters:
            index == 1
                ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ]
                : [FilteringTextInputFormatter.singleLineFormatter],
      ),
    );
  }

  //Phần Lấy CCCD
  Widget _getCCCD(WidgetRef ref) {
    final _fontImage = ref.watch(_fontImageProvider);
    final _backImage = ref.watch(_backImageProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: InkWell(
              onTap: () {
                _getCCCDImage(_fontImageProvider, ref);
              },
              child: Stack(
                children: [
                  ShadowCus(
                    isConcave: true, // Concave effect for input
                    borderRadius: 10.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    child: DottedBorder(
                      color: Colors.grey, // màu viền
                      strokeWidth: 1, // độ dày nét
                      dashPattern: [6, 3], // chiều dài nét + khoảng trống
                      borderType: BorderType.RRect, // bo tròn góc
                      radius: const Radius.circular(6),
                      child: Container(
                        width: 200,
                        height: 100,
                        alignment: Alignment.center,
                        child:
                            _fontImage == null
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Mặt trước", style: Style.fontContent),
                                    const Icon(Icons.add, color: Colors.grey),
                                  ],
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child: Image.file(
                                    _fontImage,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  _fontImage == null
                      ? SizedBox()
                      : Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            ref.read(_fontImageProvider.notifier).state = null;
                          },
                          icon: Icon(Icons.close, color: Colors.grey),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: InkWell(
              onTap: () {
                _getCCCDImage(_backImageProvider, ref);
              },
              child: Stack(
                children: [
                  ShadowCus(
                    isConcave: true, // Concave effect for input
                    borderRadius: 10.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    child: DottedBorder(
                      color: Colors.grey, // màu viền
                      strokeWidth: 1, // độ dày nét
                      dashPattern: [6, 3], // chiều dài nét + khoảng trống
                      borderType: BorderType.RRect, // bo tròn góc
                      radius: const Radius.circular(6),
                      child: Container(
                        width: 200,
                        height: 100,
                        alignment: Alignment.center,
                        child:
                            _backImage == null
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Mặt trước", style: Style.fontContent),
                                    const Icon(Icons.add, color: Colors.grey),
                                  ],
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child: Image.file(
                                    _backImage,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                      ),
                    ),
                  ),
                  _backImage == null
                      ? SizedBox()
                      : Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            ref.read(_backImageProvider.notifier).state = null;
                          },
                          icon: Icon(Icons.close, color: Colors.grey),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  //Note
  Widget _note() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(' - Vui lòng nhập đúng thông của bạn !', style: Style.fontCaption),
        Text(
          ' - Mã code chi nhánh có từ quản lý chi nhánh.',
          style: Style.fontCaption,
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
          onPressed: () async {
            ref.read(_isLoadingProvider.notifier).state = true;
            await Future.delayed(
              Duration(seconds: 5),
              () => ref.read(_isLoadingProvider.notifier).state = false,
            );
            if (index == 1) {
              Routes.pushRightLeftConsumerFul(
                // ignore: use_build_context_synchronously
                context,
                ScreenOwnerSignup(title: "Đăng kí nhà hàng"),
              );
            } else if (index == 2) {
              Routes.pushRightLeftConsumerFul(
                // ignore: use_build_context_synchronously
                context,
                ScreenManagerSignup(title: "Đăng kí chi nhánh"),
              );
            }
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
                  : index == 3
                  ? Text('Đăng kí', style: Style.TextButton)
                  : Text('Tiếp tục', style: Style.TextButton),
        ),
      ),
    );
  }
}
