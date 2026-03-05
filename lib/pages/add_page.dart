import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/utils/clean_currency.dart';
import 'package:monimate/utils/format_currency.dart';
import 'package:monimate/data/services/receipt_scanner_service.dart';
import 'package:monimate/features/budget/controller/budget_controller.dart';

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

  bool isScanning = false;

  Future<void> _startScan() async {
    final result = await ReceiptScannerService.scanReceipt();
    if (result != null) {
      setState(() {
        if (result['amount'] != null) {
          nominalC.text = CurrencyFormat.format(result['amount'])
              .replaceAll(RegExp(r'Rp\.?\s*'), '');
        }
        if (result['merchant'] != null && result['merchant'].isNotEmpty) {
          descC.text = result['merchant'];
        }
      });

      Get.snackbar(
        "Scan Berhasil",
        "Data struk telah disalin ke form.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
      );
    }
  }

  // Kategori default berdasarkan tipe transaksi
  final List<Map<String, String>> expenseCategories = [
    {'value': 'makan', 'label': '🍔 Makan', 'color': 'FFF59E0B'},
    {'value': 'minum', 'label': '🥤 Minum', 'color': 'FF3B82F6'},
    {'value': 'transport', 'label': '🚗 Transport', 'color': 'FF10B981'},
    {'value': 'hiburan', 'label': '🎮 Hiburan', 'color': 'FF8B5CF6'},
    {'value': 'belanja', 'label': '🛍️ Belanja', 'color': 'FFEC4899'},
    {'value': 'kesehatan', 'label': '💊 Kesehatan', 'color': 'FFEF4444'},
    {'value': 'pendidikan', 'label': '📚 Pendidikan', 'color': 'FF6366F1'},
    {'value': 'tagihan', 'label': '💡 Tagihan', 'color': 'FFF59E0B'},
    {'value': 'lainnya', 'label': '🧩 Lainnya', 'color': 'FF6B7280'},
  ];

  final List<Map<String, String>> incomeCategories = [
    {'value': 'gaji', 'label': '💼 Gaji', 'color': 'FF10B981'},
    {'value': 'bonus', 'label': '🎁 Bonus', 'color': 'FFF59E0B'},
    {'value': 'investasi', 'label': '📈 Investasi', 'color': 'FF3B82F6'},
    {'value': 'freelance', 'label': '💻 Freelance', 'color': 'FF8B5CF6'},
    {'value': 'hadiah', 'label': '🧧 Hadiah', 'color': 'FFEC4899'},
    {'value': 'lainnya_masuk', 'label': '🧩 Lainnya', 'color': 'FF6B7280'},
  ];

  @override
  Widget build(BuildContext context) {
    // Gabung default kategori dari asset statis dengan kategori dari Hive database
    final customCategories = type == 'expense'
        ? controller.customExpenseCategories
        : controller.customIncomeCategories;

    final List<Map<String, String>> currentCategories = [
      ...(type == 'expense' ? expenseCategories : incomeCategories),
      ...customCategories.map((c) => {
            'value': c.id,
            'label': '${c.emoji} ${c.name}',
            'color':
                'FF10B981', // Default green highlight warna jika dicustomize
            'isCustom': 'true'
          })
    ];

    // Pastikan kategori yang dipilih valid untuk tipe yang aktif
    if (!currentCategories.any((cat) => cat['value'] == category)) {
      category = currentCategories.first['value']!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: "Scan Struk (AI)",
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.document_scanner_rounded,
                  color: Theme.of(context).colorScheme.primary),
            ),
            onPressed: _startScan,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Toggle Switch
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ??
                    Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2D3748)
                      : const Color(0xFFEDF2F7),
                ),
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
                              ? Colors.redAccent.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Pengeluaran',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: type == 'expense'
                                ? Colors.redAccent
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                          ),
                        ),
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
                              ? Colors.greenAccent.withOpacity(0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Pemasukan',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: type == 'income'
                                ? Colors.green
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nominal Input (Big Text)
            Text(
              'Nominal',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2D3748)
                      : const Color(0xFFEDF2F7),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Rp.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: nominalC,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: '0',
                        filled: false,
                      ),
                      onChanged: (value) {
                        final clean = cleanCurrency(value);
                        final formatted = CurrencyFormat.format(clean)
                            .replaceAll(RegExp(r'Rp\.?\s*'), '');

                        if (value != formatted) {
                          nominalC.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category Selection (Grid Layout)
            Text(
              'Pilih Kategori',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final customCategories = type == 'expense'
                  ? controller.customExpenseCategories
                  : controller.customIncomeCategories;

              final List<Map<String, String>> currentObsCategories = [
                ...(type == 'expense' ? expenseCategories : incomeCategories),
                ...customCategories.map((c) => {
                      'value': c.id,
                      'label': '${c.emoji} ${c.name}',
                      'color': 'FF10B981',
                      'isCustom': 'true'
                    })
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount:
                    currentObsCategories.length + 1, // + 1 untuk tombol Add
                itemBuilder: (context, index) {
                  if (index == currentObsCategories.length) {
                    // Tombol tambah kategori custom
                    return GestureDetector(
                      onTap: () => _showAddCategoryModal(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28),
                            const SizedBox(height: 4),
                            Text(
                              'Buat Baru',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  final cat = currentObsCategories[index];
                  final isSelected = category == cat['value'];
                  final isCustom = cat['isCustom'] == 'true';

                  final parts = cat['label']!.split(' ');
                  final emoji = parts[0];
                  final text = parts.sublist(1).join(' ');

                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => category = cat['value']!),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.15)
                                : Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2D3748)
                                      : const Color(0xFFEDF2F7)),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(emoji,
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Delete button untuk custom category (hanya terlihat jika dipilih)
                      if (isCustom && isSelected)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () {
                              controller.deleteCustomCategory(cat['value']!);
                              // Reset pilihan setelah dihapus
                              setState(() => category =
                                  currentObsCategories.first['value']!);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        )
                    ],
                  );
                },
              );
            }),
            const SizedBox(height: 24),

            // Description Input
            Text(
              'Catatan Tambahan',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descC,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Tulis deskripsi atau catatan singkat...',
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2D3748)
                        : const Color(0xFFEDF2F7),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2D3748)
                        : const Color(0xFFEDF2F7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Modern Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                ),
                onPressed: () {
                  final amountText = nominalC.text;
                  if (amountText.isEmpty) {
                    Get.snackbar("Error", "Nominal tidak boleh kosong",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16));
                    return;
                  }

                  final amount = cleanCurrency(amountText);
                  if (amount <= 0) {
                    Get.snackbar("Error", "Nominal harus lebih dari 0",
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16));
                    return;
                  }

                  // Strict Mode Check
                  if (type == 'expense' &&
                      Get.isRegistered<BudgetController>()) {
                    final budgetC = Get.find<BudgetController>();
                    if (budgetC.isStrictMode.value) {
                      final usage = budgetC.budgetUsages.firstWhereOrNull((u) =>
                          u.budget.categoryId.toLowerCase() ==
                          category.toLowerCase());
                      if (usage != null &&
                          usage.currentUsage + amount >
                              usage.budget.monthlyLimit) {
                        Get.snackbar(
                          "Strict Mode Aktif 🔒",
                          "Transaksi ini melebihi budget ${category.capitalizeFirst}. Silakan sesuaikan budget atau matikan Strict Mode.",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 4),
                        );
                        return;
                      }
                    }
                  }

                  controller.addTransaction(type, category, amount, descC.text);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 64,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Berhasil!",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Data transaksi telah berhasil disimpan.",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "Tutup",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  nominalC.clear();
                  descC.clear();
                  FocusScope.of(context).unfocus();

                  // Optional: Return to Dashboard (Home) automatically after success
                  // Get.find<ShellController>().changeTab(0);
                },
                child: const Text(
                  'Simpan Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for navigation bar
          ],
        ),
      ),
    );
  }

  // Modal dialog untuk menambah kategori baru
  void _showAddCategoryModal(BuildContext context) {
    final TextEditingController nameCatC = TextEditingController();
    final TextEditingController emojiCatC =
        TextEditingController(text: '💰'); // Default emoji

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tambah Kategori Baru',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close))
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Input Emoji
                      Container(
                        width: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).cardTheme.color),
                        child: TextField(
                          controller: emojiCatC,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 28),
                          maxLength: 2,
                          decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Input Name
                      Expanded(
                        child: TextField(
                          controller: nameCatC,
                          decoration: InputDecoration(
                            labelText: 'Nama Kategori',
                            hintText: 'Misal: Asuransi',
                            filled: true,
                            fillColor: Theme.of(context).cardTheme.color,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (nameCatC.text.isEmpty || emojiCatC.text.isEmpty) {
                          Get.snackbar(
                              "Error", "Nama dan Emoji tidak boleh kosong",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white);
                          return;
                        }

                        controller.addCustomCategory(
                            type, nameCatC.text, emojiCatC.text);
                        Navigator.pop(context); // Tutup modal
                        Get.snackbar("Berhasil",
                            "Kategori '${nameCatC.text}' ditambahkan!",
                            backgroundColor: Colors.green,
                            colorText: Colors.white);
                      },
                      child: const Text('Simpan Kategori'),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
