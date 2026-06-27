import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/services/hive_service.dart';
import 'financial_brief_page.dart';

class DailyBriefCard extends StatelessWidget {
  const DailyBriefCard({super.key});

  @override
  Widget build(BuildContext context) {
    // We can use Obx if we use a controller, but for now let's just fetch latest
    // Assuming Hive box triggers rebuild via ValueListenableBuilder if needed,
    // or just fetch once when Dashboard builds. To be reactive, let's use ValueListenableBuilder

    return ValueListenableBuilder(
      valueListenable: HiveService.dailyBriefBox.listenable(),
      builder: (context, box, _) {
        final briefs = box.values.toList()
          ..sort((a, b) => b.generatedAt.compareTo(a.generatedAt));

        if (briefs.isEmpty) {
          return const SizedBox.shrink();
        }

        final latest = briefs.first;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: GestureDetector(
            onTap: () {
              latest.isRead = true;
              latest.save();
              Get.to(() => const FinancialBriefPage());
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(isDark ? 0.2 : 0.1),
                    Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(isDark ? 0.2 : 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              latest.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm')
                                  .format(latest.generatedAt),
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
                      if (!latest.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRichText(context, latest.summary),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRichText(BuildContext context, String text) {
    final style = TextStyle(
      fontSize: 14,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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

    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}
