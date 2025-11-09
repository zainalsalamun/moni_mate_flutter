
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Balance Card
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.oceanGradient(),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Saldo', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70)),
              const SizedBox(height: 6),
              Text('Rp 2.540.000', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 24,
                children: const [
                  _MiniStat(label: 'Pemasukan', value: 'Rp 150.000', icon: Icons.arrow_upward),
                  _MiniStat(label: 'Pengeluaran', value: 'Rp 80.000', icon: Icons.arrow_downward),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Weekly summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ringkasan Mingguan', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                _FakeBarChart(values: const [2,5,3,4,6,2,4]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Latest transactions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Transaksi Terbaru'),
                SizedBox(height: 8),
                _TxRow(emoji: '🍔', title: 'Makan Siang', subtitle: 'Hari ini • Makan', amount: '- Rp 25.000', negative: true),
                _TxRow(emoji: '🚗', title: 'Transportasi', subtitle: 'Kemarin • Transport', amount: '- Rp 50.000', negative: true),
                _TxRow(emoji: '💼', title: 'Gaji Bulanan', subtitle: '1 Nov • Pemasukan', amount: '+ Rp 3.000.000', negative: false),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _MiniStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  final String emoji, title, subtitle, amount;
  final bool negative;
  const _TxRow({required this.emoji, required this.title, required this.subtitle, required this.amount, required this.negative});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.w600, color: negative ? Colors.redAccent : Colors.green)),
        ],
      ),
    );
  }
}

class _FakeBarChart extends StatelessWidget {
  final List<int> values;
  const _FakeBarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final max = (values.isEmpty ? 1 : values.reduce((a,b)=>a>b?a:b)).toDouble();
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((v) {
          final h = (v / max) * 100;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  gradient: AppTheme.oceanGradient(),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
