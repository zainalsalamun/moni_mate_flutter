import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/theme_controller.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import '../data/services/hive_service.dart';
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
    // inisialisasi yang perlu dijalankan sebelum tampilkan UI utama
    try {
      await HiveService.init();
      await Future.delayed(const Duration(milliseconds: 500)); // buat smooth
      // register controller setelah Hive ready
      Get.put(TransactionController());
      Get.put(ThemeController());
    } catch (e) {
      // log error, tapi tetap lanjutkan supaya user tidak tertahan
      debugPrint('Init error: $e');
    }

    // beri waktu untuk animasi splash ~1s lalu pindah
    Timer(const Duration(milliseconds: 900), () {
      // Ganti ke Shell (replace)
      Get.offAll(() => const Shell());
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF48C6EF);
    return Scaffold(
      backgroundColor: primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Kalau pakai Lottie:
              // Lottie.asset('assets/lottie/monimate_splash.json', width: 160, height: 160, fit: BoxFit.contain),

              // Jika tidak pakai Lottie, pakai logo static + simple animation
              Image.asset('assets/images/monimate_logo.png',
                  width: 140, height: 140),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
