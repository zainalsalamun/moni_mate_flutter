import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/utils/format_currency.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TransactionController controller = Get.find();

  String type = 'expense';
  String category = 'makan';
  final TextEditingController nominalC = TextEditingController();
  final TextEditingController descC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ToggleButtons(
          isSelected: [type == 'income', type == 'expense'],
          borderRadius: BorderRadius.circular(14),
          onPressed: (i) {
            setState(() => type = i == 0 ? 'income' : 'expense');
          },
          children: const [
            Padding(padding: EdgeInsets.all(10), child: Text('Pemasukan')),
            Padding(padding: EdgeInsets.all(10), child: Text('Pengeluaran')),
          ],
        ),
        const SizedBox(height: 16),

        TextField(
          controller: nominalC,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final cleanText = value.replaceAll(RegExp(r'[^0-9]'), '');

            if (cleanText.isEmpty) {
              nominalC.value = const TextEditingValue(
                text: '',
                selection: TextSelection.collapsed(offset: 0),
              );
              return;
            }

            final amount = double.tryParse(cleanText) ?? 0;
            final formatted =
                CurrencyFormat.format(amount).replaceAll('Rp ', '');

            if (value != formatted) {
              nominalC.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
          decoration: InputDecoration(
            labelText: 'Nominal',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: category,
          items: const [
            DropdownMenuItem(value: 'makan', child: Text('🍔 Makan')),
            DropdownMenuItem(value: 'minum', child: Text('🥤 Minum')),
            DropdownMenuItem(value: 'transport', child: Text('🚗 Transport')),
            DropdownMenuItem(value: 'hiburan', child: Text('🎮 Hiburan')),
            DropdownMenuItem(value: 'gaji', child: Text('💼 Pemasukan')),
            DropdownMenuItem(value: 'belanja', child: Text('🛍️ Belanja')),
            DropdownMenuItem(value: 'kesehatan', child: Text('💊 Kesehatan')),
            DropdownMenuItem(value: 'pendidikan', child: Text('📚 Pendidikan')),
            DropdownMenuItem(value: 'tagihan', child: Text('💡 Tagihan')),
            DropdownMenuItem(value: 'lainnya', child: Text('🧩 Lainnya')),
          ],
          onChanged: (v) => setState(() => category = v!),
          decoration: InputDecoration(
            labelText: 'Kategori',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 12),

        // Deskripsi
        TextField(
          controller: descC,
          decoration: InputDecoration(
            labelText: 'Deskripsi (opsional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          icon: const Icon(Icons.save_outlined),
          label: const Text('Simpan Transaksi'),
          onPressed: () {
            final clean = nominalC.text.replaceAll(RegExp(r'[^0-9]'), '');
            final amount = double.tryParse(clean) ?? 0;

            if (amount <= 0) {
              Get.snackbar(
                  'Nominal tidak valid', 'Masukkan nominal yang benar');
              return;
            }

            controller.addTransaction(type, category, amount, descC.text);

            Get.snackbar('Berhasil', 'Transaksi disimpan!');

            nominalC.clear();
            descC.clear();
            FocusScope.of(context).unfocus();
          },
        ),
      ],
    );
  }
}
