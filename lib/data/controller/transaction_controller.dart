import 'package:get/get.dart';
import 'package:monimate/data/models/transaction_model.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class TransactionController extends GetxController {
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxDouble totalIncome = 0.0.obs;
  final RxDouble totalExpense = 0.0.obs;

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
