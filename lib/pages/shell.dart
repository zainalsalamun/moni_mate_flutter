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
  const Shell({super.key});

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
                key: ValueKey<int>(shellC.index.value),
                child: pages[shellC.index.value],
              ),
            )),
      ),
      extendBody: true, // Make body extend behind the navigation bar
      bottomNavigationBar: Obx(() => SafeArea(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: shellC.index.value,
                    onTap: (i) => shellC.changeTab(i),
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    items: [
                      _buildNavItem(
                          Icons.home_filled, Icons.home_outlined, 'Home'),
                      _buildNavItem(Icons.receipt_long,
                          Icons.receipt_long_outlined, 'Histori'),
                      _buildNavItem(
                          Icons.add_circle, Icons.add_circle_outline, 'Tambah'),
                      _buildNavItem(
                          Icons.bar_chart, Icons.bar_chart_outlined, 'Stat'),
                      _buildNavItem(
                          Icons.settings, Icons.settings_outlined, 'Setting'),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData activeIcon, IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Icon(icon, size: 24),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(activeIcon,
              size: 24, color: Theme.of(context).colorScheme.primary),
        ),
      ),
      label: label,
    );
  }
}
