import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:monimate/data/controller/sync_controller.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/models/transaction_model.dart';
import '../data/models/wallet_model.dart';

class WalletController extends GetxController {
  final RxList<WalletModel> wallets = <WalletModel>[].obs;
  final Rx<WalletModel?> activeWallet = Rx<WalletModel?>(null);
  final RxString activeWalletId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  void loadWallets() {
    final all = HiveService.getAllWallets();
    wallets.assignAll(all);

    // If no wallets exist, create a default one
    if (wallets.isEmpty) {
      _createDefaultWallet();
      return;
    }

    // Set active wallet
    final defaultWallet = HiveService.getDefaultWallet();
    if (defaultWallet != null) {
      activeWallet.value = defaultWallet;
      activeWalletId.value = defaultWallet.id;
    } else {
      // If no default, set first wallet as default
      wallets.first.isDefault = true;
      HiveService.updateWallet(wallets.first);
      activeWallet.value = wallets.first;
      activeWalletId.value = wallets.first.id;
    }
  }

  void _createDefaultWallet() {
    final wallet = WalletModel(
      name: 'Dompet Utama',
      type: 'cash',
      balance: 0.0,
      icon: '💰',
      colorHex: '#0288D1',
      isDefault: true,
    );
    HiveService.addWallet(wallet);
    wallets.add(wallet);
    activeWallet.value = wallet;
    activeWalletId.value = wallet.id;
  }

  void setActiveWallet(String walletId) {
    // Remove default from all
    for (var w in wallets) {
      w.isDefault = false;
      HiveService.updateWallet(w);
    }
    // Set new default
    final wallet = wallets.firstWhereOrNull((w) => w.id == walletId);
    if (wallet != null) {
      wallet.isDefault = true;
      HiveService.updateWallet(wallet);
      activeWallet.value = wallet;
      activeWalletId.value = wallet.id;
    }
    if (Get.isRegistered<SyncController>()) {
      Get.find<SyncController>().notifyDataChanged();
    }
  }

  void addWallet({
    required String name,
    required String type,
    required String icon,
    required String colorHex,
    double initialBalance = 0.0,
  }) {
    final wallet = WalletModel(
      name: name,
      type: type,
      balance: initialBalance,
      icon: icon,
      colorHex: colorHex,
      isDefault: wallets.isEmpty, // first wallet is default
    );
    HiveService.addWallet(wallet);
    wallets.add(wallet);
    if (wallets.length == 1) {
      activeWallet.value = wallet;
      activeWalletId.value = wallet.id;
    }
    if (Get.isRegistered<SyncController>()) {
      Get.find<SyncController>().notifyDataChanged();
    }
  }

  void updateWallet(WalletModel wallet) {
    HiveService.updateWallet(wallet);
    final index = wallets.indexWhere((w) => w.id == wallet.id);
    if (index != -1) {
      wallets[index] = wallet;
    }
    if (activeWallet.value?.id == wallet.id) {
      activeWallet.value = wallet;
    }
    if (Get.isRegistered<SyncController>()) {
      Get.find<SyncController>().notifyDataChanged();
    }
  }

  void deleteWallet(String walletId) {
    // Don't delete if it's the only wallet
    if (wallets.length <= 1) return;

    final wasDefault =
        wallets.firstWhereOrNull((w) => w.id == walletId)?.isDefault ?? false;

    HiveService.deleteWallet(walletId);
    wallets.removeWhere((w) => w.id == walletId);

    // If deleted wallet was active/default, set first remaining as default
    if (wasDefault && wallets.isNotEmpty) {
      wallets.first.isDefault = true;
      HiveService.updateWallet(wallets.first);
      activeWallet.value = wallets.first;
      activeWalletId.value = wallets.first.id;
    }
    if (Get.isRegistered<SyncController>()) {
      Get.find<SyncController>().notifyDataChanged();
    }
  }

  /// Get transactions filtered by active wallet
  List<TransactionModel> getWalletTransactions(String walletId) {
    if (Get.isRegistered<TransactionController>()) {
      final txController = Get.find<TransactionController>();
      return txController.transactions
          .where((t) => t.walletId == walletId)
          .toList();
    }
    return [];
  }

  /// Recalculate wallet balance from transactions
  void recalculateBalance(String walletId) {
    final txs = getWalletTransactions(walletId);
    double balance = 0;
    for (var t in txs) {
      if (t.type == 'income') {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    final wallet = wallets.firstWhereOrNull((w) => w.id == walletId);
    if (wallet != null) {
      wallet.balance = balance;
      HiveService.updateWallet(wallet);
      // Trigger reactivity
      final index = wallets.indexWhere((w) => w.id == walletId);
      if (index != -1) wallets[index] = wallet;
      if (activeWallet.value?.id == walletId) {
        activeWallet.value = wallet;
      }
    }
  }

  /// Recalculate all wallet balances
  void recalculateAllBalances() {
    for (var wallet in wallets) {
      recalculateBalance(wallet.id);
    }
  }

  /// Get total balance across all wallets
  double get totalBalance {
    return wallets.fold(0.0, (sum, w) => sum + w.balance);
  }

  /// Add transaction with wallet integration
  void addTransactionToWallet({
    required String type,
    required String category,
    required double amount,
    required String description,
    String? walletId,
  }) {
    final targetWalletId = walletId ?? activeWallet.value?.id ?? '';

    if (Get.isRegistered<TransactionController>()) {
      final txController = Get.find<TransactionController>();
      final tx = TransactionModel(
        id: const Uuid().v4(),
        type: type,
        category: category,
        amount: amount,
        description: description,
        date: DateTime.now(),
        walletId: targetWalletId,
      );
      HiveService.addTransaction(tx);
      txController.transactions.add(tx);
      txController.calculateTotals();

      // Update wallet balance
      recalculateBalance(targetWalletId);
    }
  }
}
