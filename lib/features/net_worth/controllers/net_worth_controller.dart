import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../../data/controller/transaction_controller.dart';
import '../../gamification/controllers/gamification_controller.dart';

class NetWorthController extends GetxController {
  final WalletController _walletC = Get.find<WalletController>();
  final TransactionController _txC = Get.find<TransactionController>();
  final _storage = GetStorage();
  static const String _netWorthHistoryKey = 'net_worth_history';

  // State
  final RxDouble totalAssets = 0.0.obs;
  final RxDouble totalLiabilities = 0.0.obs;
  final RxDouble netWorth = 0.0.obs;
  final RxDouble monthlyGrowth = 0.0.obs;
  final RxList<String> aiInsights = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Reactively recalculate when wallets or transactions change
    everAll([_walletC.wallets, _txC.transactions], (_) {
      recalculateAll();
    });
    
    // Initial calculation
    recalculateAll();
  }

  void recalculateAll() {
    calculateAssets();
    calculateLiabilities();
    calculateNetWorth();
    calculateMonthlyGrowth();
    generateInsights();
    
    // Cache the current month's net worth
    _cacheCurrentMonthNetWorth();
  }

  void calculateAssets() {
    double sum = 0;
    for (var w in _walletC.wallets) {
      if (['cash', 'bank', 'ewallet', 'investment'].contains(w.type)) {
        sum += w.balance;
      }
    }
    totalAssets.value = sum;
  }

  void calculateLiabilities() {
    double sum = 0;
    for (var w in _walletC.wallets) {
      if (['debt', 'credit'].contains(w.type)) {
        sum += w.balance; // Balances are stored as positive values for debts
      }
    }
    totalLiabilities.value = sum;
  }

  void calculateNetWorth() {
    netWorth.value = totalAssets.value - totalLiabilities.value;

    if (Get.isRegistered<GamificationController>()) {
      final gc = Get.find<GamificationController>();
      final nw = netWorth.value;

      void triggerMilestone(String achId, int xpAmount, String desc) {
        final ach = gc.achievements.firstWhereOrNull((a) => a.id == achId);
        if (ach != null && ach.status != 'unlocked' && ach.status != 'completed') {
          gc.addXp(xpAmount, desc);
          gc.unlockAchievement(achId);
        }
      }

      if (nw >= 10000000) triggerMilestone('nw_10', 100, 'Net Worth mencapai 10 Juta');
      if (nw >= 25000000) triggerMilestone('nw_25', 200, 'Net Worth mencapai 25 Juta');
      if (nw >= 50000000) triggerMilestone('nw_50', 300, 'Net Worth mencapai 50 Juta');
      if (nw >= 100000000) triggerMilestone('nw_100', 500, 'Net Worth mencapai 100 Juta');
      if (nw >= 1000000000) triggerMilestone('nw_1000', 1000, 'Net Worth mencapai 1 Miliar');
    }
  }

  void calculateMonthlyGrowth() {
    final prevMonthNW = _getPreviousMonthNetWorth();
    
    if (prevMonthNW == 0) {
      monthlyGrowth.value = 0.0; // Avoid division by zero
    } else {
      monthlyGrowth.value = ((netWorth.value - prevMonthNW) / prevMonthNW.abs()) * 100;
    }
  }

  double _getPreviousMonthNetWorth() {
    final history = _getHistoryMap();
    
    final now = DateTime.now();
    // previous month
    var prevMonth = now.month - 1;
    var prevYear = now.year;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear--;
    }
    
    final key = '${prevYear.toString().padLeft(4, '0')}-${prevMonth.toString().padLeft(2, '0')}';
    return history[key] ?? netWorth.value; // If no data, use current to mean 0% growth
  }

  void _cacheCurrentMonthNetWorth() {
    final history = _getHistoryMap();
    final now = DateTime.now();
    final key = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    
    history[key] = netWorth.value;
    _storage.write(_netWorthHistoryKey, history);
  }

  Map<String, double> _getHistoryMap() {
    final data = _storage.read<Map<String, dynamic>>(_netWorthHistoryKey);
    if (data == null) return {};
    return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  // Used for charts
  Map<String, double> getGrowthTrend(int monthsBack) {
    final history = _getHistoryMap();
    Map<String, double> result = {};
    
    final now = DateTime.now();
    for (int i = monthsBack - 1; i >= 0; i--) {
      var m = now.month - i;
      var y = now.year;
      while (m <= 0) {
        m += 12;
        y--;
      }
      final key = '${y.toString().padLeft(4, '0')}-${m.toString().padLeft(2, '0')}';
      // format label (e.g., 'Jan', 'Feb')
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      result[months[m-1]] = history[key] ?? 0.0;
    }
    
    // Ensure current month has latest data
    final currentKey = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    result[['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][now.month-1]] = history[currentKey] ?? netWorth.value;
    
    return result;
  }
  
  Map<String, double> getAssetBreakdown() {
    Map<String, double> breakdown = {
      'Cash': 0,
      'Bank': 0,
      'E-Wallet': 0,
      'Investment': 0,
    };
    
    for (var w in _walletC.wallets) {
      if (w.type == 'cash') {
        breakdown['Cash'] = (breakdown['Cash'] ?? 0) + w.balance;
      } else if (w.type == 'bank') {
        breakdown['Bank'] = (breakdown['Bank'] ?? 0) + w.balance;
      } else if (w.type == 'ewallet') {
        breakdown['E-Wallet'] = (breakdown['E-Wallet'] ?? 0) + w.balance;
      } else if (w.type == 'investment') {
        breakdown['Investment'] = (breakdown['Investment'] ?? 0) + w.balance;
      }
    }
    
    return breakdown;
  }
  
  Map<String, double> getLiabilityBreakdown() {
    Map<String, double> breakdown = {
      'Credit Card': 0,
      'Debt': 0,
    };
    
    for (var w in _walletC.wallets) {
      if (w.type == 'credit') {
        breakdown['Credit Card'] = (breakdown['Credit Card'] ?? 0) + w.balance;
      } else if (w.type == 'debt') {
        breakdown['Debt'] = (breakdown['Debt'] ?? 0) + w.balance;
      }
    }
    
    return breakdown;
  }

  Map<String, dynamic>? getLargestWallet() {
    if (_walletC.wallets.isEmpty) return null;
    var largest = _walletC.wallets[0];
    for (var w in _walletC.wallets) {
      if (w.balance > largest.balance) largest = w;
    }
    final pct = totalAssets.value > 0 ? (largest.balance / totalAssets.value) * 100 : 0.0;
    return {
      'name': largest.name,
      'balance': largest.balance,
      'percentage': pct,
    };
  }
  
  Map<String, dynamic>? getMostActiveWallet() {
    if (_walletC.wallets.isEmpty) return null;
    Map<String, int> counts = {};
    for (var t in _txC.transactions) {
      counts[t.walletId] = (counts[t.walletId] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    
    var maxId = counts.keys.first;
    var maxCount = counts[maxId]!;
    counts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        maxId = key;
      }
    });
    
    var w = _walletC.wallets.firstWhereOrNull((w) => w.id == maxId);
    if (w == null && _walletC.wallets.isNotEmpty) w = _walletC.wallets.firstWhereOrNull((w) => w.isDefault);
    if (w == null) return null;
    
    return {
      'name': w.name,
      'count': maxCount,
    };
  }

  void generateInsights() {
    List<String> insights = [];
    
    // Growth insight
    if (monthlyGrowth.value > 0) {
      insights.add("Net worth kamu naik ${monthlyGrowth.value.toStringAsFixed(1)}% dibanding bulan lalu.");
    } else if (monthlyGrowth.value < 0) {
      insights.add("Net worth kamu turun ${monthlyGrowth.value.abs().toStringAsFixed(1)}% dibanding bulan lalu.");
    } else {
      insights.add("Net worth kamu stabil dibanding bulan lalu.");
    }
    
    // Asset distribution insight
    final assets = getAssetBreakdown();
    if (totalAssets.value > 0) {
      var largestAssetKey = '';
      var largestAssetValue = -1.0;
      assets.forEach((key, value) {
        if (value > largestAssetValue) {
          largestAssetValue = value;
          largestAssetKey = key;
        }
      });
      if (largestAssetValue > 0) {
        final pct = (largestAssetValue / totalAssets.value) * 100;
        insights.add("Aset $largestAssetKey mendominasi ${pct.toStringAsFixed(1)}% dari total asetmu.");
      }
    }
    
    // Liability insight
    if (totalLiabilities.value > 0 && totalAssets.value > 0) {
      final pct = (totalLiabilities.value / totalAssets.value) * 100;
      if (pct > 50) {
        insights.add("Waspada! Hutang mencapai ${pct.toStringAsFixed(1)}% dari total asetmu.");
      } else {
        insights.add("Hutang saat ini adalah ${pct.toStringAsFixed(1)}% dari total aset.");
      }
    }
    
    aiInsights.assignAll(insights);
  }
}
