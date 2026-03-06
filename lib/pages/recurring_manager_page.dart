import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/recurring_controller.dart';
import 'package:monimate/utils/format_currency.dart';
import 'package:monimate/utils/date_formater.dart';
import 'package:monimate/utils/clean_currency.dart';
import 'package:monimate/data/controller/transaction_controller.dart';

class RecurringManagerPage extends StatelessWidget {
  const RecurringManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RecurringController>()) {
      Get.put(RecurringController());
    }
    final c = Get.find<RecurringController>();
    final txC =
        Get.find<TransactionController>(); // For category emoji & colors

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Rutin'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (c.recurrings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_repeat,
                    size: 80,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'Belum Ada Transaksi Rutin',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Otomatisasi tagihan atau gajimu di sini.',
                  style: TextStyle(color: Colors.grey.shade600),
                )
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: c.recurrings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final rec = c.recurrings[i];
            final isIncome = rec.type == 'income';

            return Dismissible(
              key: Key(rec.id),
              direction: DismissDirection.endToStart,
              background: Container(
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16)),
                alignment: Alignment.centerRight,
                child: const Icon(Icons.delete_outline,
                    color: Colors.white, size: 28),
              ),
              onDismissed: (_) {
                c.deleteRecurring(rec.id);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ??
                      Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isIncome
                        ? Colors.green.withOpacity(0.15)
                        : Colors.redAccent.withOpacity(0.15),
                    radius: 24,
                    child: Text(
                      txC.getEmoji(rec.category),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  title: Text(
                    rec.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiap ${rec.interval > 1 ? '${rec.interval} ' : ''}${rec.repeatType.capitalizeFirst}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Next: ${DateFormatter.format(rec.nextExecutionDate)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'} ${CurrencyFormat.format(rec.amount)}',
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.redAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 24,
                        child: Switch.adaptive(
                          value: rec.isActive,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (val) => c.toggleActive(rec.id, val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => _showAddRecurringModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddRecurringModal(BuildContext context) {
    String type = 'expense';
    String category = 'makan';
    String repeatType = 'bulanan';
    int interval = 1;
    DateTime startDate = DateTime.now();
    DateTime? endDate;

    final nameC = TextEditingController();
    final nominalC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          final expenseDropdown = [
            {'value': 'makan', 'label': '🍔 Makan'},
            {'value': 'minum', 'label': '🥤 Minum'},
            {'value': 'transport', 'label': '🚗 Transport'},
            {'value': 'tagihan', 'label': '💡 Tagihan'},
            {'value': 'hiburan', 'label': '🎮 Hiburan'},
            {'value': 'lainnya', 'label': '🧩 Lainnya'},
          ];
          final incomeDropdown = [
            {'value': 'gaji', 'label': '💼 Gaji'},
            {'value': 'bonus', 'label': '🎁 Bonus'},
            {'value': 'investasi', 'label': '📈 Investasi'},
            {'value': 'lainnya_masuk', 'label': '🧩 Lainnya'},
          ];

          final currentDropdown =
              type == 'expense' ? expenseDropdown : incomeDropdown;
          if (!currentDropdown.any((e) => e['value'] == category)) {
            category = currentDropdown.first['value']!;
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Buat Transaksi Rutin',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tipe
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2D3748)
                          : const Color(0xFFEDF2F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => type = 'expense'),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: type == 'expense'
                                    ? Colors.redAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text('Pengeluaran',
                                  style: TextStyle(
                                      color: type == 'expense'
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => type = 'income'),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: type == 'income'
                                    ? Colors.green
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text('Pemasukan',
                                  style: TextStyle(
                                      color: type == 'income'
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameC,
                    decoration: const InputDecoration(
                        labelText: 'Nama Transaksi (mis: Bayar Kos)'),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nominalC,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Nominal (Rp)', prefixText: 'Rp. '),
                    onChanged: (value) {
                      final clean = cleanCurrency(value);
                      final formatted = CurrencyFormat.format(clean)
                          .replaceAll(RegExp(r'Rp\.?\s*'), '');
                      if (value != formatted) {
                        nominalC.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length));
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: currentDropdown
                        .map((c) => DropdownMenuItem(
                            value: c['value']!, child: Text(c['label']!)))
                        .toList(),
                    onChanged: (val) => setState(() => category = val!),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: repeatType,
                          decoration:
                              const InputDecoration(labelText: 'Perulangan'),
                          items: const [
                            DropdownMenuItem(
                                value: 'harian', child: Text('Harian')),
                            DropdownMenuItem(
                                value: 'mingguan', child: Text('Mingguan')),
                            DropdownMenuItem(
                                value: 'bulanan', child: Text('Bulanan')),
                            DropdownMenuItem(
                                value: 'tahunan', child: Text('Tahunan')),
                          ],
                          onChanged: (val) => setState(() => repeatType = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) setState(() => startDate = date);
                          },
                          child: InputDecorator(
                            decoration:
                                const InputDecoration(labelText: 'Mulai Dari'),
                            child: Text(DateFormatter.format(startDate)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: endDate ??
                                  startDate.add(const Duration(days: 30)),
                              firstDate: startDate,
                              lastDate: DateTime(2100),
                            );
                            if (date != null) setState(() => endDate = date);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                                labelText: 'Berakhir (Opsional)'),
                            child: Text(endDate == null
                                ? 'Selamanya'
                                : DateFormatter.format(endDate!)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (endDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => endDate = null),
                        child: const Text('Hapus Batas Waktu',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16))),
                      onPressed: () {
                        if (nameC.text.isEmpty || nominalC.text.isEmpty) {
                          Get.snackbar('Gagal', 'Nama dan nominal harus diisi',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white);
                          return;
                        }
                        Get.find<RecurringController>().addRecurring(
                            nameC.text,
                            cleanCurrency(nominalC.text),
                            category,
                            type,
                            repeatType,
                            interval,
                            startDate,
                            endDate);
                        Navigator.pop(context);
                      },
                      child: const Text('Simpan Rutinitas',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
