import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import '../models/financial_context_model.dart';
import '../models/predictive_insight_model.dart';

class AiInsightApiService {
  static String get _apiUrl => dotenv.env['AI_API_URL'] ?? '';
  static String get _apiKey => dotenv.env['AI_API_KEY'] ?? '';

  static bool get isApiKeyAvailable => _apiUrl.isNotEmpty && _apiKey.isNotEmpty;

  static Future<String> getBriefText(String prompt) async {
    if (!isApiKeyAvailable) return '';

    try {
      final url = Uri.parse('$_apiUrl/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-v4-flash',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'stream': false,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();

        if (responseBody.startsWith('data: ')) {
          final lines = responseBody.split('\n');
          for (final line in lines.reversed) {
            final trimmed = line.trim();
            if (trimmed.startsWith('data: ')) {
              responseBody = trimmed.substring(6);
              break;
            }
          }
        }

        final data = jsonDecode(responseBody);
        final textResponse =
            data['choices']?[0]?['message']?['content']?.trim() ?? '';

        String cleanedJson = textResponse;
        final thinkRegex = RegExp(r'<think>[\s\S]*?</think>', dotAll: true);
        cleanedJson = cleanedJson.replaceAll(thinkRegex, '').trim();

        return cleanedJson;
      }
    } catch (e) {
      debugPrint("getBriefText Error: $e");
    }
    return '';
  }

  static Future<List<PredictiveInsightModel>> generateCoachInsights(
      FinancialContextModel context) async {
    if (!isApiKeyAvailable) return [];

    const systemPrompt = '''
Kamu adalah Predictive Financial Coach untuk aplikasi MoniMate.
TUGAS UTAMA: Buat maksimal 5 insight prediktif keuangan berdasarkan data JSON user.
Gaya bahasa: Singkat, praktis, bersahabat, suportif, dan bahasa Indonesia gaul/casual.
ATURAN:
1. Jangan menakut-nakuti. Jangan gunakan kalimat negatif berlebihan.
2. JANGAN menyarankan investasi spesifik (saham, crypto, dll).
3. JANGAN menyuruh meminjam uang (pinjol/kartu kredit).
4. Output HARUS dalam format JSON murni. Jangan ada markdown ```json atau ```.
5. Format severity HANYA boleh: info, success, warning, danger.
6. Format type HANYA boleh: budget_prediction, goal_prediction, recurring_impact, wallet_health, net_worth, spending_behavior, saving_advice.

FORMAT JSON OUTPUT YANG DIWAJIBKAN:
{
  "insights": [
    {
      "title": "Judul singkat (max 4 kata)",
      "message": "Pesan insight maksimal 2 kalimat singkat.",
      "type": "budget_prediction",
      "severity": "warning",
      "actionLabel": "Lihat Budget",
      "actionRoute": "/budget"
    }
  ]
}
''';

    const userMessage = '''
Berikut adalah data finansialku bulan \${context.month} \${context.year}:
\${jsonEncode(context.toJson())}

Tolong buatkan maksimal 5 insight prediktif yang paling penting.
''';

    try {
      final url = Uri.parse('\$_apiUrl/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-v4-flash',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'stream': false,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();

        if (responseBody.startsWith('data: ')) {
          final lines = responseBody.split('\\n');
          for (final line in lines.reversed) {
            final trimmed = line.trim();
            if (trimmed.startsWith('data: ')) {
              responseBody = trimmed.substring(6);
              break;
            }
          }
        }

        final data = jsonDecode(responseBody);
        final textResponse =
            data['choices']?[0]?['message']?['content']?.trim() ?? '';

        String cleanedJson = textResponse;
        final thinkRegex = RegExp(r'<think>[\\s\\S]*?</think>', dotAll: true);
        cleanedJson = cleanedJson.replaceAll(thinkRegex, '').trim();
        cleanedJson =
            cleanedJson.replaceAll('```json', '').replaceAll('```', '').trim();

        final firstBrace = cleanedJson.indexOf('{');
        final lastBrace = cleanedJson.lastIndexOf('}');

        if (firstBrace != -1 && lastBrace != -1 && lastBrace >= firstBrace) {
          cleanedJson = cleanedJson.substring(firstBrace, lastBrace + 1);
          final parsed = jsonDecode(cleanedJson);

          if (parsed['insights'] is List) {
            final List insightsRaw = parsed['insights'];
            return insightsRaw.map((e) {
              return PredictiveInsightModel(
                id: const Uuid().v4(),
                title: e['title']?.toString() ?? 'Insight',
                message: e['message']?.toString() ?? '',
                type: e['type']?.toString() ?? 'info',
                severity: e['severity']?.toString() ?? 'info',
                source: 'ai_api',
                actionLabel: e['actionLabel']?.toString() ?? '',
                actionRoute: e['actionRoute']?.toString() ?? '',
                createdAt: DateTime.now(),
              );
            }).toList();
          }
        }
      }
    } catch (e) {
      debugPrint("AI Insight API Error: \$e");
    }

    return [];
  }
}
