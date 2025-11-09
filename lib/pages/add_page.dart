
import 'package:flutter/material.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ToggleButtons(
          isSelected: const [false, true],
          borderRadius: BorderRadius.circular(14),
          children: const [Padding(padding: EdgeInsets.all(10), child: Text('Pemasukan')), Padding(padding: EdgeInsets.all(10), child: Text('Pengeluaran'))],
          onPressed: (_){},
        ),
        const SizedBox(height: 16),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Nominal',
            hintText: 'Rp 0',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          items: const [
            DropdownMenuItem(value: 'makan', child: Text('🍔 Makan')),
            DropdownMenuItem(value: 'transport', child: Text('🚗 Transport')),
            DropdownMenuItem(value: 'hiburan', child: Text('🎮 Hiburan')),
            DropdownMenuItem(value: 'gaji', child: Text('💼 Pemasukan')),
          ],
          onChanged: (_){},
          decoration: InputDecoration(
            labelText: 'Kategori',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.calendar_month), label: const Text('3 Nov 2025')),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Deskripsi (opsional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: (){}, child: const Text('Simpan Transaksi')),
      ],
    );
  }
}
