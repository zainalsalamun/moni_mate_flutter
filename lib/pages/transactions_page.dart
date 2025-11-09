
import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Cari transaksi...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.calendar_month), label: const Text('Tanggal')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: (){}, child: const Text('🏷️')),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              _TxTile(emoji: '🍔', title: 'Makan Siang', subtitle: '3 Nov 2025 • Makan', amount: '- Rp 25.000', negative: true),
              _TxTile(emoji: '🚗', title: 'GrabCar', subtitle: '3 Nov 2025 • Transport', amount: '- Rp 50.000', negative: true),
              _TxTile(emoji: '🎮', title: 'Steam Top-Up', subtitle: '2 Nov 2025 • Hiburan', amount: '- Rp 150.000', negative: true),
              _TxTile(emoji: '💼', title: 'Gaji', subtitle: '1 Nov 2025 • Pemasukan', amount: '+ Rp 3.000.000', negative: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _TxTile extends StatelessWidget {
  final String emoji, title, subtitle, amount;
  final bool negative;

  const _TxTile({required this.emoji, required this.title, required this.subtitle, required this.amount, required this.negative});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.w600, color: negative ? Colors.redAccent : Colors.green)),
      ),
    );
  }
}
