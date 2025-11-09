import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/pages/shell.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<TransactionController>();
    final shellC = Get.find<ShellController>();

    return Obx(() {
      final transactions = c.transactions.reversed.toList();

      if (transactions.isEmpty) {
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yuk tambahkan transaksi pertama kamu!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => shellC.changeTab(2),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Tambah Transaksi'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (_, i) {
          final t = transactions[i];
          final isIncome = t.type == 'income';

          IconData icon;
          switch (t.category) {
            case 'gaji':
              icon = Icons.work_outline;
              break;
            case 'makan':
              icon = Icons.fastfood_outlined;
              break;
            case 'transport':
              icon = Icons.directions_car_outlined;
              break;
            default:
              icon = Icons.local_play_outlined;
          }

          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isIncome
                    ? Colors.greenAccent.withOpacity(0.2)
                    : Colors.redAccent.withOpacity(0.2),
                child: Icon(
                  icon,
                  color: isIncome ? Colors.green : Colors.redAccent,
                ),
              ),
              title: Text(
                t.description.isEmpty
                    ? t.category.capitalizeFirst!
                    : t.description,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${t.date.day}/${t.date.month}/${t.date.year}',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: Text(
                '${isIncome ? '+' : '-'} Rp ${t.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isIncome ? Colors.green : Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onLongPress: () => c.deleteTransaction(t.id),
            ),
          );
        },
      );
    });
  }
}
