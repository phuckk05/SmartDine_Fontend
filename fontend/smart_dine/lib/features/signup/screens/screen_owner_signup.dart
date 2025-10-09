import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/widgets/loading.dart';

//Các state provider
final _isLoadingProvider = StateProvider<bool>((ref) => false);

final _imageProvider = StateProvider<File?>((ref) => null);

//Giao diện đăng kí chủ nhà hàng
class ScreenOwnerSignup extends ConsumerStatefulWidget {
  final String? title;
  const ScreenOwnerSignup({super.key, this.title});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScreenOwnerSignupState();
}

class _ScreenOwnerSignupState extends ConsumerState<ScreenOwnerSignup> {
  //Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();

  //Hàm lấy ảnh
  Future<void> _getImage(StateProvider<File?> _image) async {
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
  Widget build(BuildContext context) {
    //Xem các state
    // final _obscureText1 = ref.watch(_obscureText1Provider);
    // final _obscureText2 = ref.watch(_obscureText2Provider);

    //Build giao diện
    return Scaffold(
      appBar: AppBarCus(title: widget.title ?? ''),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
            child: Column(
              children: [
                SizedBox(height: 10),
                _label("Tên nhà hàng*"),
                _textFiled(
                  1,
                  null,
                  Icon(Icons.location_city, color: Colors.grey[600]),
                  null,
                  _nameController,
                  null,
                ),
                SizedBox(height: 10),
                _label("Địa chị*"),
                _textFiled(
                  2,
                  null,
                  Icon(Icons.local_attraction, color: Colors.grey[600]),
                  null,
                  _addressController,
                  null,
                ),
                SizedBox(height: 10),
                _label("Mã code nhà hàng*"),
                _textFiled(
                  3,
                  null,
                  Icon(Icons.code, color: Colors.grey[600]),
                  null,
                  _codeController,
                  null,
                ),
                SizedBox(height: 10),
                _label("Giấy phép kinh doanh*"),
                SizedBox(height: 10),
                _getCCCD(),
                SizedBox(height: 30),
                _note(),
                SizedBox(height: 30),
                _signinButton(context),
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

  //Note
  Widget _note() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          ' - Vui lòng nhập đúng thông tin nhà hàng của bạn !',
          style: Style.fontCaption,
        ),
        Text(' - Ghi nhớ mã code nhà hàng.', style: Style.fontCaption),
        Text(
          ' - Thời gian duyệt yêu cầu 1-2 ngày trừ các ngày lễ.',
          style: Style.fontCaption,
        ),
      ],
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
      ),
    );
  }

  //Phần Lấy CCCD
  Widget _getCCCD() {
    final _Image = ref.watch(_imageProvider);
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: InkWell(
          onTap: () {
            _getImage(_imageProvider);
          },
          child: Stack(
            children: [
              ShadowCus(
                isConcave: true, // Concave effect for input
                borderRadius: 10.0,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                        _Image == null
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Giấy phép kinh doanh",
                                  style: Style.fontContent,
                                ),
                                const Icon(Icons.add, color: Colors.grey),
                              ],
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(6.0),
                              child: Image.file(_Image, fit: BoxFit.fill),
                            ),
                  ),
                ),
              ),
              _Image == null
                  ? SizedBox()
                  : Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {
                        ref.read(_imageProvider.notifier).state = null;
                      },
                      icon: Icon(Icons.close, color: Colors.grey),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  //Phần button tiếp tục
  Widget _signinButton(BuildContext context) {
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
              isLoading ? Loading() : Text('Đăng kí', style: Style.TextButton),
        ),
      ),
    );
  }
}
