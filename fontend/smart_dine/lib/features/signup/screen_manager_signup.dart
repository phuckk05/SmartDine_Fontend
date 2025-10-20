import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mart_dine/API/cloudinary_API.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/signin/screen_signin.dart';
import 'package:mart_dine/models/branch.dart';
import 'package:mart_dine/providers/branch_provider.dart';
import 'package:mart_dine/providers/internet_provider.dart';
import 'package:mart_dine/providers/loading_provider.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/widgets/loading.dart';

//Các state provider

final _isCanPop = StateProvider.autoDispose<bool>((ref) => false);
final _isLoadingProvider = StateProvider<bool>((ref) => false);

final _imageProvider = StateProvider.autoDispose<File?>((ref) => null);
final _imageUrlProvider = StateProvider.autoDispose<String>((ref) => "");

//Giao diện đăng kí chủ nhà hàng
class ScreenManagerSignup extends ConsumerStatefulWidget {
  final String? title;
  final int userId;

  // final User user;
  const ScreenManagerSignup({super.key, this.title, required this.userId});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScreenManagerSignupState();
}

class _ScreenManagerSignupState extends ConsumerState<ScreenManagerSignup> {
  //cloudinaryAPI
  CloudinaryAPI cloudinaryAPI = CloudinaryAPI();
  //Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _codeRestaurantController =
      TextEditingController();

  //Hàm lấy ảnh
  Future<void> _getCCCDImage(
    AutoDisposeStateProvider<File?> image,
    AutoDisposeStateProvider<String?> imageUrl,
    BuildContext context,
  ) async {
    if (!ref.watch(internetProvider)) {
      Constrats.showThongBao(context, "Không có internet !");
    } else {
      //Khia báo
      final ImagePicker picker = ImagePicker();
      //Lấy ảnh
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        //Cập nhật state
        final changeImage = File(pickedFile.path);
        ref.read(image.notifier).state = File(pickedFile.path);
        ref.read(isLoadingNotifierProvider.notifier).toggle(true);
        await _changeUrl(changeImage, context);
        if (!mounted) {
          return;
        }
        ref.read(_isCanPop.notifier).state = false;
        ref.read(isLoadingNotifierProvider.notifier).toggle(false);
      }
    }
  }

  //Chuyển đổi ành
  Future<void> _changeUrl(File? file, BuildContext context) async {
    final result = await cloudinaryAPI.getURL(file);
    if (result != "0") {
      ref.read(_imageUrlProvider.notifier).state = result.toString();
      print("anh day :${result}");
      print(ref.watch(_imageUrlProvider));
    } else {
      Constrats.showThongBao(context, "Lỗi chọn ảnh");
    }
  }

  //hàm signup staff
  Future<void> siginUpBranch(Branch branch, BuildContext context) async {
    final register = await ref
        .read(branchNotifierProvider.notifier)
        .signUpBranch(branch, widget.userId, _codeRestaurantController.text);
    if (register == 0) {
      Constrats.showThongBao(context, 'Đăng kí chi nhánh thất bại !');
    } else if (register == 2) {
      Constrats.showThongBao(context, 'Mã nhà hàng không đúng !');
    } else {
      Constrats.showThongBao(
        context,
        'Đăng kí thành công ,đợi chủ nhà hàng duyệt !',
      );
      await Future.delayed(Duration(seconds: 4));
      if (!mounted) {
        return;
      }
      Routes.pushAndRemoveUntil(context, ScreenSignIn());
    }
  }

  //Hàm check value trước khi đăng kí
  Future<void> checkControllers(BuildContext context, Branch branch) async {
    if (!ref.watch(internetProvider)) {
      Constrats.showThongBao(context, "Không có internet !");
    } else {
      final _imageUrl = ref.watch(_imageUrlProvider);
      print("url image : $_imageUrl");
      if (_nameController.text.isNotEmpty &&
          _addressController.text.isNotEmpty &&
          _codeController.text.isNotEmpty &&
          _codeRestaurantController.text.isNotEmpty &&
          _imageUrl.isNotEmpty) {
        //Chuyển hướng đăng kí qua role khác
        ref.read(isLoadingNotifierProvider.notifier).toggle(true);
        await siginUpBranch(branch, context);
        if (!mounted) {
          return;
        }
        ref.read(isLoadingNotifierProvider.notifier).toggle(false);
      } else {
        Constrats.showThongBao(context, "Vui lòng nhập đủ thông tin !");
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _codeController.dispose();
    _codeRestaurantController.dispose();
    // reset lại state khi thoát
    ref.read(isLoadingNotifierProvider.notifier).toggle(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Xem các state
    // final _obscureText1 = ref.watch(_obscureText1Provider);
    // final _obscureText2 = ref.watch(_obscureText2Provider);

    //Build giao diện
    return Scaffold(
      appBar: AppBarCus(
        title: widget.title ?? '',
        isCanpop: false,
        isButtonEnabled: false,
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
                    _label("Vui lòng nhập code nhà hàng*"),
                    _textFiled(
                      1,
                      null,
                      Icon(Icons.code, color: Colors.grey[600]),
                      null,
                      _codeRestaurantController,
                      null,
                    ),
                    SizedBox(height: 10),
                    _label("Tên chi nhánh nhà hàng*"),
                    _textFiled(
                      2,
                      null,
                      Icon(Icons.location_city, color: Colors.grey[600]),
                      null,
                      _nameController,
                      null,
                    ),
                    SizedBox(height: 10),
                    _label("Địa chị*"),
                    _textFiled(
                      3,
                      null,
                      Icon(Icons.local_attraction, color: Colors.grey[600]),
                      null,
                      _addressController,
                      null,
                    ),
                    SizedBox(height: 10),
                    _label("Mã code chi nhánh*"),
                    _textFiled(
                      4,
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
            ref.watch(isLoadingNotifierProvider)
                ? Positioned.fill(child: Loading(index: 1))
                : SizedBox(),
          ],
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
          ' - Vui lòng nhập đúng thông tin chi nhánh của bạn !',
          style: Style.fontCaption,
        ),
        Text(' - Ghi nhớ mã code chi nhánh.', style: Style.fontCaption),
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
            _getCCCDImage(_imageProvider, _imageUrlProvider, context);
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
            Branch branch = Branch.create(
              companyId: widget.userId,
              name: _nameController.text,
              branchCode: _codeController.text,
              address: _addressController.text,
              image: ref.watch(_imageUrlProvider),
              managerId: widget.userId,
            );
            checkControllers(context, branch);
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
                  ? Loading(index: 1)
                  : Text('Đăng kí', style: Style.TextButton),
        ),
      ),
    );
  }
}
