
import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.calendar_today), label: const Text('November 2025')),
            const Spacer(),
            OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.download_outlined), label: const Text('Export CSV')),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pengeluaran per Kategori', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Faux donut
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 110, height: 110,
                          child: CircularProgressIndicator(value: 1, strokeWidth: 18, color: const Color(0xFF6F86D6), backgroundColor: Colors.transparent),
                        ),
                        const SizedBox(
                          width: 110, height: 110,
                          child: CircularProgressIndicator(value: 0.65, strokeWidth: 18, color: Color(0xFF48C6EF), backgroundColor: Colors.transparent),
                        ),
                        Container(width: 70, height: 70, decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(children: const [
                      _Legend(color: Color(0xFF6F86D6), label: 'Makan', value: '35%'),
                      _Legend(color: Color(0xFF48C6EF), label: 'Transport', value: '25%'),
                      _Legend(color: Color(0xFF22C55E), label: 'Hiburan', value: '20%'),
                      _Legend(color: Color(0xFFF59E0B), label: 'Lainnya', value: '20%'),
                    ]))
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _Legend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
