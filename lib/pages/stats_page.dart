import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:monimate/data/controller/transaction_controller.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TransactionController>();

    return Obx(() {
      if (c.transactions.isEmpty) {
        return const Center(child: Text('Belum ada data untuk ditampilkan.'));
      }

      final expenseList =
          c.transactions.where((t) => t.type == 'expense').toList();
      // final incomeList =
      //     c.transactions.where((t) => t.type == 'income').toList();

      final Map<String, double> categoryTotals = {};
      for (var t in expenseList) {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0) + t.amount;
      }

      final now = DateTime.now();
      final recent7Days =
          List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
      final dailyTotals = <double>[];

      for (var d in recent7Days) {
        final dayTotal = expenseList
            .where((t) =>
                t.date.day == d.day &&
                t.date.month == d.month &&
                t.date.year == d.year)
            .fold(0.0, (sum, t) => sum + t.amount);
        dailyTotals.add(dayTotal);
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Statistik Keuangan',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengeluaran per Kategori',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        sections: categoryTotals.entries.map((e) {
                          final color = _categoryColor(e.key);
                          return PieChartSectionData(
                            color: color,
                            value: e.value,
                            title: e.key.capitalizeFirst,
                            radius: 70,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...categoryTotals.entries.map((e) {
                    final color = _categoryColor(e.key);
                    return Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(e.key.capitalizeFirst!)),
                        Text('Rp ${e.value.toStringAsFixed(0)}'),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tren Pengeluaran 7 Hari Terakhir',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, meta) {
                                final idx = v.toInt();
                                if (idx >= 0 && idx < recent7Days.length) {
                                  final day = recent7Days[idx].day;
                                  return Text('$day',
                                      style: const TextStyle(fontSize: 10));
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(dailyTotals.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: dailyTotals[i],
                                color: Colors.blueAccent,
                                width: 14,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }),
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

  Color _categoryColor(String key) {
    switch (key) {
      case 'makan':
        return const Color(0xFF6F86D6);
      case 'transport':
        return const Color(0xFF48C6EF);
      case 'hiburan':
        return const Color(0xFF22C55E);
      case 'gaji':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }
}
