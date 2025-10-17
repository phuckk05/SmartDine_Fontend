import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/signin/screen_signin.dart';
import 'package:mart_dine/routes.dart';

// Provider quản lý alignment
final alignmentProvider = StateProvider<Alignment>(
  (ref) => Alignment.topCenter,
);

// Provider quản lý góc xoay
final rotationProvider = StateProvider<double>((ref) => 0.0);

// Provider quản lý chiều cao
final heightProvider = StateProvider<double>((ref) => 150);

// Provider quản lý chiều rộng
final widthProvider = StateProvider<double>((ref) => 150);

//tên ứng dụng
// final appNameProvider = StateProvider<String>((ref) => '');

class ScreenStart extends ConsumerStatefulWidget {
  const ScreenStart({super.key});

  @override
  ConsumerState<ScreenStart> createState() => _ScreenStartState();
}

class _ScreenStartState extends ConsumerState<ScreenStart> {
  //String tên ứng dụng
  String appName = '';
  String appNameLast = '';

  //String ảnh
  String appImage = '';

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), () {
      final current = ref.read(alignmentProvider);
      final newAlignment =
          current == Alignment.topCenter
              ? Alignment.center
              : Alignment.topCenter;
      ref.read(alignmentProvider.notifier).state = newAlignment;

      Future.delayed(const Duration(seconds: 2), () {
        final currentRotation = ref.read(rotationProvider);
        ref.read(rotationProvider.notifier).state = currentRotation + 90;

        Future.delayed(const Duration(seconds: 1), () {
          final currentHeight = ref.read(heightProvider);
          final currentWidth = ref.read(widthProvider);
          ref.read(heightProvider.notifier).state =
              currentHeight == 150 ? MediaQuery.of(context).size.height : 150;
          ref.read(widthProvider.notifier).state =
              currentWidth == 150 ? MediaQuery.of(context).size.width : 150;

          // Cập nhật tên ứng dụng
          appName = 'SmartDine';

          //Chuyển màn hình sang login sau 3 giây
          Future.delayed(Duration(seconds: 3), () {
            Routes.pushAndRemoveUntil(context, ScreenSignIn());
          });

          // Ch
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final alignment = ref.watch(alignmentProvider);
    final rotation = ref.watch(rotationProvider) / 90;
    final height = ref.watch(heightProvider);
    final width = ref.watch(widthProvider);

    // Nếu đang full thì bo tròn ít lại
    final isFullSize = height > 300 && width > 300;
    final borderRadius = BorderRadius.circular(isFullSize ? 0 : 20);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: AnimatedAlign(
          alignment: alignment,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          child: AnimatedRotation(
            turns: rotation,
            duration: const Duration(seconds: 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  appImage.isNotEmpty
                      ? Expanded(
                        child: Center(
                          child: Hero(
                            tag: 'appImage',
                            child: Image.asset(
                              appImage.toString(),
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ),
                      )
                      : SizedBox(),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Hero(
                            tag: 'appName',
                            child: Text(
                              appName.toString(),
                              style: TextStyle(
                                fontSize: Style.headingFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontFamily: Style.fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
