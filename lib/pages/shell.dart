import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_page.dart';
import 'transactions_page.dart';
import 'add_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';

class ShellController extends GetxController {
  final RxInt index = 0.obs;
  void changeTab(int i) => index.value = i;
}

class Shell extends StatefulWidget {
  const Shell({Key? key}) : super(key: key);

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final ShellController shellC = Get.put(ShellController(), permanent: true);

  final pages = const [
    DashboardPage(),
    TransactionsPage(),
    AddPage(),
    StatsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: KeyedSubtree(
                // biar AnimatedSwitcher detect perubahan
                key: ValueKey<int>(shellC.index.value),
                child: pages[shellC.index.value],
              ),
            )),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Obx(() => NavigationBar(
                destinations: const [
                  NavigationDestination(
                      icon: Icon(Icons.home_outlined), label: 'Home'),
                  NavigationDestination(
                      icon: Icon(Icons.list_alt_outlined), label: 'Transaksi'),
                  NavigationDestination(
                      icon: Icon(Icons.add_circle_outline), label: 'Tambah'),
                  NavigationDestination(
                      icon: Icon(Icons.bar_chart_outlined), label: 'Statistik'),
                  NavigationDestination(
                      icon: Icon(Icons.settings_outlined), label: 'Pengaturan'),
                ],
                selectedIndex: shellC.index.value,
                onDestinationSelected: (i) => shellC.changeTab(i),
                height: 64,
              )),
        ),
      ),
    );
  }
}
