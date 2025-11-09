
import 'package:flutter/material.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('Tema', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Light / Dark', style: TextStyle(color: Colors.grey)),
                    ]),
                    const Row(children: [Icon(Icons.wb_sunny_outlined), SizedBox(width: 8), Icon(Icons.nightlight_round)]),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('Backup Data', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Simpan data ke file lokal', style: TextStyle(color: Colors.grey)),
                    ]),
                    OutlinedButton(onPressed: (){}, child: const Text('Backup')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('Export CSV', style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Bagikan riwayat transaksi', style: TextStyle(color: Colors.grey)),
                    ]),
                    OutlinedButton(onPressed: (){}, child: const Text('Export')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text('Tentang MoniMate', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('v1.0.0 • Teman keuangan pribadimu 💰'),
          ),
        ),
      ],
    );
  }
}
