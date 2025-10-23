// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mart_dine/features/staff/screen_choose_table.dart';
import 'package:mart_dine/features/staff/screen_start.dart';
import 'package:mart_dine/providers/mode_provider.dart';

void main() async {
  //Cấu hình để sử dụng firebase
  // WidgetsFlutterBinding.ensureInitialized();
  // // Khởi tạo Firebase
  // await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  runApp(const ProviderScope(child: MeTalkApp()));
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
      home: const ScreenChooseTable(),
    );
  }
}
