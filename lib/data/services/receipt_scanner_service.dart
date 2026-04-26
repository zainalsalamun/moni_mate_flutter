import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReceiptScannerService {
  // Mengambil API Key dari file .env agar aman jika dipush ke GitHub publik
  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<Map<String, dynamic>?> scanReceipt() async {
    // 1. Peringatan jika API Key belum diisi
    if (_geminiApiKey == 'ISI_API_KEY_ANDA_DISINI' || _geminiApiKey.isEmpty) {
      Get.snackbar(
        "API Key Belum Diisi",
        "Silakan masukkan API Key Gemini Anda di baris 11 file receipt_scanner_service.dart",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
      );
      return null;
    }

    final ImagePicker picker = ImagePicker();

    // 2. Ambil gambar dari kamera bawaan HP
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image == null) return null;

    // 3. Tampilkan Loading Dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 24),
              const Text(
                "Menganalisa dengan AI...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "AI sedang mengekstrak nama toko dan total harga dari struk Anda.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(Get.context!)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // 4. Proses dengan Gemini API
    try {
      final imageBytes = await File(image.path).readAsBytes();
      final imagePart = DataPart('image/jpeg', imageBytes);

      // Prompt instruksi tegas agar outputnya pasti berformat JSON
      final prompt = TextPart('''
Analyze this receipt image and extract the main total amount (usually the final price paid) and the merchant/store name.
Return ONLY a raw JSON string exactly in this format without any markdown blocks or backticks:
{
  "merchant": "Store Name",
  "amount": 15000
}
Note: Ensure the amount is a plain number (integer or float) without currency symbols, commas, or dots as thousands separators. For example, if it says Rp 43.500, return 43500. If you cannot find the information, return null for that specific field.
''');

      // Daftar model yang didukung dari yang paling umum hingga *legacy*
      final List<String> availableModels = [
        'gemini-1.5-flash',
        'gemini-1.5-pro',
        'gemini-pro-vision',
        'gemini-1.5-flash-latest'
      ];

      GenerateContentResponse? response;
      String? lastError;

      // Coba satu per satu model sampai ada yang berhasil
      for (String modelName in availableModels) {
        try {
          debugPrint("Mencoba model Gemini: $modelName...");
          final model = GenerativeModel(
            model: modelName,
            apiKey: _geminiApiKey,
          );

          response = await model.generateContent([
            Content.multi([prompt, imagePart])
          ]);

          debugPrint("Berhasil menggunakan model: $modelName");
          break; // Keluar dari loop jika berhasil
        } catch (e) {
          debugPrint("Gagal menggunakan model $modelName: $e");
          lastError = e.toString();
        }
      }

      if (response == null) {
        debugPrint("Gemini Gagal. Mengalihkan ke ML Kit AI Offline...");
        throw Exception(
            "Semua model Gemini gagal diakses. Error terakhir: $lastError");
      }

      if (Get.isDialogOpen == true) {
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }

      final textResponse = response.text?.trim() ?? '';

      String cleanedJson =
          textResponse.replaceAll('```json', '').replaceAll('```', '').trim();

      debugPrint("--- GEMINI JSON RAW OUTPUT ---");
      debugPrint(cleanedJson);
      debugPrint("------------------------------");

      try {
        final Map<String, dynamic> data = jsonDecode(cleanedJson);
        return {
          'merchant': data['merchant'] ?? '',
          'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
        };
      } catch (e) {
        debugPrint("!!! GEMINI JSON DECODE ERROR !!!");
        debugPrint("Raw Response: $textResponse");
        throw Exception(
            "Gagal mengenali teks struk. Pastikan foto struk terlihat cerah dan jelas.");
      }
    } catch (e) {
      // ==========================================================
      // FALLBACK KE ML KIT (AI OFFLINE) JIKA GEMINI GAGAL / ERROR
      // ==========================================================
      debugPrint(
          "Gagal menggunakan Gemini AI, mencoba ML Kit Text Recognition...");

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

        if (Get.isDialogOpen == true) {
          Navigator.of(Get.context!, rootNavigator: true).pop();
        }

        return {
          'amount': amount,
          'merchant': merchant,
        };
      } catch (mlKitError) {
        if (Get.isDialogOpen == true) {
          Navigator.of(Get.context!, rootNavigator: true).pop();
        }
        throw Exception("Gemini & ML Kit gagal memproses gambar.");
      }
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
          double val = _cleanReceiptCurrency(m.group(0)!);
          if (val > maxVal) maxVal = val;
        }
      }
    }

    if (maxVal > 0) return maxVal;

    // Fallback: search for any number > 1000 that looks like a total
    final reg = RegExp(r'(\d{1,3}(?:[.,]\d{3})+)');
    final matches = reg.allMatches(text);
    for (var m in matches) {
      double val = _cleanReceiptCurrency(m.group(0)!);
      if (val > maxVal) maxVal = val;
    }

    return maxVal > 0 ? maxVal : null;
  }

  static double _cleanReceiptCurrency(String text) {
    // Menghapus apapun selain angka, koma, dan titik
    String cleaned = text.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (cleaned.isEmpty) return 0;

    // Jika ada koma dan titik (misal 15.000,00 atau 15,000.00)
    if (cleaned.contains(',') && cleaned.contains('.')) {
      int lastComma = cleaned.lastIndexOf(',');
      int lastDot = cleaned.lastIndexOf('.');
      int decimalIndex = lastComma > lastDot ? lastComma : lastDot;

      String mainPart =
          cleaned.substring(0, decimalIndex).replaceAll(RegExp(r'[.,]'), '');
      String decPart = cleaned.substring(decimalIndex + 1);
      return double.tryParse('$mainPart.$decPart') ?? 0;
    }

    // Jika hanya ada koma atau hanya titik
    int sepIndex = cleaned.lastIndexOf(RegExp(r'[.,]'));
    if (sepIndex != -1) {
      int digitsAfter = cleaned.length - sepIndex - 1;
      // Jika ada persis 3 digit di belakang separator, itu PASTI ribuan (e.g., 43.500 atau 43,500)
      if (digitsAfter == 3) {
        return double.tryParse(cleaned.replaceAll(RegExp(r'[.,]'), '')) ?? 0;
      }
      // Jika ada 1 atau 2 digit, kemungkinan itu desimal (e.g., 15000.00)
      else if (digitsAfter == 2 || digitsAfter == 1) {
        String mainPart =
            cleaned.substring(0, sepIndex).replaceAll(RegExp(r'[.,]'), '');
        String decPart = cleaned.substring(sepIndex + 1);
        return double.tryParse('$mainPart.$decPart') ?? 0;
      }
    }

    // Jika tidak ada separator, kembalikan angkanya utuh
    return double.tryParse(cleaned.replaceAll(RegExp(r'[.,]'), '')) ?? 0;
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
