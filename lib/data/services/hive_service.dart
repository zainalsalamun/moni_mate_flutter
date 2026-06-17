import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/goal_model.dart';
import '../models/contribution_model.dart';
import '../../features/budget/model/budget_model.dart';
import '../../features/wallet/data/models/wallet_model.dart';

class HiveService {
  static const String boxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String recurringBoxName = 'recurring_transactions';
  static const String budgetBoxName = 'budgets';
  static const String goalBoxName = 'goals';
  static const String contributionBoxName = 'contributions';
  static const String chatHistoryBoxName = 'chat_history';
  static const String walletBoxName = 'wallets';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(RecurringTransactionModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(BudgetPeriodAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(ContributionModelAdapter());
    Hive.registerAdapter(WalletModelAdapter());

    await Hive.openBox<TransactionModel>(boxName);
    await Hive.openBox<CategoryModel>(categoryBoxName);
    await Hive.openBox<RecurringTransactionModel>(recurringBoxName);
    await Hive.openBox<BudgetModel>(budgetBoxName);
    await Hive.openBox<GoalModel>(goalBoxName);
    await Hive.openBox<ContributionModel>(contributionBoxName);
    await Hive.openBox<String>(chatHistoryBoxName);
    await Hive.openBox<WalletModel>(walletBoxName);
  }

  static Box<TransactionModel> get box => Hive.box<TransactionModel>(boxName);
  static Box<CategoryModel> get categoryBox =>
      Hive.box<CategoryModel>(categoryBoxName);
  static Box<RecurringTransactionModel> get recurringBox =>
      Hive.box<RecurringTransactionModel>(recurringBoxName);

  static Future<void> addTransaction(TransactionModel tx) async {
    await box.put(tx.id, tx);
  }

  static List<TransactionModel> getAll() {
    return box.values.toList();
  }

  static Future<void> deleteTransaction(String id) async {
    await box.delete(id);
  }

  static Future<void> clearAll() async {
    await box.clear();
  }

  // Categories Functionality
  static Future<void> addCategory(CategoryModel cat) async {
    await categoryBox.put(cat.id, cat);
  }

  static List<CategoryModel> getCustomCategories(String type) {
    return categoryBox.values.where((c) => c.type == type).toList();
  }

  static Future<void> deleteCategory(String id) async {
    await categoryBox.delete(id);
  }

  // Recurring Transactions Functionality
  static Future<void> addRecurringTransaction(
      RecurringTransactionModel tx) async {
    await recurringBox.put(tx.id, tx);
  }

  static List<RecurringTransactionModel> getAllRecurring() {
    return recurringBox.values.toList();
  }

  static Future<void> deleteRecurringTransaction(String id) async {
    await recurringBox.delete(id);
  }

  // Budget Functionality
  static Box<BudgetModel> get budgetBox => Hive.box<BudgetModel>(budgetBoxName);

  static Future<void> addBudget(BudgetModel budget) async {
    await budgetBox.put(budget.id, budget);
  }

  static List<BudgetModel> getAllBudgets() {
    return budgetBox.values.toList();
  }

  static Future<void> deleteBudget(String id) async {
    await budgetBox.delete(id);
  }

  // Financial Goals Functionality
  static Box<GoalModel> get goalBox => Hive.box<GoalModel>(goalBoxName);
  static Box<ContributionModel> get contributionBox =>
      Hive.box<ContributionModel>(contributionBoxName);

  static Future<void> addGoal(GoalModel goal) async {
    await goalBox.put(goal.id, goal);
  }

  static List<GoalModel> getAllGoals() {
    return goalBox.values.toList();
  }

  static Future<void> deleteGoal(String id) async {
    await goalBox.delete(id);
  }

  static Future<void> addContribution(ContributionModel contribution) async {
    await contributionBox.put(contribution.id, contribution);
  }

  static List<ContributionModel> getContributionsForGoal(String goalId) {
    return contributionBox.values.where((c) => c.goalId == goalId).toList();
  }

  static Future<void> deleteContributionsByGoalId(String goalId) async {
    final contributions =
        contributionBox.values.where((c) => c.goalId == goalId).toList();
    for (var c in contributions) {
      await c.delete();
    }
  }

  // Chat History Functionality
  static Box<String> get chatHistoryBox => Hive.box<String>(chatHistoryBoxName);

  static Future<void> saveChatHistory(
      List<Map<String, String>> messages) async {
    await chatHistoryBox.put('messages', jsonEncode(messages));
  }

  static List<Map<String, String>> getChatHistory() {
    final data = chatHistoryBox.get('messages');
    if (data == null || data.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  static Future<void> clearChatHistory() async {
    await chatHistoryBox.delete('messages');
  }

  // Wallet Functionality
  static Box<WalletModel> get walletBox => Hive.box<WalletModel>(walletBoxName);

  static Future<void> addWallet(WalletModel wallet) async {
    await walletBox.put(wallet.id, wallet);
  }

  static List<WalletModel> getAllWallets() {
    return walletBox.values.toList();
  }

  static WalletModel? getWalletById(String id) {
    return walletBox.get(id);
  }

  static Future<void> updateWallet(WalletModel wallet) async {
    await walletBox.put(wallet.id, wallet);
  }

  static Future<void> deleteWallet(String id) async {
    await walletBox.delete(id);
  }

  static WalletModel? getDefaultWallet() {
    try {
      return walletBox.values.firstWhere((w) => w.isDefault);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setDefaultWallet(String walletId) async {
    // Remove default from all wallets
    for (var wallet in walletBox.values) {
      wallet.isDefault = false;
      await walletBox.put(wallet.id, wallet);
    }
    // Set new default
    final wallet = walletBox.get(walletId);
    if (wallet != null) {
      wallet.isDefault = true;
      await walletBox.put(wallet.id, wallet);
    }
  }
}
