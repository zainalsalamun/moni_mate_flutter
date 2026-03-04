import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/models/recurring_transaction_model.dart';
import 'package:monimate/data/services/hive_service.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:uuid/uuid.dart';

class RecurringController extends GetxController {
  final RxList<RecurringTransactionModel> recurrings =
      <RecurringTransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecurrings();
  }

  void loadRecurrings() {
    final all = HiveService.getAllRecurring();
    recurrings.assignAll(all);
    checkAndExecuteRecurring();
  }

  void addRecurring(String title, double amount, String category, String type,
      String repeatType, int interval, DateTime startDate, DateTime? endDate) {
    // Normalisasikan jam startDate untuk eksekusi yang tepat (potong jam)
    DateTime nextExecution =
        DateTime(startDate.year, startDate.month, startDate.day);

    final rec = RecurringTransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      category: category,
      type: type,
      repeatType: repeatType,
      startDate: startDate,
      endDate: endDate,
      interval: interval,
      nextExecutionDate: nextExecution,
      isActive: true, // Auto active
    );

    HiveService.addRecurringTransaction(rec);
    recurrings.add(rec);
    checkAndExecuteRecurring();
  }

  void toggleActive(String id, bool val) {
    final idx = recurrings.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final rec = recurrings[idx];
      rec.isActive = val;
      rec.save(); // HiveObject save
      recurrings.refresh();
    }
  }

  void deleteRecurring(String id) {
    HiveService.deleteRecurringTransaction(id);
    recurrings.removeWhere((e) => e.id == id);
  }

  // --- OFFLINE SCHEDULER ENGINE ---
  void checkAndExecuteRecurring() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if TransactionController exists (should since we put it too)
    if (!Get.isRegistered<TransactionController>()) return;
    final txC = Get.find<TransactionController>();

    bool hasExecuted = false;

    for (var rec in recurrings) {
      if (!rec.isActive) continue;

      if (rec.endDate != null && rec.nextExecutionDate.isAfter(rec.endDate!)) {
        rec.isActive = false; // Finished
        rec.save();
        continue;
      }

      // execute while next <= today (catch up missed past occurrences)
      DateTime executionCursor = rec.nextExecutionDate;
      // Normalisasi
      executionCursor = DateTime(
          executionCursor.year, executionCursor.month, executionCursor.day);

      bool updated = false;

      while (!executionCursor.isAfter(today)) {
        // Cek saldo pintar (jika ingin dikembangkan lebih dalam, misalnya blokir jika kurang dsb, tapi by req tetap dilanjut/warning, sementara ini kita pasang auto default catat)

        // Tambahkan transaksi asli
        txC.addTransaction(rec.type, rec.category, rec.amount,
            "${rec.title} (Auto-Recurring)");

        // calculate next
        executionCursor =
            _calculateNext(executionCursor, rec.repeatType, rec.interval);
        updated = true;

        // stop if end date is reached
        if (rec.endDate != null && executionCursor.isAfter(rec.endDate!)) {
          rec.isActive = false;
          break;
        }
      }

      if (updated) {
        rec.nextExecutionDate = executionCursor;
        rec.save();
        hasExecuted = true;

        // Custom Notif/Snack ringan untuk user
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.snackbar(
            "Transaksi Rutin Ditambahkan",
            "${rec.title} telah dicatat ke Mutasi kamu.",
            backgroundColor: Theme.of(Get.context!).colorScheme.primary,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
          );
        });
      }
    }

    if (hasExecuted) {
      recurrings.refresh();
    }
  }

  DateTime _calculateNext(DateTime current, String repeatType, int interval) {
    switch (repeatType.toLowerCase()) {
      case 'harian':
      case 'daily':
        return current.add(Duration(days: interval));
      case 'mingguan':
      case 'weekly':
        return current.add(Duration(days: interval * 7));
      case 'bulanan':
      case 'monthly':
        final nextMonth = current.month + interval;
        // Simple month addition (edge cases like Jan 31 + 1 mo => Feb 28, can be complex in Dart, basic here)
        final newYear = current.year + (nextMonth - 1) ~/ 12;
        final newMonth = (nextMonth - 1) % 12 + 1;
        var newDay = current.day;

        // Handle max days
        final maxDays = _daysInMonth(newMonth, newYear);
        if (newDay > maxDays) newDay = maxDays;

        return DateTime(newYear, newMonth, newDay);
      case 'tahunan':
      case 'yearly':
        var newYear2 = current.year + interval;
        var newDay2 = current.day;
        if (current.month == 2 && current.day == 29) {
          final isLeap = (newYear2 % 4 == 0) &&
              ((newYear2 % 100 != 0) || (newYear2 % 400 == 0));
          if (!isLeap) newDay2 = 28;
        }
        return DateTime(newYear2, current.month, newDay2);
      default:
        return current.add(Duration(days: interval));
    }
  }

  int _daysInMonth(int month, int year) {
    if (month == 2) {
      bool isLeap = (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
      return isLeap ? 29 : 28;
    }
    const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month - 1];
  }
}
