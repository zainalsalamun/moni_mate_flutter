import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';

class ExportService {
  static Future<String> exportToCsv(List<TransactionModel> data) async {
    final List<List<dynamic>> rows = [];

    rows.add(['ID', 'Jenis', 'Kategori', 'Nominal', 'Deskripsi', 'Tanggal']);

    for (var t in data) {
      rows.add([
        t.id,
        t.type,
        t.category,
        t.amount.toStringAsFixed(2),
        t.description,
        t.date.toIso8601String(),
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/monimate_export.csv';

    final file = File(path);
    await file.writeAsString(csvData);
    return path;
  }

  static Future<void> shareCsv(String path) async {
    await Share.shareXFiles([XFile(path)],
        text: 'Export data keuangan dari MoniMate 💰');
  }
}
