// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/start/screen/screen_start.dart';
import 'package:mart_dine/providers/mode_provider.dart';
import 'features/branch_management/screen/branch_dashboard.dart';

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
      home: const BranchDashboardScreen(),
    );
  }
}
