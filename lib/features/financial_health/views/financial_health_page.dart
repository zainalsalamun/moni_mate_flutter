import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/financial_health_controller.dart';

class FinancialHealthPage extends StatelessWidget {
  const FinancialHealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FinancialHealthController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => c.calculateScore(),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.score.value == null) {
          return const Center(child: Text('Gagal memuat data'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _ScoreRing(score: c.totalScore),
              const SizedBox(height: 8),
              Text(
                FinancialHealthController.getScoreLabel(c.totalScore),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: FinancialHealthController.getScoreColor(c.totalScore),
                ),
              ),
              const SizedBox(height: 24),
              _BreakdownCard(c: c),
              const SizedBox(height: 16),
              _InsightsCard(c: c),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Animated Score Ring ────────────────────────────────────────────
class _ScoreRing extends StatefulWidget {
  final double score;
  const _ScoreRing({required this.score});

  @override
  State<_ScoreRing> createState() => _ScoreRingState();
}

class _ScoreRingState extends State<_ScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animation = Tween<double>(begin: 0, end: widget.score / 100).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = FinancialHealthController.getScoreColor(widget.score);
    final emoji = FinancialHealthController.getScoreEmoji(widget.score);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.06),
                ),
              ),
              // Score arc
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: _animation.value,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  color: color,
                ),
              ),
              // Center text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 2),
                  Text(
                    widget.score.toStringAsFixed(0),
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Breakdown Card ─────────────────────────────────────────────────
class _BreakdownCard extends StatelessWidget {
  final FinancialHealthController c;
  const _BreakdownCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final items = [
      _ScoreItem('Budget', c.budgetScore, 30,
          Icons.account_balance_wallet_rounded, 'Budget compliance'),
      _ScoreItem(
          'Goals', c.goalScore, 25, Icons.flag_rounded, 'Target progress'),
      _ScoreItem(
          'Saving', c.savingScore, 20, Icons.savings_rounded, 'Saving ratio'),
      _ScoreItem('Trend', c.trendScore, 15, Icons.trending_up_rounded,
          'Spending trend'),
      _ScoreItem('Darurat', c.emergencyScore, 10, Icons.shield_rounded,
          'Emergency fund'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D3748)
              : const Color(0xFFEDF2F7),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Skor',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildBar(context, item)),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, _ScoreItem item) {
    final color = FinancialHealthController.getScoreColor(
      (item.score / item.max) * 100,
    );
    final fraction = item.score / item.max;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${item.score.toStringAsFixed(0)} / ${item.max.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreItem {
  final String label;
  final double score;
  final double max;
  final IconData icon;
  final String desc;
  _ScoreItem(this.label, this.score, this.max, this.icon, this.desc);
}

// ─── Insights Card ──────────────────────────────────────────────────
class _InsightsCard extends StatelessWidget {
  final FinancialHealthController c;
  const _InsightsCard({required this.c});

  @override
  Widget build(BuildContext context) {
    if (c.insights.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D3748)
              : const Color(0xFFEDF2F7),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Insight',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...c.insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        insight,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
