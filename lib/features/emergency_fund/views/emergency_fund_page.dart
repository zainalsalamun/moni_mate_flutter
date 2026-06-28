import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/emergency_fund_controller.dart';
import '../../../utils/format_currency.dart';

class EmergencyFundPage extends StatelessWidget {
  const EmergencyFundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmergencyFundController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dana Darurat', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        final metrics = controller.metrics.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1: Summary
              _buildSummarySection(context, metrics),
              const SizedBox(height: 24),

              // SECTION 2: Readiness Status
              _buildReadinessSection(context, metrics),
              const SizedBox(height: 24),

              // SECTION 3: Profile Selector & Breakdown
              _buildProfileSection(context, controller),
              const SizedBox(height: 24),

              // SECTION 4: Wallet Source
              _buildWalletSourceSection(context),
              const SizedBox(height: 24),

              // SECTION 5: Projection
              _buildProjectionSection(context, metrics),
              const SizedBox(height: 24),

              // Goal Integration
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.createEmergencyGoal();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Goal Dana Darurat berhasil dibuat.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text('Create Emergency Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummarySection(BuildContext context, metrics) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00796B), Color(0xFF00B4DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4DB).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            'Dana Terkumpul',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormat.format(metrics.currentFund),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${CurrencyFormat.format(metrics.targetFund)}',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
              ),
              Text(
                '${(metrics.progressPercent * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: metrics.progressPercent.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessSection(BuildContext context, metrics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(metrics.statusColorHex).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_rounded,
              color: Color(metrics.statusColorHex),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Readiness Status', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  metrics.readinessStatus,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(metrics.statusColorHex),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, EmergencyFundController controller) {
    final profile = controller.profile.value;
    final metrics = controller.metrics.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profil Dana Darurat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildProfileChoice(
                  'Single', '3 Bulan', profile.type == 'single', () => controller.updateProfile('single')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildProfileChoice(
                  'Married', '6 Bulan', profile.type == 'married', () => controller.updateProfile('married')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildProfileChoice(
                  'Freelance', '9 Bulan', profile.type == 'freelancer', () => controller.updateProfile('freelancer')),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildBreakdownRow('Rata-rata Pengeluaran /bln', CurrencyFormat.format(metrics.averageMonthlyExpense)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
              _buildBreakdownRow('Multiplier (${profile.type.capitalizeFirst})', 'x${metrics.multiplier}'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
              _buildBreakdownRow('Target Fund Ideal', CurrencyFormat.format(metrics.targetFund), isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileChoice(String title, String subtitle, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00796B) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00796B) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? null : Colors.grey, fontWeight: isBold ? FontWeight.bold : null)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, fontSize: isBold ? 16 : 14)),
      ],
    );
  }

  Widget _buildWalletSourceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sumber Dana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Hanya saldo liquid (Cash, Bank, E-Wallet) yang dihitung sebagai dana darurat.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSourceChip('💵 Cash'),
              const SizedBox(width: 8),
              _buildSourceChip('🏦 Bank'),
              const SizedBox(width: 8),
              _buildSourceChip('📱 E-Wallet'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSourceChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildProjectionSection(BuildContext context, metrics) {
    // Basic projection: assuming saving 10% of avg expense or a fixed 1M / month
    double assumedSaving = 1000000;
    if (metrics.averageMonthlyExpense > 0) {
      assumedSaving = metrics.averageMonthlyExpense * 0.2; // 20% of expenses roughly
    }
    double shortfall = metrics.targetFund - metrics.currentFund;
    int monthsNeeded = shortfall > 0 ? (shortfall / assumedSaving).ceil() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timeline, color: Colors.orange, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Proyeksi Pencapaian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if (monthsNeeded > 0)
                  Text(
                    'Jika kamu menabung Rp ${CurrencyFormat.format(assumedSaving).replaceAll('Rp ', '').trim()} / bulan, target tercapai dalam $monthsNeeded bulan.',
                    style: const TextStyle(fontSize: 13),
                  )
                else
                  const Text(
                    'Target dana darurat kamu sudah tercapai! Pertahankan kondisi ini.',
                    style: TextStyle(fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
