import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportImageTemplate extends StatelessWidget {
  final Map<String, dynamic> data;
  final int month;
  final int year;

  const ReportImageTemplate({
    super.key,
    required this.data,
    required this.month,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 1);
    final percentFormat = NumberFormat.percentPattern('id_ID');

    final double healthScore = (data['healthScore'] as num?)?.toDouble() ?? 0.0;
    final double netWorth = (data['netWorth'] as num?)?.toDouble() ?? 0.0;
    final double savingRate = (data['savingRate'] as num?)?.toDouble() ?? 0.0;
    final double closestProgress = (data['closestProgress'] as num?)?.toDouble() ?? 0.0;

    return MediaQuery(
      data: const MediaQueryData(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 1080,
          height: 1920,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)], // Ocean / Space theme
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.all(80.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF48C6EF), size: 60),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MoniMate',
                        style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Monthly Report • ${DateFormat('MMMM yyyy', 'id_ID').format(DateTime(year, month))}",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
            
            // Grid Stats
            Expanded(
              child: GridView.count(
                primary: false,
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                crossAxisSpacing: 60,
                mainAxisSpacing: 60,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard('Financial Health', healthScore.toStringAsFixed(0), Icons.favorite, Colors.pinkAccent),
                  _buildStatCard('Net Worth', currencyFormat.format(netWorth), Icons.account_balance_wallet, Colors.greenAccent),
                  _buildStatCard('Saving Rate', percentFormat.format(savingRate), Icons.savings, Colors.amberAccent),
                  _buildStatCard('Goal Progress', percentFormat.format(closestProgress), Icons.flag, Colors.blueAccent),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            // Insights
            Container(
              padding: const EdgeInsets.all(60),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 AI Insights', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72))),
                  const SizedBox(height: 40),
                  ...List.generate((data['insights'] as List).length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF48C6EF))),
                          Expanded(
                            child: Text(
                              data['insights'][index],
                              style: const TextStyle(fontSize: 32, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 60),
            const Text('Generated securely by MoniMate AI', style: TextStyle(color: Colors.white54, fontSize: 24)),
          ],
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: color.withOpacity(0.5), width: 4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: color),
          const SizedBox(height: 40),
          Text(value, style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          Text(title, style: TextStyle(fontSize: 36, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }
}
