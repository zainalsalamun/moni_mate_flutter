import 'package:flutter/material.dart';
import 'package:monimate/features/monthly_report/views/report_image_template.dart';

void main() {
  runApp(
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
}
