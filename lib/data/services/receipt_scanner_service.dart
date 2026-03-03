import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:monimate/utils/clean_currency.dart';

class ReceiptScannerService {
  static Future<Map<String, dynamic>?> scanReceipt() async {
    final ImagePicker picker = ImagePicker();

    // 1. Pick Image
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image == null) return null;

    // Show loading dialog
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Menganalisis Struk dengan AI..."),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String fullText = recognizedText.text;
      double? amount = _extractAmount(fullText);
      String merchant = _extractMerchant(recognizedText.blocks);

      await textRecognizer.close();
      if (Get.isDialogOpen ?? false) {
        Navigator.of(Get.overlayContext!).pop();
      }

      return {
        'amount': amount,
        'merchant': merchant,
      };
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Navigator.of(Get.overlayContext!).pop();
      }
      Get.snackbar("Error", "Gagal memproses gambar: $e");
      return null;
    }
  }

  static double? _extractAmount(String text) {
    // Regex logic to find currency-like patterns
    // Focus on finding large numbers often preceded by "TOTAL", "TOTAL BAYAR", "RP", etc.
    final List<String> lines = text.split('\n');
    double maxVal = 0;

    for (var line in lines) {
      String cleanLine =
          line.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9.,]'), '');

      // Look for lines containing total keywords
      if (cleanLine.contains("TOTAL") ||
          cleanLine.contains("AMOUNT") ||
          cleanLine.contains("BAYAR")) {
        final reg = RegExp(r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})?)');
        final matches = reg.allMatches(line);
        for (var m in matches) {
          double val = cleanCurrency(m.group(0)!);
          if (val > maxVal) maxVal = val;
        }
      }
    }

    if (maxVal > 0) return maxVal;

    // Fallback: search for any number > 1000 that looks like a total
    final reg = RegExp(r'(\d{1,3}(?:[.,]\d{3})+)');
    final matches = reg.allMatches(text);
    for (var m in matches) {
      double val = cleanCurrency(m.group(0)!);
      if (val > maxVal) maxVal = val;
    }

    return maxVal > 0 ? maxVal : null;
  }

  static String _extractMerchant(List<TextBlock> blocks) {
    if (blocks.isEmpty) return "";

    // Merhcant is usually in the first block or at the top
    // We take the first non-numeric line that has more than 3 characters
    for (var block in blocks) {
      for (var line in block.lines) {
        String t = line.text.trim();
        if (t.length > 3 && !RegExp(r'^\d+$').hasMatch(t)) {
          return t;
        }
      }
    }
    return "";
  }
}
