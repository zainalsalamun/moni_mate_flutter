import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart'; // ⬅️ Tambahkan import ini
import 'package:monimate/data/controller/theme_controller.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/services/hive_service.dart';

import 'shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  Future<void> _initEverything() async {
    try {
      await initializeDateFormatting('id_ID', null);

      await HiveService.init();

      Get.put(TransactionController());
      Get.put(ThemeController());

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Init error: $e');
    }

    Timer(const Duration(milliseconds: 900), () {
      Get.offAll(() => const Shell());
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF48C6EF);
    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/monimate_logo.png',
                width: 140,
                height: 140,
              ),
              const SizedBox(height: 18),
              const Text(
                'MoniMate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 60,
                height: 6,
                child: LinearProgressIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
