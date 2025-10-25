import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/bottom_Navigation/screen/bottom_navigation.dart';
import 'package:mart_dine/features/kitchen/screen_phongbep.dart';
import 'package:mart_dine/providers/mode_provider.dart';

void main() {
  //Cấu hình để sử dụng firebase
  WidgetsFlutterBinding.ensureInitialized();
  // // Khởi tạo Firebase
  // await Firebase.initializeApp();
  runApp(ProviderScope(child: SmartDineApp()));
}

class SmartDineApp extends ConsumerWidget {
  const SmartDineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SmartDine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: ref.watch(modeProvider) ? Colors.white : Colors.black,
          brightness:
              ref.watch(modeProvider) ? Brightness.dark : Brightness.light,
        ),
      ),

      //home: const ScreenBottomNavigation(index: 2), // Chạy Admin
      //home: ScreenKitChen(), // Chạy Kitchen
      home: const ScreenBottomNavigation(index: 1), // Chạy Admin
    );
  }
}
