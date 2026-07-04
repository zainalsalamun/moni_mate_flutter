import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../utils/format_currency.dart';
import '../controllers/wealth_timeline_controller.dart';
import 'wealth_timeline_page.dart';

class WealthTimelineDashboardCard extends StatelessWidget {
  const WealthTimelineDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WealthTimelineController>()) return const SizedBox.shrink();
    final controller = Get.find<WealthTimelineController>();

    return Obx(() {
      if (controller.snapshots.isEmpty) return const SizedBox.shrink();

      final latest = controller.snapshots.last;
      final recentSnapshots = controller.snapshots.length >= 6 
          ? controller.snapshots.sublist(controller.snapshots.length - 6)
          : controller.snapshots;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: GestureDetector(
          onTap: () => Get.to(() => const WealthTimelinePage()),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF3498DB)], // Dark Blue to Ocean
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3498DB).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NET WORTH JOURNEY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: latest.growthPercentMoM >= 0 
                            ? Colors.greenAccent.withOpacity(0.2)
                            : Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            latest.growthPercentMoM >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            color: latest.growthPercentMoM >= 0 ? Colors.greenAccent : Colors.redAccent,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${latest.growthPercentMoM.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: latest.growthPercentMoM >= 0 ? Colors.greenAccent : Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  CurrencyFormat.format(latest.netWorth),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Mini Line Chart
                SizedBox(
                  height: 60,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      minX: 0,
                      maxX: (recentSnapshots.length - 1).toDouble(),
                      minY: controller.allTimeLow.value * 0.9,
                      maxY: controller.allTimeHigh.value * 1.1,
                      lineBarsData: [
                        LineChartBarData(
                          spots: recentSnapshots.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.netWorth);
                          }).toList(),
                          isCurved: true,
                          color: Colors.white,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.0),
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ATH: ${CurrencyFormat.format(controller.allTimeHigh.value)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'ATL: ${CurrencyFormat.format(controller.allTimeLow.value)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
