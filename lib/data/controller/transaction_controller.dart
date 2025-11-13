import 'package:get/get.dart';
import 'package:monimate/data/models/transaction_model.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:monimate/utils/date_formater.dart';
import 'package:uuid/uuid.dart';

class TransactionController extends GetxController {
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;

  var filterType = 'monthly'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() {
    final all = HiveService.getAll();
    transactions.assignAll(all);
    calculateTotals();
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

  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();

    return transactions.where((t) {
      final date = t.date;

      // HARIAN
      if (filterType.value == 'daily') {
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      }

      // MINGGUAN
      if (filterType.value == 'weekly') {
        final start = now.subtract(Duration(days: now.weekday - 1)); // Senin
        final end = start.add(const Duration(days: 6)); // Minggu

        return date.isAfter(start.subtract(const Duration(days: 1))) &&
            date.isBefore(end.add(const Duration(days: 1)));
      }

      // BULANAN
      return date.month == now.month && date.year == now.year;
    }).toList();
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
      if (t.type == 'income')
        income += t.amount;
      else
        expense += t.amount;
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
}
