import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/predictive_insight_controller.dart';
import 'predictive_insight_card.dart';

class PredictiveInsightPage extends StatefulWidget {
  const PredictiveInsightPage({super.key});

  @override
  State<PredictiveInsightPage> createState() => _PredictiveInsightPageState();
}

class _PredictiveInsightPageState extends State<PredictiveInsightPage> {
  final PredictiveInsightController controller = Get.find<PredictiveInsightController>();
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua',
    'Budget',
    'Goals',
    'Recurring',
    'Net Worth',
    'Wallet'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictive Coach'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter section
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                );
              },
            ),
          ),
          
          // Status bar
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(
                  controller.isOfflineMode.value ? Icons.cloud_off : Icons.cloud_done,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.isOfflineMode.value 
                      ? 'Menampilkan insight lokal (offline)' 
                      : 'Disinkronkan dengan AI',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (controller.insights.isNotEmpty)
                  Text(
                    "Terakhir: ${DateFormat('HH:mm').format(controller.insights.first.createdAt)}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          )),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.insights.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredInsights = controller.insights.where((insight) {
                if (_selectedFilter == 'Semua') return true;
                if (_selectedFilter == 'Budget' && insight.type == 'budget_prediction') return true;
                if (_selectedFilter == 'Goals' && insight.type == 'goal_prediction') return true;
                if (_selectedFilter == 'Recurring' && insight.type == 'recurring_impact') return true;
                if (_selectedFilter == 'Net Worth' && insight.type == 'net_worth') return true;
                if (_selectedFilter == 'Wallet' && insight.type == 'wallet_health') return true;
                return false;
              }).toList();

              if (filteredInsights.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada insight untuk kategori ini',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  controller.refreshInsights(forceApi: true);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredInsights.length,
                  itemBuilder: (context, index) {
                    return PredictiveInsightCard(insight: filteredInsights[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
