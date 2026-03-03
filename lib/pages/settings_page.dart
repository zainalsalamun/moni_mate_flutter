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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Pengaturan',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(context, "Tampilan"),
                    _buildSettingCard(
                      context,
                      child: Obx(() {
                        final isDark = themeC.themeMode.value == ThemeMode.dark;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn(
                                "Mode Gelap", "Ubah nuansa aplikasi"),
                            Switch.adaptive(
                              value: isDark,
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                              onChanged: (val) {
                                themeC.toggleTheme(val);
                                Get.snackbar(
                                  'Tema Berubah',
                                  val
                                      ? 'Mode Gelap Aktif 🌙'
                                      : 'Mode Terang Aktif ☀️',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.9),
                                  colorText: Colors.white,
                                  margin: const EdgeInsets.all(16),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "Data & Riwayat"),
                    _buildSettingCard(
                      context,
                      child: InkWell(
                        onTap: () async {
                          if (c.transactions.isEmpty) {
                            Get.snackbar('Tidak ada data',
                                'Belum ada transaksi untuk dieksport',
                                snackPosition: SnackPosition.TOP);
                            return;
                          }
                          Get.snackbar('Menyiapkan...',
                              'Membuat file CSV, tunggu sebentar',
                              snackPosition: SnackPosition.TOP);
                          final path =
                              await ExportService.exportToCsv(c.transactions);
                          await ExportService.shareCsv(path);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn("Export CSV",
                                "Bagikan riwayat sebagai file Excel"),
                            Icon(Icons.ios_share_rounded,
                                color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                      context,
                      child: InkWell(
                        onTap: () async {
                          final confirm = await Get.dialog<bool>(
                            AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: const Text('Hapus Semua Data?'),
                              content: const Text(
                                  'Tindakan ini tidak bisa dibatalkan. Semua riwayat transaksi akan hilang permanen.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: Text('Batal',
                                      style: TextStyle(
                                          color: Colors.grey.shade600)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => Get.back(result: true),
                                  child: const Text('Hapus Sekarang',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            c.clearAll();
                            Get.snackbar(
                                'Terhapus', 'Semua data berhasil dibersihkan',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn(
                                "Reset Data", "Hapus semua riwayat transaksi",
                                isDestructive: true),
                            const Icon(Icons.delete_sweep_rounded,
                                color: Colors.redAccent),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, "Informasi"),
                    _buildSettingCard(
                      context,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.info_outline_rounded,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('MoniMate App',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text('Versi 1.1.0 • Stable Build',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: child,
    );
  }

  Widget _buildInfoColumn(String title, String subtitle,
      {bool isDestructive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: isDestructive ? Colors.redAccent : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
