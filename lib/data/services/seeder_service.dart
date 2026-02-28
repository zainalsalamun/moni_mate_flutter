import 'package:flutter/foundation.dart';
import 'package:monimate/data/models/transaction_model.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class SeederService {
  static Future<void> seedTransactions() async {
    // final box = HiveService.box;

    // Check if we already have transactions (optional: skip if already seeded)
    // if (box.values.isNotEmpty) return;

    debugPrint("Seeding transactions...");

    final random = Random();
    final categoriesExpense = [
      'makan',
      'minum',
      'transport',
      'hiburan',
      'belanja',
      'kesehatan'
    ];
    final categoriesIncome = ['gaji', 'bonus', 'freelance'];

    // Generate dates from November 2025 to February 2026
    final start = DateTime(2025, 11, 1);
    final end = DateTime(2026, 2, 28);
    final daysToGenerate = end.difference(start).inDays;

    for (int i = 0; i < 150; i++) {
      // Random date between November and February
      final randomDay = random.nextInt(daysToGenerate);
      final date = start.add(Duration(days: randomDay));

      // Random type (more expenses than income usually)
      final isExpense = random.nextDouble() > 0.2; // 80% expense
      final type = isExpense ? 'expense' : 'income';

      final category = isExpense
          ? categoriesExpense[random.nextInt(categoriesExpense.length)]
          : categoriesIncome[random.nextInt(categoriesIncome.length)];

      // Setup reasonable amounts
      final amount = isExpense
          ? (random.nextInt(50) + 1) * 10000.0 // 10k to 500k
          : (random.nextInt(10) + 5) * 1000000.0; // 5M to 15M

      final tx = TransactionModel(
        id: const Uuid().v4(),
        type: type,
        category: category,
        amount: amount,
        description: "Seeded transaction $i",
        date: date,
      );

      await HiveService.addTransaction(tx);
    }
    debugPrint("Seed complete");
  }
}
