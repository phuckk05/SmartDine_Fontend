// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:me_talk/demo_spring_boot.dart';
import 'package:me_talk/features/bottom_Navigation/screen/bottom_navigation.dart';
import 'package:me_talk/features/start/screen/screen_start.dart';
import 'package:me_talk/providers/mode_provider.dart';

void main() async {
  //Cấu hình để sử dụng firebase
  // WidgetsFlutterBinding.ensureInitialized();
  // // Khởi tạo Firebase
  // await Firebase.initializeApp();
  runApp(ProviderScope(child: MeTalkApp()));
}

class MeTalkApp extends ConsumerWidget {
  const MeTalkApp({super.key});

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

      // Thiết lập chệ độ sáng tối
      home: const Demo(),
    );
  }
}
