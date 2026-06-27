import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/services/hive_service.dart';
import '../models/daily_financial_brief_model.dart';

class FinancialBriefPage extends StatelessWidget {
  const FinancialBriefPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Coach Brief'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.dailyBriefBox.listenable(),
        builder: (context, box, _) {
          final briefs = box.values.toList()
            ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

          if (briefs.isEmpty) {
            return const Center(
              child: Text('Belum ada financial brief hari ini.'),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              20, 
              20, 
              20, 
              20 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: briefs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final brief = briefs[index];
              return _buildBriefItem(context, brief);
            },
          );
        },
      ),
    );
  }

  Widget _buildBriefItem(BuildContext context, DailyFinancialBriefModel brief) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine icon and color based on priority
    IconData icon = Icons.info_outline;
    Color color = Theme.of(context).colorScheme.primary;

    switch (brief.priority) {
      case DailyBriefPriority.info:
        icon = Icons.insights_rounded;
        break;
      case DailyBriefPriority.success:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case DailyBriefPriority.warning:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case DailyBriefPriority.danger:
        icon = Icons.error_outline;
        color = Colors.redAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D3748) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brief.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, dd MMM yyyy • HH:mm')
                          .format(brief.generatedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRichText(context, brief.summary),
        ],
      ),
    );
  }

  Widget _buildRichText(BuildContext context, String text) {
    final style = TextStyle(
      fontSize: 14,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
    );
    final boldStyle = style.copyWith(fontWeight: FontWeight.bold);

    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return RichText(text: TextSpan(style: style, children: spans));
  }
}
