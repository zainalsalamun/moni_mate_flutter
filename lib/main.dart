import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'pages/dashboard_page.dart';
import 'pages/transactions_page.dart';
import 'pages/add_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const _Shell(),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell({Key? key}) : super(key: key);

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int index = 0;
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
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: NavigationBar(
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
            selectedIndex: index,
            onDestinationSelected: (i) => setState(() => index = i),
            height: 64,
          ),
        ),
      ),
    );
  }
}
