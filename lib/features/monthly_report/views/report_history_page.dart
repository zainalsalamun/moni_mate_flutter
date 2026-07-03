import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/monthly_report_controller.dart';
import '../models/monthly_report_model.dart';
import 'report_preview_page.dart';

class ReportHistoryPage extends StatelessWidget {
  const ReportHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final controller = Get.put(MonthlyReportController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isGenerating.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating report...'),
              ],
            ),
          );
        }

        if (controller.reports.isEmpty) {
          return const Center(
            child: Text(
              'No reports available yet.\\nReports are generated automatically at the start of every month.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.reports.length,
          itemBuilder: (context, index) {
            final report = controller.reports[index];
            return _buildReportCard(context, controller, report);
          },
        );
      }),
    );
  }

  Widget _buildReportCard(BuildContext context, MonthlyReportController controller, MonthlyReportModel report) {
    final title = DateFormat('MMMM yyyy', 'id_ID').format(DateTime(report.year, report.month));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Get.to(() => ReportPreviewPage(report: report));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.insert_chart,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Generated: ${DateFormat('dd MMM yyyy HH:mm').format(report.generatedAt)}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Hapus Laporan",
                      middleText: "Apakah Anda yakin ingin menghapus laporan ini?",
                      textConfirm: "Hapus",
                      textCancel: "Batal",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        controller.deleteReport(report.id);
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => controller.shareReport(report, shareImage: false),
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                  label: const Text('Share PDF'),
                ),
                TextButton.icon(
                  onPressed: () => controller.shareReport(report, shareImage: true),
                  icon: const Icon(Icons.image, color: Colors.blueAccent),
                  label: const Text('Share Card'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
