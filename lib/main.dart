import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:monimate/data/controller/theme_controller.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:monimate/pages/shell.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  //Init Hive & Controller
  await HiveService.init();
  Get.put(TransactionController());
  Get.put(ThemeController());

  runApp(const MoniMateApp());
}

class MoniMateApp extends StatelessWidget {
  const MoniMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoniMate',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const Shell(),
    );
  }
}
