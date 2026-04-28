import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/models/transaction_model.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:monimate/data/models/category_model.dart';
import 'package:monimate/utils/date_formater.dart';
import 'package:uuid/uuid.dart';

class TransactionController extends GetxController {
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;

  final RxString filterType = "all".obs; // Default to 'all' to see seeded data

  // RxList untuk category custom
  final RxList<CategoryModel> customExpenseCategories = <CategoryModel>[].obs;
  final RxList<CategoryModel> customIncomeCategories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    final all = HiveService.getAll();
    transactions.assignAll(all);
    calculateTotals();
    loadCategories();
  }

  void loadCategories() {
    customExpenseCategories
        .assignAll(HiveService.getCustomCategories('expense'));
    customIncomeCategories.assignAll(HiveService.getCustomCategories('income'));
  }

  void addCustomCategory(String type, String name, String emoji) {
    final cat = CategoryModel(
      id: const Uuid().v4(),
      type: type,
      name: name,
      emoji: emoji,
      isCustom: true,
    );
    HiveService.addCategory(cat);
    loadCategories();
  }

  void deleteCustomCategory(String id) {
    HiveService.deleteCategory(id);
    loadCategories();
  }

  void addTransaction(
      String type, String category, double amount, String description) {
    final tx = TransactionModel(
      id: const Uuid().v4(),
      type: type,
      category: category,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );

    HiveService.addTransaction(tx);
    transactions.add(tx);
    calculateTotals();
  }

  List<TransactionModel> get recentTransactions {
    final list = List<TransactionModel>.from(transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();

    final list = transactions.where((t) {
      final date = t.date;

      if (filterType.value == 'daily') {
        // Last 7 days
        return date.isAfter(now.subtract(const Duration(days: 7)));
      }

      if (filterType.value == 'weekly') {
        // Last 30 days
        return date.isAfter(now.subtract(const Duration(days: 30)));
      }

      if (filterType.value == 'monthly') {
        return date.year == now.year && date.month == now.month;
      }

      return true; // 'all'
    }).toList();

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Map<String, List<TransactionModel>> get groupedTransactions {
    final list = filteredTransactions;
    list.sort((a, b) => b.date.compareTo(a.date));

    final Map<String, List<TransactionModel>> groups = {};

    for (var t in list) {
      final key = _formatGroupDate(t.date);
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(t);
    }

    if (filterType.value == "daily" && !groups.containsKey("Hari Ini")) {
      groups["Hari Ini"] = [];
    }

    return groups;
  }

  String _formatGroupDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Hari Ini";
    }

    final kemarin = now.subtract(const Duration(days: 1));

    if (date.year == kemarin.year &&
        date.month == kemarin.month &&
        date.day == kemarin.day) {
      return "Kemarin";
    }

    return DateFormatter.format(date);
  }

  void deleteTransaction(String id) {
    HiveService.deleteTransaction(id);
    transactions.removeWhere((e) => e.id == id);
    calculateTotals();
  }

  void calculateTotals() {
    double income = 0;
    double expense = 0;

    for (var t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
  }

  void clearAll() async {
    await HiveService.clearAll();
    transactions.clear();
    totalIncome.value = 0;
    totalExpense.value = 0;
  }

  String getEmoji(String categoryName) {
    final name = categoryName.toLowerCase();
    // Check custom categories
    final custom = [...customExpenseCategories, ...customIncomeCategories]
        .firstWhereOrNull((c) => c.name.toLowerCase() == name);
    if (custom != null) return custom.emoji;

    switch (name) {
      case 'makan':
        return '🍲';
      case 'minum':
        return '🥤';
      case 'transport':
        return '🚗';
      case 'hiburan':
        return '🎮';
      case 'gaji':
        return '💼';
      case 'belanja':
        return '🛍️';
      case 'kesehatan':
        return '💊';
      case 'pendidikan':
        return '📚';
      case 'tagihan':
        return '💡';
      default:
        return '🧩';
    }
  }

  dynamic getColor(String categoryName) {
    final name = categoryName.toLowerCase();
    switch (name) {
      case 'makan':
        return const Color(0xFF6F86D6);
      case 'transport':
        return const Color(0xFF48C6EF);
      case 'hiburan':
        return const Color(0xFF22C55E);
      case 'gaji':
        return const Color(0xFFF59E0B);
      case 'belanja':
        return const Color(0xFFE879F9);
      case 'kesehatan':
        return const Color(0xFFFB7185);
      case 'pendidikan':
        return const Color(0xFF8B5CF6);
      case 'tagihan':
        return const Color(0xFFFFA500);
      case 'minum':
        return const Color(0xFF654444);
      default:
        // Hash name to color for custom categories
        final hash = name.codeUnits.fold(0, (prev, element) => prev + element);
        return Colors.primaries[hash % Colors.primaries.length];
    }
  }
}
