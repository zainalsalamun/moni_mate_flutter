import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'receipt_result_page.dart';

class AnalyzeReceiptPage extends StatefulWidget {
  final String imagePath;
  const AnalyzeReceiptPage({super.key, required this.imagePath});

  @override
  State<AnalyzeReceiptPage> createState() => _AnalyzeReceiptPageState();
}

class _AnalyzeReceiptPageState extends State<AnalyzeReceiptPage> {
  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    final recognizer = TextRecognizer();
    final input = InputImage.fromFilePath(widget.imagePath);

    final text = await recognizer.processImage(input);
    final rawText = text.text;

    recognizer.close();

    final result = _parseStruk(rawText);

    await Future.delayed(const Duration(seconds: 1));

    Get.off(() => ReceiptResultPage(
          result: result,
          imagePath: widget.imagePath,
        ));
  }

  Map<String, dynamic> _parseStruk(String raw) {
    final upper = raw.toUpperCase();

    final total = _extractTotal(upper);

    final date1 = RegExp(r"\d{2}/\d{2}/\d{4}");
    final date2 = RegExp(
        r"\d{1,2}\s+(JANUARI|FEBRUARI|MARET|APRIL|MEI|JUNI|JULI|AGUSTUS|SEPTEMBER|OKTOBER|NOVEMBER|DESEMBER)\s+\d{4}");

    String? tanggal =
        date1.firstMatch(upper)?.group(0) ?? date2.firstMatch(upper)?.group(0);

    String merchant = "Tidak diketahui";
    if (upper.contains("INDOMARET")) merchant = "Indomaret";
    if (upper.contains("ALFAMART")) merchant = "Alfamart";
    if (upper.contains("MINIMARKET")) merchant = "Minimarket";
    if (upper.contains("ALFAMIDI")) merchant = "Alfamidi";
    if (upper.contains("PERTAMAX") || upper.contains("PERTAMINA")) {
      merchant = "SPBU Pertamina";
    }

    return {
      "total": total,
      "tanggal": tanggal,
      "merchant": merchant,
      "raw": raw,
    };
  }

  String? _extractTotal(String text) {
    final lines = text.split('\n');

    for (final line in lines) {
      final upper = line.toUpperCase();

      if (upper.contains("TOTAL") ||
          upper.contains("JUMLAH") ||
          upper.contains("BAYAR")) {
        final reg = RegExp(r"(\d[\d\.\,]*)");
        final match = reg.firstMatch(upper);

        if (match != null) {
          String raw = match.group(1)!;

          raw = raw.replaceAll('.', '').replaceAll(',', '.');

          return raw;
        }
      }
    }

    final allNums = RegExp(r"\d[\d\.\,]+").allMatches(text);
    if (allNums.isNotEmpty) {
      String raw = allNums.last.group(0)!;
      raw = raw.replaceAll('.', '').replaceAll(',', '.');
      return raw;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              "Menganalisa Struk",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            const Text(
              "Pastikan struk terlihat jelas.\nProses ini membutuhkan beberapa detik.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(widget.imagePath),
                        width: 300,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // overlay grid
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _ScanGridPainter(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFF48C6EF)),
            const SizedBox(height: 16),
            const Text(
              "Membaca struk...",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ScanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.25)
      ..strokeWidth = 1;

    for (int i = 1; i < 12; i++) {
      final y = size.height * i / 12;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
