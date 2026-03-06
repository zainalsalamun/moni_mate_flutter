import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/models/transaction_model.dart';
import 'package:monimate/pages/shell.dart';
import 'package:monimate/theme/app_theme.dart';
import 'package:monimate/utils/date_formater.dart';
import 'package:monimate/utils/format_currency.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TransactionController>();
    final shellC = Get.find<ShellController>();

    return Obx(() {
      final grouped = c.groupedTransactions;

      if (c.transactions.isEmpty) {
        return _emptyState(context, shellC);
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildTransactionContent(
          context,
          c,
          grouped,
          key: ValueKey(c.filterType.value),
        ),
      );
    });
  }

  Widget _emptyState(BuildContext context, ShellController shellC) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 90,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Transaksi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yuk tambahkan transaksi pertama kamu!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => shellC.changeTab(2),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Tambah Transaksi'),
            )
          ],
        ),
      ),
    );
  }

  Widget _filterBar(BuildContext context, TransactionController c) {
    final items = [
      {"id": "all", "label": "Semua"},
      {"id": "daily", "label": "7 Hari"},
      {"id": "weekly", "label": "30 Hari"},
      {"id": "monthly", "label": "Bulan Ini"},
    ];

    return Obx(
      () => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: items.map((e) {
            final selected = c.filterType.value == e["id"];

            return Expanded(
              child: GestureDetector(
                onTap: () => c.filterType.value = e["id"]!,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: selected ? AppTheme.oceanGradient() : null,
                    color: selected ? null : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      e["label"]!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: selected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _transactionTile(
      BuildContext context, TransactionController c, TransactionModel t) {
    final isIncome = t.type == 'income';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2D3748)
                : const Color(0xFFEDF2F7)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isIncome
                ? Colors.greenAccent.withOpacity(0.15)
                : Colors.redAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(_emoji(t.category), style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          t.description.isEmpty ? t.category.capitalizeFirst! : t.description,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            DateFormatter.format(t.date),
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 12),
          ),
        ),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${isIncome ? '+' : '-'} ${CurrencyFormat.format(t.amount)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isIncome ? Colors.green : Colors.redAccent,
            ),
          ),
        ),
        onLongPress: () => c.deleteTransaction(t.id),
      ),
    );
  }

  Widget _buildTransactionContent(
    BuildContext context,
    TransactionController c,
    Map<String, List<TransactionModel>> grouped, {
    required Key key,
  }) {
    return ListView(
      key: key,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _filterBar(context, c),
        const SizedBox(height: 20),
        ...grouped.entries.map((entry) {
          final title = entry.key;
          final list = entry.value;

          if (c.filterType.value == "daily" &&
              title == "Hari Ini" &&
              list.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 48,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Belum Ada Transaksi Hari Ini",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...list.map((t) => _transactionTile(context, c, t)),
              const SizedBox(height: 20),
            ],
          );
        }),
      ],
    );
  }

  String _emoji(String key) {
    switch (key) {
      case 'makan':
        return '🍔';
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
}
