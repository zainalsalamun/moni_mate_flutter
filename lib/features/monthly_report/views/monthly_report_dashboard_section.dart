import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/monthly_report_controller.dart';
import 'report_history_page.dart';
import 'report_preview_page.dart';

class MonthlyReportDashboardSection extends StatelessWidget {
  const MonthlyReportDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MonthlyReportController());

    return Obx(() {
      if (controller.reports.isEmpty && !controller.isGenerating.value) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Laporan Bulanan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => const ReportHistoryPage());
                  },
                  child: const Text('Lihat Semua'),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (controller.isGenerating.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              _buildLatestReportCard(context, controller),
          ],
        ),
      );
    });
  }

  Widget _buildLatestReportCard(BuildContext context, MonthlyReportController controller) {
    final report = controller.reports.first;
    final title = DateFormat('MMMM yyyy', 'id_ID').format(DateTime(report.year, report.month));

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => ReportPreviewPage(report: report));
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Laporan bulan lalu telah siap!', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.blueAccent),
              onPressed: () {
                // Show bottom sheet to choose PDF or Image
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          title: const Text('Bagikan sebagai PDF'),
                          onTap: () {
                            Navigator.pop(ctx);
                            controller.shareReport(report, shareImage: false);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.image, color: Colors.blue),
                          title: const Text('Bagikan ke Story (PNG)'),
                          onTap: () {
                            Navigator.pop(ctx);
                            controller.shareReport(report, shareImage: true);
                          },
                        ),
                      ],
                    ),
                  )
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }
}
