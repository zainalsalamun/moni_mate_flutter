import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:monimate/features/net_worth/models/net_worth_snapshot_model.dart';
import 'package:monimate/features/net_worth/controllers/net_worth_controller.dart';

class WealthTimelineService extends GetxService {
  final NetWorthController _netWorthController = Get.find<NetWorthController>();

  @override
  void onInit() {
    super.onInit();
    // Wait until the net worth is calculated then try generating snapshot
    ever(_netWorthController.netWorth, (_) {
      generateMonthlySnapshot();
    });
  }

  Future<void> generateMonthlySnapshot() async {
    final double currentNetWorth = _netWorthController.netWorth.value;
    final double totalAssets = _netWorthController.totalAssets.value;
    final double totalLiabilities = _netWorthController.totalLiabilities.value;

    // Do not generate if still 0 or uninitialized
    if (totalAssets == 0 && totalLiabilities == 0) return;

    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    final existingSnapshots = HiveService.getAllNetWorthSnapshots();
    final currentMonthSnapshotIndex = existingSnapshots.indexWhere((s) => s.year == year && s.month == month);

    // Calculate Growth
    double growthMoM = 0;
    double growthYoY = 0;

    // MoM Calculation
    final previousMonth = month == 1 ? 12 : month - 1;
    final previousMonthYear = month == 1 ? year - 1 : year;
    final lastMonthSnapshot = existingSnapshots.firstWhereOrNull((s) => s.year == previousMonthYear && s.month == previousMonth);

    if (lastMonthSnapshot != null && lastMonthSnapshot.netWorth != 0) {
      growthMoM = ((currentNetWorth - lastMonthSnapshot.netWorth) / lastMonthSnapshot.netWorth.abs()) * 100;
    }

    // YoY Calculation
    final lastYearSnapshot = existingSnapshots.firstWhereOrNull((s) => s.year == year - 1 && s.month == month);
    if (lastYearSnapshot != null && lastYearSnapshot.netWorth != 0) {
      growthYoY = ((currentNetWorth - lastYearSnapshot.netWorth) / lastYearSnapshot.netWorth.abs()) * 100;
    }

    if (currentMonthSnapshotIndex >= 0) {
      // Update existing snapshot for current month
      final existing = existingSnapshots[currentMonthSnapshotIndex];
      final updatedSnapshot = NetWorthSnapshotModel(
        id: existing.id,
        year: year,
        month: month,
        snapshotDate: now,
        totalAssets: totalAssets,
        totalLiabilities: totalLiabilities,
        netWorth: currentNetWorth,
        growthPercentMoM: growthMoM,
        growthPercentYoY: growthYoY,
        createdAt: existing.createdAt,
      );
      await HiveService.saveNetWorthSnapshot(updatedSnapshot);
    } else {
      // Create new snapshot
      final newSnapshot = NetWorthSnapshotModel(
        id: const Uuid().v4(),
        year: year,
        month: month,
        snapshotDate: now,
        totalAssets: totalAssets,
        totalLiabilities: totalLiabilities,
        netWorth: currentNetWorth,
        growthPercentMoM: growthMoM,
        growthPercentYoY: growthYoY,
        createdAt: now,
      );
      await HiveService.saveNetWorthSnapshot(newSnapshot);
    }
  }

  List<NetWorthSnapshotModel> getAllSnapshots() {
    final list = HiveService.getAllNetWorthSnapshots();
    list.sort((a, b) {
      if (a.year != b.year) return a.year.compareTo(b.year);
      return a.month.compareTo(b.month);
    });
    return list;
  }
}
