import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/models/transaction_model.dart';
import 'package:monimate/utils/date_formater.dart';
import 'package:monimate/utils/format_currency.dart';
import 'package:table_calendar/table_calendar.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final TransactionController c = Get.find<TransactionController>();

  String currentView = "summary";

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.transactions.isEmpty) {
        return const Center(child: Text('Belum ada data untuk ditampilkan.'));
      }

      final expenseList =
          c.transactions.where((t) => t.type == 'expense').toList();

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
          const SizedBox(height: 12),
          _buildViewToggle(context),
          const SizedBox(height: 16),
          if (currentView == "summary")
            _buildSummaryView(
              context,
              categoryTotals: categoryTotals,
              recent7Days: recent7Days,
              dailyTotals: dailyTotals,
            )
          else
            _buildCalendarView(context),
        ],
      );
    });
  }

  // Widget _buildViewToggle(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.all(4),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade200,
  //       borderRadius: BorderRadius.circular(24),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: GestureDetector(
  //             onTap: () {
  //               if (currentView != "summary") {
  //                 setState(() => currentView = "summary");
  //               }
  //             },
  //             child: AnimatedContainer(
  //               duration: const Duration(milliseconds: 180),
  //               curve: Curves.easeInOut,
  //               padding: const EdgeInsets.symmetric(vertical: 10),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(20),
  //                 color: currentView == "summary"
  //                     ? Theme.of(context).colorScheme.primary
  //                     : Colors.transparent,
  //               ),
  //               alignment: Alignment.center,
  //               child: Text(
  //                 "Ringkasan",
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.w600,
  //                   color: currentView == "summary"
  //                       ? Colors.white
  //                       : Colors.black87,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: GestureDetector(
  //             onTap: () {
  //               if (currentView != "calendar") {
  //                 setState(() => currentView = "calendar");
  //               }
  //             },
  //             child: AnimatedContainer(
  //               duration: const Duration(milliseconds: 180),
  //               curve: Curves.easeInOut,
  //               padding: const EdgeInsets.symmetric(vertical: 10),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(20),
  //                 color: currentView == "calendar"
  //                     ? Theme.of(context).colorScheme.primary
  //                     : Colors.transparent,
  //               ),
  //               alignment: Alignment.center,
  //               child: Text(
  //                 "Kalender",
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.w600,
  //                   color: currentView == "calendar"
  //                       ? Colors.white
  //                       : Colors.black87,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (currentView != "summary") {
                  setState(() => currentView = "summary");
                }
              },
              child: AnimatedScale(
                scale: currentView == "summary" ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: currentView == "summary"
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Ringkasan",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: currentView == "summary"
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (currentView != "calendar") {
                  setState(() => currentView = "calendar");
                }
              },
              child: AnimatedScale(
                scale: currentView == "calendar" ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: currentView == "calendar"
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Kalender",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: currentView == "calendar"
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryView(
    BuildContext context, {
    required Map<String, double> categoryTotals,
    required List<DateTime> recent7Days,
    required List<double> dailyTotals,
  }) {
    return Column(
      children: [
        Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pengeluaran Bulan Ini",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormat.format(
                    categoryTotals.values.fold(0.0, (a, b) => a + b),
                  ),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 260,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 60,
                      sectionsSpace: 4,
                      startDegreeOffset: -90,
                      pieTouchData: PieTouchData(enabled: true),
                      sections: () {
                        final total =
                            categoryTotals.values.fold(0.0, (a, b) => a + b);

                        return categoryTotals.entries.map((e) {
                          final percent =
                              total == 0 ? 0 : (e.value / total) * 100;
                          final color = _categoryColor(e.key);

                          return PieChartSectionData(
                            color: color,
                            value: e.value,
                            radius: 90,
                            showTitle: true,
                            title: "${percent.toStringAsFixed(0)}%",
                            titleStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          );
                        }).toList();
                      }(),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  children: categoryTotals.entries.map((e) {
                    final color = _categoryColor(e.key);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.key.capitalizeFirst!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            CurrencyFormat.format(e.value),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
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
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
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
  }

  Widget _buildCalendarView(BuildContext context) {
    final Map<DateTime, List<TransactionModel>> events = {};

    for (var t in c.transactions) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      events.putIfAbsent(day, () => []);
      events[day]!.add(t);
    }

    DateTime today = DateTime.now();
    _selectedDay ??= DateTime(today.year, today.month, today.day);

    final selectedKey = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    final selectedEvents = events[selectedKey] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TableCalendar<TransactionModel>(
              firstDay: DateTime(today.year - 1, 1, 1),
              lastDay: DateTime(today.year + 1, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) {
                final key = DateTime(day.year, day.month, day.day);
                return events[key] ?? [];
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Transaksi ${DateFormatter.format(selectedKey)}",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (selectedEvents.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tidak ada transaksi pada hari ini.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: selectedEvents.map((t) {
              final isIncome = t.type == 'income';
              final emoji = _emoji(t.category);

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    t.description.isEmpty
                        ? t.category.capitalizeFirst!
                        : t.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isIncome ? 'Pemasukan' : 'Pengeluaran',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Text(
                    '${isIncome ? '+' : '-'} ${CurrencyFormat.format(t.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isIncome ? Colors.green : Colors.redAccent,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
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
      case 'belanja':
        return const Color(0xFFE879F9);
      case 'kesehatan':
        return const Color(0xFFFB7185);
      case 'pendidikan':
        return const Color(0xFF8B5CF6);
      case 'tagihan':
        return const Color(0xFFFFA500);
      case 'minum':
        return const Color(0xFF654444);
      default:
        return Colors.grey;
    }
  }

  String _emoji(String key) {
    switch (key) {
      case 'makan':
        return '🍔';
      case 'minum':
        return '🥤';
      case 'transport':
        return '🚗';
      case 'hiburan':
        return '🎮';
      case 'gaji':
        return '💼';
      case 'belanja':
        return '🛍️';
      case 'kesehatan':
        return '💊';
      case 'pendidikan':
        return '📚';
      case 'tagihan':
        return '💡';
      default:
        return '🧩';
    }
  }
}
