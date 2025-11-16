// import 'package:email_validator/email_validator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/bottom_Navigation/bottom_navigation.dart';
import 'package:mart_dine/features/forgot_passwork/screens/screen_findaccuont.dart';
import 'package:mart_dine/features/signup/screen_select_signup.dart';
// import 'package:mart_dine/features/staff/screen_choose_table.dart'; // Tạm ẩn
import 'package:mart_dine/features/branch_management/screen/branch_navigation.dart';
import 'package:mart_dine/providers/branch_provider.dart';
import 'package:mart_dine/providers/loading_provider.dart';
import 'package:mart_dine/providers/user_provider.dart';
import 'package:mart_dine/providers/user_session_provider.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/loading.dart';

class ScreenSignIn extends ConsumerStatefulWidget {
  const ScreenSignIn({super.key});
  @override
  ConsumerState<ScreenSignIn> createState() => _ScreenSignInState();
}

final _obscureText = StateProvider<bool>((ref) => true);
final _isLoadingProvider = StateProvider<bool>((ref) => false);

class _ScreenSignInState extends ConsumerState<ScreenSignIn> {
  // final Constrats constrats = Constrats();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  //Hàm load
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  //Hàm check email
  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  //Hàm sigin
  void toSignIn() async {
    // if (isValidEmail(_emailController.text) == false) {
    //   Constrats.showThongBao(context, 'Vui lòng nhập đúng định dạng email.');
    //   return;
    // }
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Constrats.showThongBao(
        context,
        'Vui lòng nhập đầy đủ thông tin đăng nhập.',
      );
      return;
    }

    ref.read(isLoadingNotifierProvider.notifier).toggle(true);
    final user = await ref
        .watch(userNotifierProvider.notifier)
        .signInInfor(_emailController.text, _passwordController.text);

    if (user != null) {
      // Kiểm tra trạng thái tài khoản
      if (user.statusId == 3) {
        // Chờ duyệt
        Constrats.showThongBao(
          context,
          'Tài khoản của bạn chưa được duyệt. Vui lòng chờ admin phê duyệt.',
        );
        ref.read(isLoadingNotifierProvider.notifier).toggle(false);
        return;
      } else if (user.statusId == 2) {
        //Không hoạt động
        Constrats.showThongBao(
          context,
          'Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ admin.',
        );
        ref.read(isLoadingNotifierProvider.notifier).toggle(false);
        return;
      } else if (user.statusId == 1) {
        // Đã duyệt
        // Kiểm tra role và hiển thị thông tin
        String roleName = '';
        int? branchId;
        switch (user.role) {
          case 1:
            roleName = 'Administrator';
            // Admin không cần branchId cụ thể
            break;
          case 2:
            roleName = 'Manager';
            // Manager: tìm chi nhánh mà user này là manager (manager_id trong bảng branches)
            branchId = await ref
                .read(branchNotifierProvider.notifier)
                .getBranchIdByManagerId(user.id as int);

            break;
          case 3:
            roleName = 'Staff';
            // Staff: tìm trong bảng user_branches
            branchId = await ref
                .read(branchNotifierProvider.notifier)
                .getBranchIdByUserId(user.id as int);

            break;
          case 4:
            roleName = 'Chef';
            // Chef: tìm trong bảng user_branches
            branchId = await ref
                .read(branchNotifierProvider.notifier)
                .getBranchIdByUserId(user.id as int);

            break;
          case 5:
            roleName = 'Owner';
            // Owner không cần branchId cụ thể hoặc có thể truy cập tất cả
            break;
          default:
            roleName = 'Staff';
            branchId = await ref
                .read(branchNotifierProvider.notifier)
                .getBranchIdByUserId(user.id as int);
            break;
        }



        // Lưu user session cho branch management
        await ref
            .read(userSessionProvider.notifier)
            .login(
              userId: user.id ?? 0,
              userName: user.fullName,
              userRole: user.role ?? 3,
              companyId: user.companyId,
              branchIds: branchId != null ? [branchId] : [],
              defaultBranchId: branchId,
            );



        Constrats.showThongBao(
          context,
          'Đăng nhập thành công!\nVai trò: $roleName ${branchId != null ? "- Chi nhánh: $branchId" : ""}',
        );

        // Điều hướng dựa theo role
        if (user.role == 1) {
          // Admin
          Routes.pushRightLeftConsumerFul(
            context,
            const ScreenBottomNavigation(index: 2),
          );
        } else if (user.role == 2) {
          // Manager -> Màn hình quản lý chi nhánh
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BranchManagementNavigation(),
            ),
          );
        } else if (user.role == 3) {
          // Staff -> Tạm thời chuyển về Bottom Navigation (có thể thay đổi sau)
          Constrats.showThongBao(
            context,
            'Chức năng nhân viên đang được phát triển. Chuyển về màn hình chính.',
          );
          
          // Tạm thời chuyển về bottom navigation với index 0 (Home)
          Routes.pushRightLeftConsumerFul(
            context,
            const ScreenBottomNavigation(index: 0),
          );

          /* TODO: Sẽ mở lại khi có màn hình chọn bàn
          // Try to resolve companyId from branchId if available
          int? companyId;
          if (branchId != null) {
            final cid = await ref
                .read(branchNotifierProvider.notifier)
                .getCompanyIdByBranchId(branchId);
            if (cid != null) companyId = cid;
          }

          Routes.pushRightLeftConsumerFul(
            context,
            ScreenChooseTable(
              branchId: branchId ?? 0,
              userId: user.id ?? 0,
              companyId: companyId ?? 0,
            ),
          );
          */
        } else if (user.role == 4) {
          // Chef
          Routes.pushRightLeftConsumerFul(
            context,
            const ScreenBottomNavigation(index: 1),
          );
        } else if (user.role == 5) {
          // Owner -> Chuyển về Bottom Navigation với quyền admin
          Routes.pushRightLeftConsumerFul(
            context,
            const ScreenBottomNavigation(index: 2),
          );
        } else {
          // Default fallback cho các role không xác định
          Constrats.showThongBao(
            context,
            'Vai trò không xác định. Chuyển về màn hình chính.',
          );
          Routes.pushRightLeftConsumerFul(
            context,
            const ScreenBottomNavigation(index: 0),
          );
        }
      } 
    }
    else {
        Constrats.showThongBao(
          context,
          'Đăng nhập không thành công. Vui lòng kiểm tra lại email và mật khẩu.',
        );
      }
      ref.read(isLoadingNotifierProvider.notifier).toggle(false);
  }

  //Hàm dispose
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Background color
      backgroundColor: Style.backgroundColor,
      //Body
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Style.paddingPhone,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center, // Center content horizontally
                    children: [
                      _logo(),
                      const SizedBox(height: 30),
                      _textFiledName(),
                      const SizedBox(height: 15), // Space between inputs
                      _textFiledPass(),
                      const SizedBox(height: 10), // Space before buttons
                      _forgot_signup(),
                      const SizedBox(height: 10), // Space before buttons
                      _signinButton(),
                    ],
                  ),
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

  //Phần button đăng nhập
  Widget _signinButton() {
    final isLoading = ref.watch(_isLoadingProvider);
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: ShadowCus(
        borderRadius: 20.0,
        baseColor: Style.buttonBackgroundColor, // Button's distinct color
        padding: EdgeInsets.zero, // Padding handled by MaterialButton
        child: MaterialButton(
          onPressed: () {
            toSignIn();
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
                  : Text('Đăng nhập', style: Style.TextButton),
        ),
      ),
    );
  }

  //Phần logo app và tên app
  Widget _logo() {
    return Column(
      children: [
        Hero(
          tag: 'appName',
          child: Text(
            'SmartDine',
            style: TextStyle(
              fontSize: Style.headingFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontFamily: Style.fontFamily,
            ),
          ),
        ),
        Text(
          'Quản lý nhả hảng & phục vụ',
          style: TextStyle(
            fontSize: Style.defaultFontSize,
            color: Style.textColorGray,
            fontFamily: Style.fontFamily,
          ),
        ),
      ],
    );
  }

  //Phân tên đăng nhập
  Widget _textFiledName() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ShadowCus(
        isConcave: true, // Concave effect for input
        borderRadius: 10.0,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Hero(
          tag: 'tendangnhap',
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
              hintText: 'Email', // Use hintText instead of labelText
              hintStyle: const TextStyle(color: kTextColorLight),
              border: InputBorder.none, // Remove default border
              contentPadding: const EdgeInsets.only(
                left: 0,
                top: 12,
                bottom: 12,
                right: 0,
              ), // Adjust padding
            ),
            // onSubmitted:
            //     (value) => ref.read(userProvider.notifier).updateName(value),
            style: const TextStyle(color: kTextColorDark),
          ),
        ),
      ),
    );
  }

  //Phần mật khẩu
  Widget _textFiledPass() {
    final isObscureText = ref.watch(_obscureText);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ShadowCus(
        isConcave: true, // Concave effect for input
        borderRadius: 10.0,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: TextField(
          controller: _passwordController,
          obscureText: isObscureText, // Toggle visibility
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
            hintText: 'Mật khẩu', // Use hintText
            hintStyle: const TextStyle(color: kTextColorLight),
            border: InputBorder.none, // Remove default border
            contentPadding: const EdgeInsets.only(
              left: 0,
              top: 12,
              bottom: 12,
              right: 0,
            ), // Adjust padding
            suffixIcon: IconButton(
              icon: Icon(
                isObscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: () {
                ref.read(_obscureText.notifier).state = !isObscureText;
              },
            ),
          ),
          // onSubmitted:
          //     (value) => ref.read(userProvider.notifier).updateAge(value),
          // style: const TextStyle(color: kTextColorDark),
        ),
      ),
    );
  }

  //Phần  quên mật khẩu và đăng kí
  Widget _forgot_signup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Routes.pushRightLeftConsumerFul(context, const ScreenFindaccuont());
          },
          child: Text(
            'Quên mật khẩu?',
            style: TextStyle(color: Style.textColorGray),
          ),
        ),
        Text('Hoặc', style: TextStyle(color: Style.textColorGray)),
        TextButton(
          onPressed: () {
            // toSignUp();
            Routes.pushRightLeftConsumerLess(context, ScreenSelectSiginup());
          },
          child: Text(
            'Đăng kí',
            style: TextStyle(
              color: Colors.blue, // Distinct color for Sign Up
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
