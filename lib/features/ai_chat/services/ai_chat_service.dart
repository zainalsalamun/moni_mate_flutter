import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class AiChatService {
  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static bool get isApiKeyAvailable =>
      _geminiApiKey.isNotEmpty && _geminiApiKey != 'ISI_API_KEY_ANDA_DISINI';

  /// Sends a message to Gemini with financial assistant context.
  /// Returns a Map with 'reply' (String) and optionally 'action' data.
  static Future<Map<String, dynamic>> sendMessage(
    String userMessage, {
    List<Map<String, dynamic>>? transactionSummary,
    double? totalIncome,
    double? totalExpense,
  }) async {
    if (!isApiKeyAvailable) {
      return {
        'reply':
            'API Key belum diisi. Silakan masukkan GEMINI_API_KEY di file .env.',
        'action': null,
      };
    }

    // Build context about the user's financial data
    String financialContext = '';
    if (totalIncome != null && totalExpense != null) {
      financialContext +=
          'Total pemasukan pengguna: Rp ${totalIncome.toStringAsFixed(0)}\n';
      financialContext +=
          'Total pengeluaran pengguna: Rp ${totalExpense.toStringAsFixed(0)}\n';
      financialContext +=
          'Saldo: Rp ${(totalIncome - totalExpense).toStringAsFixed(0)}\n';
    }
    if (transactionSummary != null && transactionSummary.isNotEmpty) {
      financialContext += 'Transaksi terakhir:\n';
      for (var tx in transactionSummary.take(10)) {
        financialContext +=
            '- ${tx['type'] == 'income' ? 'Pemasukan' : 'Pengeluaran'}: ${tx['category']} Rp ${tx['amount']} (${tx['description']})\n';
      }
    }

    final systemPrompt = '''
Kamu adalah MoniMate AI, asisten keuangan pribadi yang ramah dan membantu.
Kamu berbicara dalam bahasa Indonesia dengan gaya santai dan friendly.

TUGAS UTAMA:
1. Jika pengguna ingin MENAMBAH TRANSAKSI, ekstrak data dan kembalikan JSON action.
2. Jika pengguna BERTANYA tentang keuangan mereka, jawab berdasarkan data yang diberikan.
3. Jika pengguna bertanya TIPS keuangan, berikan saran yang praktis.

ATURAN OUTPUT:
- Selalu balas dengan JSON yang valid TANPA markdown code blocks
- Format respons:
{
  "reply": "Teks balasan untuk pengguna",
  "action": null,
  "action_type": null
}

JIKA PENGGUNA INGIN MENAMBAH TRANSAKSI (expense/pengeluaran atau income/pemasukan):
{
  "reply": "Konfirmasi ke pengguna bahwa transaksi akan ditambahkan",
  "action_type": "add_transaction",
  "action": {
    "type": "expense" atau "income",
    "category": "nama_kategori_lowercase",
    "amount": angka_tanpa_titik_koma,
    "description": "deskripsi_transaksi"
  }
}

KATEGORI YANG TERSEDIA:
Expense: makan, minum, transport, hiburan, belanja, kesehatan, pendidikan, tagihan, lainnya
Income: gaji, bonus, investasi, freelance, hadiah, lainnya_masuk

JIKA PENGGUNA BERTANYA (contoh: "berapa pengeluaranku bulan ini?", "tips hemat", dll):
{
  "reply": "Jawaban lengkap dan informatif",
  "action_type": null,
  "action": null
}

Data keuangan pengguna saat ini:
$financialContext
''';

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
        systemInstruction: Content.text(systemPrompt),
      );

      final chat = model.startChat();

      final response = await chat.sendMessage(
        Content.text(userMessage),
      );

      final textResponse = response.text?.trim() ?? '';

      String cleanedJson =
          textResponse.replaceAll('```json', '').replaceAll('```', '').trim();

      debugPrint("--- AI CHAT RAW OUTPUT ---");
      debugPrint(cleanedJson);
      debugPrint("--------------------------");

      final Map<String, dynamic> data = jsonDecode(cleanedJson);
      return data;
    } catch (e) {
      debugPrint("AI Chat Error: $e");

      // Fallback: try without system instruction
      try {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _geminiApiKey,
        );

        final chat = model.startChat();

        final fullPrompt = '''$systemPrompt

Pengguna: $userMessage
''';

        final response = await chat.sendMessage(
          Content.text(fullPrompt),
        );

        final textResponse = response.text?.trim() ?? '';

        String cleanedJson =
            textResponse.replaceAll('```json', '').replaceAll('```', '').trim();

        final Map<String, dynamic> data = jsonDecode(cleanedJson);
        return data;
      } catch (e2) {
        debugPrint("AI Chat Fallback Error: $e2");
        return {
          'reply':
              'Maaf, terjadi kesalahan saat memproses pesanmu. Coba lagi ya! 😊',
          'action': null,
        };
      }
    }
  }
}
