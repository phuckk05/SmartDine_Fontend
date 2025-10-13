import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/cloudinary_API.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/signup/screen_manager_signup.dart';
import 'package:mart_dine/features/signup/screen_owner_signup.dart';
import 'package:mart_dine/models/user.dart';
import 'package:mart_dine/providers/loading_provider.dart';
import 'package:mart_dine/providers/user_provider.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart';

//Các state provider
final _isCanPop = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final _obscureText1Provider = StateProvider.autoDispose<bool>((ref) => true);
final _obscureText2Provider = StateProvider.autoDispose<bool>((ref) => true);
final _fontImageProvider = StateProvider.autoDispose<File?>((ref) => null);
final _backImageProvider = StateProvider.autoDispose<File?>((ref) => null);
final _fontImageUrlProvider = StateProvider.autoDispose<String?>((ref) => null);
final _backImageUrlProvider = StateProvider.autoDispose<String?>((ref) => null);

//Giao diện đăng kí thông tin cá nhân
// ignore: must_be_immutable
class ScreenInformationSignup extends ConsumerStatefulWidget {
  final String? title;
  final int? index;
  const ScreenInformationSignup({super.key, this.title, this.index});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _ScreenInformationState();
  }
}

class _ScreenInformationState extends ConsumerState<ScreenInformationSignup> {
  //Cloudinary
  CloudinaryAPI cloudinaryAPI = CloudinaryAPI();
  //Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController1;
  late final TextEditingController _passwordController2;
  late final TextEditingController _codeBranchController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _passwordController1 = TextEditingController();
    _passwordController2 = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _codeBranchController = TextEditingController();
    super.initState();
  }

  //hàm signup staff
  Future<void> siginUpStaff(User user, BuildContext context) async {
    final register = await ref
        .read(userNotifierProvider.notifier)
        .signUp(user, _codeBranchController.text);
    if (register == 1) {
      ref.read(_isLoadingProvider.notifier).state = false;
      ref.read(isLoadingNotifierProvider.notifier).toggle();
      Constrats.showThongBao(context, 'Mã chi nhánh không đúng !');
    } else if (register == 2) {
      ref.read(_isLoadingProvider.notifier).state = false;
      ref.read(isLoadingNotifierProvider.notifier).toggle();
      Constrats.showThongBao(context, 'Đăng kí thành công !');
    } else if (register == 3) {
      ref.read(_isLoadingProvider.notifier).state = false;
      ref.read(isLoadingNotifierProvider.notifier).toggle();
      Constrats.showThongBao(context, 'Số điện thoại & email đã tồn tại !');
    } else {
      ref.read(_isLoadingProvider.notifier).state = false;
      ref.read(isLoadingNotifierProvider.notifier).toggle();
      Constrats.showThongBao(context, 'Đăng kí thất bại !');
    }
  }

  //Hàm check email
  bool isValidEmail(String? input) {
    if (input == null) return false;
    final email = input.trim();
    if (email.isEmpty) return false;
    // tổng độ dài tối đa 254, local-part tối đa 64,
    // cho phép ký tự thông dụng trong local-part: . + - _ và các ký tự hợp lệ theo RFC-ish
    final regex = RegExp(
      r"^(?=.{1,254}$)(?=.{1,64}@)[A-Za-z0-9!#$%&'*+/=?^_`{|}~.-]+"
      r"@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
      r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*\.[A-Za-z]{2,}$",
    );
    return regex.hasMatch(email);
  }

  //Hàm check value trước khi đăng kí
  Future<void> checkControllers(BuildContext context, User user) async {
    // Check passwords match (not just both non-empty)
    if (_passwordController1.text == _passwordController2.text) {
      if (_nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _codeBranchController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          ref.watch(_fontImageUrlProvider) != null &&
          ref.watch(_backImageUrlProvider) != null) {
        //Chuyển hướng đăng kí qua role khác
        if (_phoneController.text.length == 10) {
          if (isValidEmail(_emailController.text)) {
            if (_nameController.text.length > 1) {
              if (widget.index == 1) {
                Routes.pushRightLeftConsumerFul(
                  context,
                  ScreenOwnerSignup(title: "Đăng kí nhà hàng"),
                );
              } else if (widget.index == 2) {
                Routes.pushRightLeftConsumerFul(
                  context,
                  ScreenManagerSignup(title: "Đăng kí chi nhánh"),
                );
              } else {
                ref.read(isLoadingNotifierProvider.notifier).toggle();
                ref.read(_isCanPop.notifier).state = true;
                try {
                  await siginUpStaff(user, context);
                } catch (e) {
                  // Show server error message if any
                  final msg = e.toString();
                  Constrats.showThongBao(context, msg);
                } finally {
                  if (mounted) {
                    ref.read(isLoadingNotifierProvider.notifier).toggle();
                    ref.read(_isCanPop.notifier).state = false;
                  }
                }
              }
            } else {
              Constrats.showThongBao(context, "Tên quá ngắn !");
            }
          } else {
            Constrats.showThongBao(context, "email chưa đúng định dạng !");
          }
        } else {
          Constrats.showThongBao(
            context,
            "Số điện thoại chưa đúng định dạng !",
          );
        }
      } else {
        Constrats.showThongBao(context, "Vui lòng nhập đủ thông tin !");
      }
    } else {
      Constrats.showThongBao(context, "Mật khẩu không đúng !");
    }
  }

  //Hàm lấy ảnh
  Future<void> _getCCCDImage(
    AutoDisposeStateProvider<File?> image,
    AutoDisposeStateProvider<String?> imageUrl,
    BuildContext context,
  ) async {
    //Khia báo
    final ImagePicker picker = ImagePicker();
    //Lấy ảnh
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      //Cập nhật state
      final changeImage = File(pickedFile.path);
      ref.read(image.notifier).state = File(pickedFile.path);
      _changeUrl(imageUrl, changeImage, ref, context);
      ref.read(isLoadingNotifierProvider.notifier).toggle();
      ref.read(_isCanPop.notifier).state = false;
    }
  }

  //Chuyển đổi ành
  Future<void> _changeUrl(
    AutoDisposeStateProvider<String?> image,
    File? file,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final result = await cloudinaryAPI.getURL(file);

    if (!mounted) return;

    if (result != "0") {
      ref.read(image.notifier).state = result;
      if (ref.watch(image) != null) {
        ref.read(isLoadingNotifierProvider.notifier).toggle();
      }
    } else {
      Constrats.showThongBao(context, "Lỗi chọn ảnh");
    }
  }

  @override
  void dispose() {
    _codeBranchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController1.dispose();
    _emailController.dispose();
    _passwordController2.dispose();

    // reset lại state khi thoát
    if (!mounted) {
      ref.read(isLoadingNotifierProvider.notifier).toggle();
      ref.read(_isCanPop.notifier).state = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Xem các state
    final _obscureText1 = ref.watch(_obscureText1Provider);
    final _obscureText2 = ref.watch(_obscureText2Provider);
    //Build giao diện
    return PopScope(
      canPop: ref.watch(_isCanPop),
      child: Scaffold(
        appBar: AppBarCus(
          title: widget.title ?? '',
          isCanpop: ref.watch(_isCanPop),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Style.paddingPhone,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      _label("Họ và tên*"),
                      _textFiled(
                        2,
                        null,
                        Icon(Icons.person, color: Colors.grey[600]),
                        null,
                        _nameController,
                        null,
                      ),
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
                                  : Icon(
                                    Icons.visibility,
                                    color: Colors.grey[600],
                                  ),
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
                                  : Icon(
                                    Icons.visibility,
                                    color: Colors.grey[600],
                                  ),
                          onPressed: () {
                            //Thay đổi trạng thái ẩn hiện mật khẩu
                            ref.read(_obscureText2Provider.notifier).state =
                                !_obscureText2;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      widget.index == 3
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
                      _getCCCD(ref, context),
                      SizedBox(height: 30),
                      widget.index == 3 ? _note() : SizedBox(),
                      SizedBox(height: 30),
                      _signinButton(context, ref),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              ref.watch(isLoadingNotifierProvider)
                  ? Positioned.fill(child: Loading(index: 1))
                  : SizedBox(),
            ],
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
  Widget _getCCCD(WidgetRef ref, BuildContext context) {
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
                _getCCCDImage(
                  _fontImageProvider,
                  _fontImageUrlProvider,
                  context,
                );
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
                _getCCCDImage(
                  _backImageProvider,
                  _backImageUrlProvider,
                  context,
                );
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
                                    Text("Mặt sau", style: Style.fontContent),
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
        Text(
          ' - Vui lòng nhập đúng thông tin của bạn !',
          style: Style.fontCaption,
        ),
        Text(
          ' - Mã code chi nhánh có từ quản lý chi nhánh.',
          style: Style.fontCaption,
        ),
      ],
    );
  }

  //Phần button tiếp tục
  Widget _signinButton(BuildContext context, WidgetRef ref) {
    // final userProvider = ref.watch(userNotifierProvider);
    final isLoading = ref.watch(_isLoadingProvider);
    final _fontImageUrl = ref.watch(_fontImageUrlProvider);
    final _backImageUrl = ref.watch(_backImageUrlProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: ShadowCus(
        borderRadius: 20.0,
        baseColor: Style.buttonBackgroundColor, // Button's distinct color
        padding: EdgeInsets.zero, // Padding handled by MaterialButton
        child: MaterialButton(
          onPressed: () {
            //User
            User user = User.create(
              fullName: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              password: _passwordController1.text,
              statusId: 3,
              fontImage: _fontImageUrl ?? "Chưa có",
              backImage: _backImageUrl ?? "Chưa có",
            );
            //Hàm đăng kí phục vụ
            checkControllers(context, user);
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
                  ? Loading(index: 0)
                  : widget.index == 3
                  ? Text('Đăng kí', style: Style.TextButton)
                  : Text('Tiếp tục', style: Style.TextButton),
        ),
      ),
    );
  }
}
