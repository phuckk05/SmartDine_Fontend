import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mart_dine/features/bottom_Navigation/bottom_navigation.dart';
import 'package:mart_dine/providers/mode_provider.dart';

Future<void> main() async {
  //Cấu hình để sử dụng firebase
  WidgetsFlutterBinding.ensureInitialized();
  // // Khởi tạo Firebase
  // await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  runApp(const ProviderScope(child: SmartDineApp()));
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

      home: ScreenBottomNavigation(index: 1),
    );
  }
}
