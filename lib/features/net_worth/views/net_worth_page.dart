import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../utils/format_currency.dart';
import '../controllers/net_worth_controller.dart';
import '../../../theme/app_theme.dart';

class NetWorthPage extends StatefulWidget {
  const NetWorthPage({super.key});

  @override
  State<NetWorthPage> createState() => _NetWorthPageState();
}

class _NetWorthPageState extends State<NetWorthPage> {
  final NetWorthController nwc = Get.find<NetWorthController>();
  int touchedIndex = -1;
  int _selectedTrend = 12; // months

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Net Worth Detail'),
        centerTitle: true,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummarySection(context),
              const SizedBox(height: 24),
              _buildAIInsightsSection(context),
              const SizedBox(height: 24),
              _buildAssetBreakdownSection(context),
              const SizedBox(height: 24),
              _buildLiabilityBreakdownSection(context),
              const SizedBox(height: 24),
              _buildGrowthTrendSection(context),
              const SizedBox(height: 24),
              _buildWalletAnalyticsSection(context),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.oceanGradient(),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL NET WORTH', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormat.format(nwc.netWorth.value),
              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Asset', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormat.format(nwc.totalAssets.value),
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Hutang', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormat.format(nwc.totalLiabilities.value),
                        style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsSection(BuildContext context) {
    if (nwc.aiInsights.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('AI Financial Insight', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ...nwc.aiInsights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(insight, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAssetBreakdownSection(BuildContext context) {
    final breakdown = nwc.getAssetBreakdown();
    final colors = {
      'Cash': Colors.green,
      'Bank': Colors.blue,
      'E-Wallet': Colors.cyan,
      'Investment': Colors.purple,
    };
    
    // Check if total assets > 0
    if (nwc.totalAssets.value <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distribusi Asset', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: breakdown.entries.map((entry) {
                final isTouched = breakdown.keys.toList().indexOf(entry.key) == touchedIndex;
                final fontSize = isTouched ? 16.0 : 12.0;
                final radius = isTouched ? 60.0 : 50.0;
                final value = entry.value;
                return PieChartSectionData(
                  color: colors[entry.key],
                  value: value,
                  title: '${((value / nwc.totalAssets.value) * 100).toStringAsFixed(1)}%',
                  radius: radius,
                  titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).where((section) => section.value > 0).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...breakdown.entries.where((e) => e.value > 0).map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[entry.key], shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(entry.key)),
              Text(CurrencyFormat.format(entry.value), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildLiabilityBreakdownSection(BuildContext context) {
    final breakdown = nwc.getLiabilityBreakdown();
    if (nwc.totalLiabilities.value <= 0) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distribusi Hutang', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...breakdown.entries.where((e) => e.value > 0).map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(entry.key == 'Credit Card' ? Icons.credit_card : Icons.receipt_long, color: Colors.redAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(CurrencyFormat.format(entry.value), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildGrowthTrendSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trend Net Worth', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            DropdownButton<int>(
              value: _selectedTrend,
              items: const [
                DropdownMenuItem(value: 3, child: Text('3 Bulan')),
                DropdownMenuItem(value: 6, child: Text('6 Bulan')),
                DropdownMenuItem(value: 12, child: Text('12 Bulan')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedTrend = val);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.only(top: 20, right: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2D3748)
                  : const Color(0xFFEDF2F7),
            ),
          ),
          child: Builder(builder: (context) {
            final trendData = nwc.getGrowthTrend(_selectedTrend);
            final keys = trendData.keys.toList();
            final values = trendData.values.toList();
            double maxY = values.isEmpty ? 100 : values.reduce((a, b) => a > b ? a : b);
            if (maxY <= 0) maxY = 100000;
            
            return BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Theme.of(context).colorScheme.primary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${keys[groupIndex]}\n${CurrencyFormat.format(rod.toY)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(keys[value.toInt()], style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        color: Theme.of(context).colorScheme.primary,
                        width: _selectedTrend == 12 ? 12 : 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      )
                    ],
                  );
                }),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWalletAnalyticsSection(BuildContext context) {
    final largest = nwc.getLargestWallet();
    final active = nwc.getMostActiveWallet();
    
    if (largest == null && active == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analisis Dompet', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            if (largest != null)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2D3748)
                          : const Color(0xFFEDF2F7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dompet Terbesar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(largest['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${largest['percentage'].toStringAsFixed(1)}% dari aset', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
              ),
            if (largest != null && active != null) const SizedBox(width: 16),
            if (active != null)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2D3748)
                          : const Color(0xFFEDF2F7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Paling Aktif', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(active['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('${active['count']} transaksi', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
