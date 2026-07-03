import 'package:get/get.dart';
import 'package:monimate/features/net_worth/models/net_worth_snapshot_model.dart';
import 'package:monimate/features/net_worth/services/wealth_timeline_service.dart';

class WealthTimelineController extends GetxController {
  final WealthTimelineService _timelineService =
      Get.find<WealthTimelineService>();

  final RxList<NetWorthSnapshotModel> snapshots = <NetWorthSnapshotModel>[].obs;
  final RxString selectedRange = '6M'.obs; // '6M', '1Y', '2Y', 'ALL'

  // Summary Metrics
  final RxDouble currentNetWorth = 0.0.obs;
  final RxDouble allTimeHigh = 0.0.obs;
  final RxDouble allTimeLow = 0.0.obs;
  final RxDouble currentMoMGrowth = 0.0.obs;
  final RxDouble currentYoYGrowth = 0.0.obs;
  final RxDouble avgMonthlyGrowth = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    // Reactively reload if service generates new snapshots
    ever(_timelineService.getAllSnapshots().obs, (_) => loadData());
  }

  void loadData() {
    final allSnapshots = _timelineService.getAllSnapshots();
    snapshots.assignAll(allSnapshots);

    if (allSnapshots.isNotEmpty) {
      final latest = allSnapshots.last;
      currentNetWorth.value = latest.netWorth;
      currentMoMGrowth.value = latest.growthPercentMoM;
      currentYoYGrowth.value = latest.growthPercentYoY;

      double high = allSnapshots.first.netWorth;
      double low = allSnapshots.first.netWorth;
      double totalGrowth = 0;

      for (var s in allSnapshots) {
        if (s.netWorth > high) high = s.netWorth;
        if (s.netWorth < low) low = s.netWorth;
        totalGrowth += s.growthPercentMoM;
      }

      allTimeHigh.value = high;
      allTimeLow.value = low;
      avgMonthlyGrowth.value = totalGrowth / allSnapshots.length;
    }
  }

  void changeRange(String range) {
    selectedRange.value = range;
  }

  List<NetWorthSnapshotModel> get filteredSnapshots {
    final all = snapshots.toList();
    if (all.isEmpty) return [];

    DateTime now = DateTime.now();
    DateTime cutoff;

    switch (selectedRange.value) {
      case '6M':
        cutoff = DateTime(now.year, now.month - 5, 1);
        break;
      case '1Y':
        cutoff = DateTime(now.year - 1, now.month, 1);
        break;
      case '2Y':
        cutoff = DateTime(now.year - 2, now.month, 1);
        break;
      case 'ALL':
      default:
        return all;
    }

    return all
        .where((s) =>
            s.snapshotDate.isAfter(cutoff) ||
            (s.year == cutoff.year && s.month == cutoff.month))
        .toList();
  }

  NetWorthSnapshotModel? get bestMonth {
    if (snapshots.isEmpty) return null;
    return snapshots
        .reduce((a, b) => a.growthPercentMoM > b.growthPercentMoM ? a : b);
  }

  NetWorthSnapshotModel? get worstMonth {
    if (snapshots.isEmpty) return null;
    return snapshots
        .reduce((a, b) => a.growthPercentMoM < b.growthPercentMoM ? a : b);
  }
}
