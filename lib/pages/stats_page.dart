import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/models/transaction_model.dart';
import 'package:monimate/utils/category_icon.dart';
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

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.transactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_graph_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Belum Ada Statistik',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Catat transaksi Anda terlebih dahulu\nuntuk melihat ringkasan keuangan di sini.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      height: 1.5,
                    ),
              ),
            ],
          ),
        );
      }

      // Filter by selected month
      final monthTransactions = c.transactions.where((t) {
        return t.date.year == _selectedMonth.year &&
            t.date.month == _selectedMonth.month;
      }).toList();

      if (monthTransactions.isEmpty && currentView == "summary") {
        return Column(
          children: [
            const SizedBox(height: 16),
            _buildMonthSelector(context),
            const SizedBox(height: 50),
            _buildEmptyMonthState(context),
          ],
        );
      }

      final expenseList =
          monthTransactions.where((t) => t.type == 'expense').toList();
      final incomeList =
          monthTransactions.where((t) => t.type == 'income').toList();

      final totalExpense = expenseList.fold(0.0, (sum, t) => sum + t.amount);
      final totalIncome = incomeList.fold(0.0, (sum, t) => sum + t.amount);

      final lastMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      final pastMonthTransactions = c.transactions.where((t) {
        return t.date.year == lastMonth.year && t.date.month == lastMonth.month;
      }).toList();
      final pastTotalExpense = pastMonthTransactions.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);
      final pastTotalIncome = pastMonthTransactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);

      String calculateGrowth(double past, double current) {
        if (past == 0 && current == 0) return "0%";
        if (past == 0) return "↑ 100%";
        final diff = current - past;
        final pct = (diff / past * 100).abs().toStringAsFixed(0);
        if (diff >= 0) return "↑ $pct%";
        return "↓ $pct%";
      }

      final lastMonthName = DateFormatter.formatMonth(lastMonth);
      final incomeGrowthText = "${calculateGrowth(pastTotalIncome, totalIncome)} dari $lastMonthName ${lastMonth.year}";
      final expenseGrowthText = "${calculateGrowth(pastTotalExpense, totalExpense)} dari $lastMonthName ${lastMonth.year}";

      final Map<String, double> categoryTotals = {};
      for (var t in expenseList) {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0) + t.amount;
      }

      // Bar Chart Logic for the selected month
      // We'll show weekly totals or just 4 segments for the month
      final daysInMonth =
          DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
      final weeklyTotals = List.generate(4, (i) {
        final start = i * 7 + 1;
        final end = (i == 3) ? daysInMonth : (i + 1) * 7;
        return expenseList
            .where((t) => t.date.day >= start && t.date.day <= end)
            .fold(0.0, (sum, t) => sum + t.amount);
      });

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMonthSelector(context),
          const SizedBox(height: 20),
          _buildViewToggle(context),
          const SizedBox(height: 20),
          if (currentView == "summary")
            _buildSummaryView(
              context,
              categoryTotals: categoryTotals,
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              weeklyTotals: weeklyTotals,
              incomeGrowthText: incomeGrowthText,
              expenseGrowthText: expenseGrowthText,
            )
          else
            _buildCalendarView(context),
          const SizedBox(height: 120),
        ],
      );
    });
  }

  Widget _buildMonthSelector(BuildContext context) {
    final monthName = DateFormatter.formatMonth(_selectedMonth);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 20),
              color: Colors.black87,
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                });
              },
            ),
          ),
          Column(
            children: [
              Text(
                monthName,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87),
              ),
              const SizedBox(height: 2),
              Text(
                _selectedMonth.year.toString(),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right_rounded, size: 20),
              color: Colors.black87,
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMonthState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            "Tidak ada transaksi di bulan ini",
            style: TextStyle(
                color: Colors.grey.shade600, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: currentView == "summary"
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded, 
                      size: 18, 
                      color: currentView == "summary" ? Colors.white : Colors.grey.shade600
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Ringkasan",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: currentView == "summary"
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: currentView == "calendar"
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded, 
                      size: 16, 
                      color: currentView == "calendar" ? Colors.white : Colors.grey.shade600
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Kalender",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: currentView == "calendar"
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
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
    required double totalIncome,
    required double totalExpense,
    required List<double> weeklyTotals,
    required String incomeGrowthText,
    required String expenseGrowthText,
  }) {
    return Column(
      children: [
        // Cash Flow Overview
        Row(
          children: [
            Expanded(
              child: _buildSimpleStatCard(
                context,
                title: "Pemasukan",
                amount: totalIncome,
                color: Colors.green,
                icon: Icons.south_rounded,
                growthText: incomeGrowthText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSimpleStatCard(
                context,
                title: "Pengeluaran",
                amount: totalExpense,
                color: Colors.redAccent,
                icon: Icons.north_east_rounded,
                growthText: expenseGrowthText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 3,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Distribusi Pengeluaran",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text("Persentase", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey.shade700),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (categoryTotals.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("Tidak ada pengeluaran", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  )
                else ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final chartAreaWidth = constraints.maxWidth * (5 / 11);
                      final maxTotalRadius = chartAreaWidth / 2.6;
                      final centerRadius = (maxTotalRadius * 0.45).clamp(15.0, 40.0);
                      final sectionRadius = (maxTotalRadius * 0.55).clamp(20.0, 45.0);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 180,
                              child: PieChart(
                                PieChartData(
                                  centerSpaceRadius: centerRadius,
                                  sectionsSpace: 2,
                                  startDegreeOffset: -90,
                                  pieTouchData: PieTouchData(enabled: true),
                                  sections: categoryTotals.entries.map((e) {
                                    final percent = totalExpense == 0
                                        ? 0
                                        : (e.value / totalExpense) * 100;
                                    final sectionColor = CategoryIcon.getColor(c.getCategoryName(e.key));
                                    return PieChartSectionData(
                                      color: sectionColor,
                                      value: e.value,
                                      radius: sectionRadius,
                                      showTitle: false,
                                      badgeWidget: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: sectionColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          "${percent.toStringAsFixed(0)}%",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      badgePositionPercentageOffset: 1.15,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: categoryTotals.entries.map((e) {
                            final percent = totalExpense == 0 ? 0 : (e.value / totalExpense) * 100;
                            final color = CategoryIcon.getColor(c.getCategoryName(e.key));
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.getCategoryName(e.key),
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              CurrencyFormat.format(e.value),
                                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade500, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "${percent.toStringAsFixed(0)}%",
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Divider(height: 1, color: Colors.grey.shade200),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.pie_chart_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total Pengeluaran", style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              FittedBox(
                                child: Text(CurrencyFormat.format(totalExpense), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 30, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 8)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Rata-rata harian", style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text("${CurrencyFormat.format(totalExpense / DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month))} / hari", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.info_outline_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tren Mingguan',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
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
                              return Text('M${v.toInt() + 1}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(weeklyTotals.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: weeklyTotals[i],
                              color: Theme.of(context).colorScheme.primary,
                              width: 24,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
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

  Widget _buildSimpleStatCard(
    BuildContext context, {
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required String growthText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormat.format(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            growthText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CategoryIcon(
                    category: c.getCategoryName(t.category),
                    size: 24,
                    backgroundColor: isIncome
                        ? Colors.greenAccent.withOpacity(0.15)
                        : Colors.redAccent.withOpacity(0.15),
                  ),
                  title: Text(
                    t.description.isEmpty
                        ? c.getCategoryName(t.category)
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
}
