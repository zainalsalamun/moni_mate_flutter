import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'features/monthly_report/views/report_image_template.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  testWidgets('ReportImageTemplate capture test', (WidgetTester tester) async {
    final controller = ScreenshotController();
    try {
      await controller.captureFromWidget(
        const MediaQuery(
          data: MediaQueryData(),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              child: ReportImageTemplate(
                data: {
                  'healthScore': 80.0,
                  'netWorth': 100000.0,
                  'savingRate': 0.2,
                  'closestProgress': 0.5,
                  'insights': ['Insight 1']
                },
                month: 6,
                year: 2026,
              ),
            ),
          ),
        ),
      );
      print("SUCCESS");
    } catch (e, stack) {
      print("ERROR: \$e");
      print(stack);
    }
  });
}
