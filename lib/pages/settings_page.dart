import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/theme_controller.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import '../data/services/export_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TransactionController>();
    final themeC = Get.find<ThemeController>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Obx(() {
                  final isDark = themeC.themeMode.value == ThemeMode.dark;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tema',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Light / Dark',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Mode Terang',
                            onPressed: () {
                              themeC.toggleTheme(false);
                              Get.snackbar(
                                'Tema Berubah',
                                'Mode Terang Aktif ☀️',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                              );
                            },
                            icon: Icon(
                              Icons.wb_sunny_outlined,
                              color:
                                  !isDark ? Colors.amber : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Mode Gelap',
                            onPressed: () {
                              themeC.toggleTheme(true);
                              Get.snackbar(
                                'Tema Berubah',
                                'Mode Gelap Aktif 🌙',
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                              );
                            },
                            icon: Icon(
                              Icons.nightlight_round,
                              color: isDark
                                  ? Colors.blueAccent
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Backup Data',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Simpan data ke file lokal',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final confirm = await Get.dialog<bool>(
                          AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: const Text(
                                'Yakin ingin menghapus semua data transaksi?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          c.clearAll();
                          Get.snackbar('Data dihapus',
                              'Semua transaksi berhasil dihapus.');
                        }
                      },
                      child: const Text('Backup'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Export CSV',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text('Bagikan riwayat transaksi',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        if (c.transactions.isEmpty) {
                          Get.snackbar('Tidak ada data',
                              'Belum ada transaksi untuk diexport');
                          return;
                        }

                        Get.snackbar('Menyiapkan...',
                            'Membuat file CSV, tunggu sebentar');
                        final path =
                            await ExportService.exportToCsv(c.transactions);
                        await ExportService.shareCsv(path);
                        Get.snackbar('Berhasil',
                            'File berhasil diexport dan siap dibagikan');
                      },
                      child: const Text('Export'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text(
              'Tentang MoniMate',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('v1.0.0 • Teman keuangan pribadimu 💰'),
          ),
        ),
      ],
    );
  }
}
