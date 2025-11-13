import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/utils/date_formater.dart';
import 'package:monimate/utils/format_currency.dart';
import '../theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TransactionController>();
    return Obx(() {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card saldo utama
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.oceanGradient(),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Saldo',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormat.format(
                      c.totalIncome.value - c.totalExpense.value),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 24,
                  children: [
                    _MiniStat(
                        label: 'Pemasukan',
                        value: c.totalIncome.value,
                        color: Colors.greenAccent),
                    _MiniStat(
                        label: 'Pengeluaran',
                        value: c.totalExpense.value,
                        color: Colors.redAccent),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Daftar transaksi terbaru
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transaksi Terbaru',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (c.transactions.isEmpty)
                    const Text('Belum ada transaksi')
                  else
                    ...c.transactions.reversed.take(5).map(
                          (t) => ListTile(
                            leading: Text(
                              t.category == 'gaji'
                                  ? '💼'
                                  : t.category == 'makan'
                                      ? '🍔'
                                      : t.category == 'minum'
                                          ? '🥤'
                                          : t.category == 'transport'
                                              ? '🚗'
                                              : t.category == 'hiburan'
                                                  ? '🎮'
                                                  : t.category == 'belanja'
                                                      ? '🛍️'
                                                      : t.category ==
                                                              'kesehatan'
                                                          ? '💊'
                                                          : t.category ==
                                                                  'pendidikan'
                                                              ? '📚'
                                                              : t.category ==
                                                                      'tagihan'
                                                                  ? '💡'
                                                                  : '🧩',
                              style: const TextStyle(fontSize: 20),
                            ),
                            title: Text(t.description.isEmpty
                                ? t.category.capitalizeFirst!
                                : t.description),
                            subtitle: Text(
                              DateFormatter.format(t.date),
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Text(
                              '${t.type == 'income' ? '+' : '-'} ${CurrencyFormat.format(t.amount)}',
                              style: TextStyle(
                                color: t.type == 'income'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 6),
        Text(
          '$label: ${CurrencyFormat.format(value)}',
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
