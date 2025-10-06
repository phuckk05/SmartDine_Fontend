// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:me_talk/core/constrats.dart';
// import 'package:me_talk/core/style.dart';
// import 'package:me_talk/features/forgot_passwork/screen/screen_confirm.dart';
// import 'package:me_talk/routes.dart';
// import 'package:me_talk/widgets/icon_back.dart';

// final textEmailProvider = StateProvider<TextEditingController>((ref) => TextEditingController(),);
// final isClosedProvider = StateProvider<bool>((ref) => false);

// class ScreenFindAccuont extends ConsumerStatefulWidget {
//   const ScreenFindAccuont({super.key});

//   @override
//   ConsumerState<ScreenFindAccuont> createState() =>
//       _ScreenForgotpassworkState();
// }

// class _ScreenForgotpassworkState extends ConsumerState<ScreenFindAccuont> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //Màu background
//       backgroundColor: Style.backgroundColor,
//       //AppBar
//       appBar: AppBar(
//         leading: IconBack.back(context),
//         title: Text('Tìm tài khoản', style: Style.fontTitle),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//       ),
//       //Body
//       body: _body(),
//     );
//   }

//   Widget _body() {
//     return SafeArea(
//       child: Center(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
//             child: Column(
//               children: [
//                 _dongChu(),
//                 const SizedBox(height: 30),
//                 _textFiled(),
//                 const SizedBox(height: 30),
//                 _buttonConfirm()
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   //Dòng chữ
//   Widget _dongChu() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: const Text(
//         'Nhập địa chỉ email của bạn.',
//         style: TextStyle(
//           fontSize: Style.defaultFontSize,
//           color: Style.textColorMedium,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }

//   //Textfiled tên email
//   Widget _textFiled() {
//     final isCheckColsed = ref.watch(isClosedProvider);
//     return ShadowCus(
//       isConcave: true,
//       borderRadius: 10.0,
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//       child: Material(
//         child: TextField(
//           controller: ref.watch(textEmailProvider),
//           decoration: InputDecoration(
//             prefixIcon: Icon(Icons.email, color: Colors.grey[600]),
//             hintText: 'Email', // Use hintText instead of labelText
//             hintStyle: const TextStyle(color: kTextColorLight),
//             border: InputBorder.none, // Remove default border
//             contentPadding: const EdgeInsets.only(
//               left: 0,
//               top: 12,
//               bottom: 12,
//               right: 0,
//             ), // Adjust padding
//             suffixIcon:
//                 isCheckColsed
//                     ? IconButton(
//                       icon: const Icon(
//                         Icons.close,
//                         color: Style.kTextColorMedium,
//                       ),
//                       onPressed: () {
//                         ref.read(textEmailProvider).clear();
//                         ref.read(isClosedProvider.notifier).state = false;
//                       },
//                     )
//                     : SizedBox(),
//             filled: true,
//             fillColor: Style.backgroundColor,
//           ),
//           onChanged: (value) {
//             value.isNotEmpty
//                 ? ref.read(isClosedProvider.notifier).state = true
//                 : ref.read(isClosedProvider.notifier).state = false;
//           },
    
//           style: const TextStyle(color: kTextColorDark),
//         ),
//       ),
//     );
//   }

//   //Button "tiếp tục"
//   Widget _buttonConfirm() {
//     return ShadowCus(
//       borderRadius: 20.0,
//       baseColor: Style.buttonBackgroundColor, // Button's distinct color
//       padding: EdgeInsets.zero, // Padding handled by MaterialButton
//       child: MaterialButton(
//         onPressed: () {
//           Routes.pushRightLeft(context, ScreenConfirm());
//         },
//         // Set button color to transparent so NeumorphicContainer's color shows
//         color: Colors.transparent,
//         elevation: 0, // Remove default elevation
//         highlightElevation: 0, // Remove highlight elevation
//         splashColor: Colors.white.withOpacity(0.2), // Splash effect
//          minWidth: double.infinity,
//         height: 50,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.0),
//         ),
        
//         // child: Text('Đăng nhập', style: Style.TextButton),
//         child:Text('Tiếp tục', style: Style.TextButton),
//       ),
//     );
//   }
// }
