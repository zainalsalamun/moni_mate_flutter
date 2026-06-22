import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiChatService {
  static String get _apiUrl => dotenv.env['AI_API_URL'] ?? '';
  static String get _apiKey => dotenv.env['AI_API_KEY'] ?? '';

  static bool get isApiKeyAvailable => _apiUrl.isNotEmpty && _apiKey.isNotEmpty;

  /// Strip markdown formatting from text for plain Text widget display
  static String _stripMarkdown(String text) {
    String result = text;
    // Remove bold/italic markers
    result =
        result.replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!);
    result = result.replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m.group(1)!);
    result = result.replaceAllMapped(RegExp(r'__(.+?)__'), (m) => m.group(1)!);
    result = result.replaceAllMapped(RegExp(r'_(.+?)_'), (m) => m.group(1)!);
    // Remove inline code
    result = result.replaceAllMapped(RegExp(r'`(.+?)`'), (m) => m.group(1)!);
    // Remove horizontal rules
    result = result.replaceAll(RegExp(r'^-{3,}\s*$', multiLine: true), '');
    // Remove markdown table rows (lines starting with |)
    result = result.replaceAll(RegExp(r'^\|.*\|\s*$', multiLine: true), '');
    // Remove consecutive empty lines (clean up after table removal)
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return result.trim();
  }

  /// Sends a message to the AI API with financial assistant context.
  /// Returns a Map with 'reply' (String) and optionally 'action' data.
  static Future<Map<String, dynamic>> sendMessage(
    String userMessage, {
    List<Map<String, dynamic>>? transactionSummary,
    double? totalIncome,
    double? totalExpense,
    List<Map<String, String>>? chatHistory,
  }) async {
    if (!isApiKeyAvailable) {
      return {
        'reply':
            'API Key belum diisi. Silakan masukkan AI_API_KEY di file .env.',
        'action': null,
        'action_type': null,
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

ATURAN PENTING - FORMAT OUTPUT:
- JANGAN gunakan markdown (**bold**, *italic*, `code`, tabel | |, atau pembatas ---)
- JANGAN gunakan simbol markdown apapun di dalam field "reply"
- Tulis teks biasa yang bisa langsung dibaca. Gunakan emoji untuk hiasan.
- Contoh yang BENAR: "Total pengeluaranmu Rp 1.163.000. Kamu sudah belanja makan Rp 988.000 hari ini."
- Contoh SALAH: "| Keterangan | Nominal |" atau "**Rp 1.163.000**"
- Untuk merangkum data, cukup tulis dalam kalimat biasa, jangan pakai tabel.
- Selalu balas HANYA dengan objek JSON tunggal yang valid TANPA awalan teks, TANPA akhiran teks, dan TANPA markdown code blocks.
- Ekstrak nominal (amount) SECARA SAMA PERSIS dengan angka yang disebutkan pengguna. JANGAN PERNAH mengalikan (x2), menjumlahkan, atau mengakumulasikan nominal dengan transaksi sebelumnya di riwayat chat.
- Format respons:
{
  "reply": "Teks balasan untuk pengguna dalam tulisan biasa tanpa markdown",
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
      debugPrint("AI Chat: Sending to Gemini...");

      // Build messages list with chat history for context
      final List<Map<String, String>> messages = [
        {'role': 'system', 'content': systemPrompt},
      ];

      // Add chat history if available (so AI remembers previous conversation)
      if (chatHistory != null && chatHistory.isNotEmpty) {
        for (final msg in chatHistory) {
          messages.add(msg);
        }
        debugPrint("Chat history included: ${chatHistory.length} messages");
      }

      // Add current user message
      messages.add({'role': 'user', 'content': userMessage});

      final url = Uri.parse('$_apiUrl/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'Combo_minimax_mimo',
          'messages': messages,
          'stream': false,
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      debugPrint("--- AI CHAT REQUEST ---");
      debugPrint("URL: $url");
      debugPrint(
          "API Key: ${_apiKey.substring(0, _apiKey.length.clamp(0, 8))}...");
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Response length: ${response.body.length} chars");
      debugPrint("------------------------");

      if (response.statusCode == 200) {
        // Handle SSE (Server-Sent Events) format: "data: {...}" or plain JSON
        String responseBody = response.body.trim();
        debugPrint(
            "Raw response (first 300 chars): ${responseBody.substring(0, responseBody.length.clamp(0, 300))}");

        // If response starts with "data: ", extract JSON from SSE format
        if (responseBody.startsWith('data: ')) {
          // Could be multiple "data: " lines; take the last non-empty one
          final lines = responseBody.split('\n');
          for (final line in lines.reversed) {
            final trimmed = line.trim();
            if (trimmed.startsWith('data: ')) {
              responseBody = trimmed.substring(6); // Remove "data: " prefix
              break;
            }
          }
          debugPrint(
              "Extracted from SSE format: ${responseBody.substring(0, responseBody.length.clamp(0, 200))}");
        }

        final data = jsonDecode(responseBody);
        final textResponse =
            data['choices']?[0]?['message']?['content']?.trim() ?? '';

        debugPrint("--- AI CHAT RAW OUTPUT ---");
        debugPrint(textResponse);
        debugPrint("--------------------------");

        // Strip <think>...</think> blocks (reasoning model output)
        String cleanedJson = textResponse;
        final thinkRegex = RegExp(r'<think>[\s\S]*?</think>', dotAll: true);
        cleanedJson = cleanedJson.replaceAll(thinkRegex, '').trim();

        // Also strip markdown code blocks
        cleanedJson =
            cleanedJson.replaceAll('```json', '').replaceAll('```', '').trim();

        // Extract JSON object if the model includes conversational text
        int startIndex = cleanedJson.indexOf('{');
        int endIndex = cleanedJson.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            cleanedJson = cleanedJson.substring(startIndex, endIndex + 1);
        }

        debugPrint("--- AI CHAT CLEANED OUTPUT ---");
        debugPrint(cleanedJson);
        debugPrint("--------------------------------");

        try {
          final Map<String, dynamic> result = jsonDecode(cleanedJson);
          
          // Handle 'actiontype' typo from LLM
          if (result['action_type'] == null && result['actiontype'] != null) {
            String type = result['actiontype'].toString();
            if (type == 'addtransaction') type = 'add_transaction';
            result['action_type'] = type;
          }

          // Strip any markdown from the reply field for plain Text display
          if (result['reply'] is String) {
            result['reply'] = _stripMarkdown(result['reply'] as String);
          }
          return result;
        } catch (parseError) {
          debugPrint("JSON parse failed, using raw text as reply");
          // If not valid JSON, return the raw text as a friendly reply
          return {
            'reply': cleanedJson.isNotEmpty
                ? _stripMarkdown(cleanedJson)
                : 'Maaf, aku tidak bisa memproses pertanyaanmu. Coba tanyakan hal lain ya! 😊',
            'action': null,
            'action_type': null,
          };
        }
      } else {
        debugPrint("--- AI CHAT ERROR ---");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        debugPrint("Headers: ${response.headers}");
        debugPrint("---------------------");
        return {
          'reply':
              'Terjadi kesalahan dari server (status ${response.statusCode}). Coba lagi ya! 😊',
          'action': null,
          'action_type': null,
        };
      }
    } catch (e, stackTrace) {
      debugPrint("--- AI CHAT EXCEPTION ---");
      debugPrint("Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      debugPrint("-------------------------");
      return {
        'reply':
            'Terjadi kesalahan saat menghubungi server. Cek koneksi internet kamu ya! 😊',
        'action': null,
        'action_type': null,
      };
    }
  }
}
