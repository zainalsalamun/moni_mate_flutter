import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../utils/format_currency.dart';
import '../controllers/wealth_timeline_controller.dart';
import '../controllers/net_worth_controller.dart';

class WealthTimelinePage extends StatelessWidget {
  const WealthTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WealthTimelineController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wealth Timeline',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              // Export PDF logic will be handled here
              Get.snackbar('Export', 'Fitur export sedang dipersiapkan.');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            if (controller.snapshots.isEmpty) {
              return const Center(child: Text('Belum ada histori kekayaan.'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryHeader(controller, context),
                const SizedBox(height: 24),
                _buildTimelineChart(controller, context),
                const SizedBox(height: 24),
                _buildGrowthStatistics(controller, context),
                const SizedBox(height: 24),
                _buildAssetComposition(context),
                const SizedBox(height: 24),
                _buildMilestones(controller, context),
                const SizedBox(height: 24),
                _buildJourneyTimeline(controller, context),
                const SizedBox(height: 40),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(
      WealthTimelineController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Net Worth',
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            CurrencyFormat.format(controller.currentNetWorth.value),
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGrowthIndicator('MoM', controller.currentMoMGrowth.value),
              _buildGrowthIndicator('YoY', controller.currentYoYGrowth.value),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('All-Time High',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Text(CurrencyFormat.format(controller.allTimeHigh.value),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('All-Time Low',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Text(CurrencyFormat.format(controller.allTimeLow.value),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthIndicator(String label, double percent) {
    final isPositive = percent >= 0;
    return Row(
      children: [
        Text('$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isPositive
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Colors.green : Colors.red, size: 10),
              const SizedBox(width: 2),
              Text('${percent.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineChart(
      WealthTimelineController controller, BuildContext context) {
    final snapshots = controller.filteredSnapshots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Net Worth Timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.only(top: 20, right: 20, bottom: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.blue.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ],
          ),
          child: snapshots.isEmpty
              ? const Center(child: Text('No Data'))
              : LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: snapshots.length > 6
                              ? (snapshots.length / 5).ceilToDouble()
                              : 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < snapshots.length) {
                              final s = snapshots[value.toInt()];
                              final monthStr = DateFormat('MMM')
                                  .format(DateTime(0, s.month));
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(monthStr,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final s = snapshots[spot.x.toInt()];
                            return LineTooltipItem(
                              '${DateFormat('MMMM yyyy').format(DateTime(s.year, s.month))}\n',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              children: [
                                TextSpan(
                                  text: CurrencyFormat.format(s.netWorth),
                                  style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
                    minX: 0,
                    maxX: (snapshots.length - 1).toDouble(),
                    minY: controller.allTimeLow.value * 0.8,
                    maxY: controller.allTimeHigh.value * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: snapshots
                            .asMap()
                            .entries
                            .map((e) =>
                                FlSpot(e.key.toDouble(), e.value.netWorth))
                            .toList(),
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withOpacity(0.3),
                              Colors.blueAccent.withOpacity(0.0)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['6M', '1Y', '2Y', 'ALL'].map((range) {
              final isSelected = controller.selectedRange.value == range;
              return GestureDetector(
                onTap: () => controller.changeRange(range),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blueAccent
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    range,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthStatistics(
      WealthTimelineController controller, BuildContext context) {
    final best = controller.bestMonth;
    final worst = controller.worstMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Growth Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.blue.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            children: [
              _buildStatRow(
                  'Avg. Monthly Growth',
                  '${controller.avgMonthlyGrowth.value.toStringAsFixed(1)}%',
                  Icons.show_chart,
                  Colors.blue),
              const Divider(height: 24),
              if (best != null)
                _buildStatRow(
                    'Best Month (${DateFormat('MMM yyyy').format(DateTime(best.year, best.month))})',
                    '+${best.growthPercentMoM.toStringAsFixed(1)}%',
                    Icons.arrow_upward,
                    Colors.green),
              if (best != null && worst != null) const Divider(height: 24),
              if (worst != null)
                _buildStatRow(
                    'Worst Month (${DateFormat('MMM yyyy').format(DateTime(worst.year, worst.month))})',
                    '${worst.growthPercentMoM.toStringAsFixed(1)}%',
                    Icons.arrow_downward,
                    Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      ],
    );
  }

  Widget _buildAssetComposition(BuildContext context) {
    final nwController = Get.find<NetWorthController>();
    final assets = nwController.getAssetBreakdown();
    final liabilities = nwController.getLiabilityBreakdown();

    // Simplification for the current state
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Current Composition',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.blue.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ],
          ),
          child: Column(
            children: [
              ...assets.entries.map((e) => _buildStatRow(
                  e.key,
                  CurrencyFormat.format(e.value),
                  Icons.account_balance_wallet,
                  Colors.green)),
              const Divider(height: 24),
              ...liabilities.entries.map((e) => _buildStatRow(
                  e.key,
                  CurrencyFormat.format(e.value),
                  Icons.credit_card,
                  Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMilestones(
      WealthTimelineController controller, BuildContext context) {
    // Generate Milestones dynamically based on allTimeHigh
    final List<double> thresholds = [
      10000000,
      25000000,
      50000000,
      100000000,
      250000000,
      500000000,
      1000000000
    ];
    List<Widget> unlocked = [];

    for (var t in thresholds) {
      if (controller.allTimeHigh.value >= t) {
        unlocked.add(Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Text('Net Worth mencapai ${CurrencyFormat.format(t)} 🎉',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ));
      }
    }

    if (unlocked.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Milestones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: unlocked),
        ),
      ],
    );
  }

  Widget _buildJourneyTimeline(
      WealthTimelineController controller, BuildContext context) {
    final reversed = controller.snapshots.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reversed.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final s = reversed[index];
            final isPositive = s.growthPercentMoM >= 0;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                  DateFormat('MMMM yyyy').format(DateTime(s.year, s.month)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                  'Assets: ${CurrencyFormat.format(s.totalAssets)} • Liab: ${CurrencyFormat.format(s.totalLiabilities)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormat.format(s.netWorth),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    '${isPositive ? '+' : ''}${s.growthPercentMoM.toStringAsFixed(1)}%',
                    style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
