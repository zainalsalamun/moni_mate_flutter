import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/monthly_report_model.dart';
import '../controllers/monthly_report_controller.dart';

class ReportPreviewPage extends StatelessWidget {
  final MonthlyReportModel report;

  const ReportPreviewPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MonthlyReportController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
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
                ),
              );
            },
          )
        ],
      ),
      body: report.imagePath != null && File(report.imagePath!).existsSync()
          ? InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.file(
                      File(report.imagePath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            )
          : const Center(
              child: Text('Preview gambar tidak tersedia.'),
            ),
    );
  }
}
