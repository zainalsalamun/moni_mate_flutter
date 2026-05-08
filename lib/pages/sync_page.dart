import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/controller/sync_controller.dart';

/// SyncPage — Premium cloud sync settings UI.
/// Shows connection status, last sync time, sync now button,
/// auto-sync toggle, and Google account management.
class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final syncC = Get.find<SyncController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Sinkronisasi',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Sync Status Hero Card ──────────────
                    _buildSyncStatusCard(context, syncC, isDark),
                    const SizedBox(height: 24),

                    // ── Account Section ────────────────────
                    _buildSectionHeader(context, "AKUN GOOGLE"),
                    _buildAccountCard(context, syncC, isDark),
                    const SizedBox(height: 24),

                    // ── Sync Settings Section ──────────────
                    _buildSectionHeader(context, "PENGATURAN SYNC"),
                    _buildAutoSyncCard(context, syncC, isDark),
                    const SizedBox(height: 12),
                    _buildUnsyncedCard(context, syncC, isDark),
                    const SizedBox(height: 24),

                    // ── Info Section ────────────────────────
                    _buildSectionHeader(context, "INFORMASI"),
                    _buildInfoCard(context, isDark),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ─── Sync Status Hero Card ─────────────────────
  Widget _buildSyncStatusCard(
      BuildContext context, SyncController syncC, bool isDark) {
    return Obx(() {
      final isOnline = syncC.isOnline.value;
      final isSyncing = syncC.isSyncing.value;
      final isSignedIn = syncC.isSignedIn.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isOnline
                ? [const Color(0xFF0288D1), const Color(0xFF4FC3F7)]
                : [
                    Colors.grey.shade600,
                    Colors.grey.shade400,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isOnline
                      ? const Color(0xFF0288D1)
                      : Colors.grey.shade600)
                  .withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status row
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline
                        ? const Color(0xFF69F0AE)
                        : Colors.orange.shade300,
                    boxShadow: [
                      BoxShadow(
                        color: (isOnline
                                ? const Color(0xFF69F0AE)
                                : Colors.orange.shade300)
                            .withOpacity(0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const Spacer(),
                if (isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Sync message
            Text(
              syncC.syncStatusMessage.value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            if (syncC.lastSyncTime.value != null)
              Text(
                _formatLastSync(syncC.lastSyncTime.value!),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            const SizedBox(height: 20),

            // Sync Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (isSyncing || !isSignedIn)
                    ? null
                    : () async {
                        final success = await syncC.syncNow();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  success ? 'Sync Berhasil ✅' : 'Sync Gagal',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  success
                                      ? 'Semua data berhasil disinkronkan'
                                      : syncC.isOnline.value
                                          ? 'Terjadi kesalahan saat sync'
                                          : 'Tidak ada koneksi internet',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            backgroundColor: success
                                ? const Color(0xFF0288D1).withOpacity(0.9)
                                : Colors.redAccent.withOpacity(0.9),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                icon: Icon(
                  isSyncing
                      ? Icons.hourglass_top_rounded
                      : Icons.sync_rounded,
                  size: 20,
                ),
                label: Text(
                  isSyncing ? 'Menyinkronkan...' : 'Sync Sekarang',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0288D1),
                  disabledBackgroundColor: Colors.white.withOpacity(0.5),
                  disabledForegroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── Account Card ──────────────────────────────
  Widget _buildAccountCard(
      BuildContext context, SyncController syncC, bool isDark) {
    return Obx(() {
      final isSignedIn = syncC.isSignedIn.value;

      return _buildCard(
        context,
        isDark,
        child: isSignedIn
            ? Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_circle_rounded,
                      color: Color(0xFF0288D1),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          syncC.userName.value.isNotEmpty
                              ? syncC.userName.value
                              : 'Google Account',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          syncC.userEmail.value,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirm = await Get.dialog<bool>(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text('Putuskan Koneksi?'),
                          content: const Text(
                              'Data lokal tetap aman. Anda bisa menghubungkan kembali kapan saja.'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: Text('Batal',
                                  style:
                                      TextStyle(color: Colors.grey.shade600)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Get.back(result: true),
                              child: const Text('Putuskan',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await syncC.signOut();
                      }
                    },
                    child: Text(
                      'Putuskan',
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              )
            : InkWell(
                onTap: () async {
                  final success = await syncC.signIn();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            success ? 'Terhubung ✅' : 'Gagal terhubung',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            success
                                ? 'Akun Google berhasil dihubungkan'
                                : 'Silakan coba lagi',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      backgroundColor: success
                          ? const Color(0xFF0288D1).withOpacity(0.9)
                          : Colors.redAccent.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0288D1).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        color: Color(0xFF0288D1),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hubungkan Google',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Login untuk sync data ke cloud',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
      );
    });
  }

  // ─── Auto Sync Card ────────────────────────────
  Widget _buildAutoSyncCard(
      BuildContext context, SyncController syncC, bool isDark) {
    return Obx(() => _buildCard(
          context,
          isDark,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto Sync',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sinkronkan otomatis setiap 15 menit',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: syncC.autoSyncEnabled.value,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: syncC.isSignedIn.value
                    ? (val) => syncC.toggleAutoSync(val)
                    : null,
              ),
            ],
          ),
        ));
  }

  // ─── Unsynced Count Card ───────────────────────
  Widget _buildUnsyncedCard(
      BuildContext context, SyncController syncC, bool isDark) {
    return Obx(() {
      final count = syncC.unsyncedCount.value;

      return _buildCard(
        context,
        isDark,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: count > 0
                    ? Colors.orange.withOpacity(0.12)
                    : const Color(0xFF69F0AE).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                count > 0
                    ? Icons.cloud_upload_rounded
                    : Icons.cloud_done_rounded,
                color: count > 0 ? Colors.orange : const Color(0xFF69F0AE),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count > 0
                        ? '$count data belum disinkronkan'
                        : 'Semua data tersinkronkan',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count > 0
                        ? 'Tekan Sync Sekarang untuk mengunggah'
                        : 'Data kamu aman di cloud ☁️',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── Info Card ─────────────────────────────────
  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return _buildCard(
      context,
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                'Tentang Cloud Sync',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
              Icons.shield_rounded, 'Data disimpan terenkripsi di Google Drive'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.devices_rounded,
              'Pindah device tanpa kehilangan data'),
          const SizedBox(height: 8),
          _buildInfoRow(
              Icons.wifi_off_rounded, 'App tetap berfungsi saat offline'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.compare_arrows_rounded,
              'Konflik diselesaikan otomatis (data terbaru menang)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Shared UI Components ──────────────────────

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, bool isDark,
      {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: child,
    );
  }

  // ─── Helpers ───────────────────────────────────

  String _formatLastSync(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = _monthName(dt.month);
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return 'Terakhir sync: $d $m $y, $h:$min';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return months[month - 1];
  }
}
