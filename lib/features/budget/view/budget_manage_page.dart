import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/utils/format_currency.dart';
import 'package:monimate/utils/clean_currency.dart';
import '../controller/budget_controller.dart';
import '../model/budget_model.dart';
import 'budget_components.dart';

class BudgetManagePage extends StatefulWidget {
  const BudgetManagePage({super.key});

  @override
  State<BudgetManagePage> createState() => _BudgetManagePageState();
}

class _BudgetManagePageState extends State<BudgetManagePage> {
  final budgetC = Get.find<BudgetController>();
  final txC = Get.find<TransactionController>();

  final _limitController = TextEditingController();
  String? selectedCategory;
  BudgetPeriod selectedPeriod = BudgetPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Budgeting',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStrictModeToggle(),
                    const SizedBox(height: 12),
                    _buildAddBudgetCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Budget Aktif',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (budgetC.budgetUsages.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('Belum ada budget yang diset.'),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final usage = budgetC.budgetUsages[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            BudgetProgressBar(usage: usage),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      _showEditBudget(usage.budget),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Edit'),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () =>
                                      budgetC.deleteBudget(usage.budget.id),
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16, color: Colors.pink),
                                  label: const Text('Hapus',
                                      style: TextStyle(color: Colors.pink)),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                    childCount: budgetC.budgetUsages.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
  }

  Widget _buildStrictModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: budgetC.isStrictMode.value
            ? Colors.redAccent.withOpacity(0.05)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: budgetC.isStrictMode.value
              ? Colors.redAccent.withOpacity(0.3)
              : Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: SwitchListTile(
        title: const Text('Strict Mode 🔒',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Cegah transaksi jika melebih budget.'),
        value: budgetC.isStrictMode.value,
        onChanged: (val) => budgetC.isStrictMode.value = val,
        activeColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildAddBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tambah Budget Baru 🎯',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            hint: const Text('Pilih Kategori'),
            items: _getExpenseCategories().map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat.capitalizeFirst!),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedCategory = val;
                if (val != null) {
                  final suggestion = budgetC.suggestBudget(val);
                  if (suggestion > 0) {
                    final formatted = CurrencyFormat.format(suggestion)
                        .replaceAll(RegExp(r'Rp\.?\s*'), '');
                    _limitController.text = formatted;
                  }
                }
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).canvasColor,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Limit Budget (Rp)',
              prefixText: 'Rp. ',
              filled: true,
              fillColor: Theme.of(context).canvasColor,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (value) {
              final clean = cleanCurrency(value);
              final formatted = CurrencyFormat.format(clean)
                  .replaceAll(RegExp(r'Rp\.?\s*'), '');

              if (value != formatted) {
                _limitController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan Budget',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          if (selectedCategory != null &&
              budgetC.suggestBudget(selectedCategory!) > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '💡 AI menyarankan budget ${CurrencyFormat.format(budgetC.suggestBudget(selectedCategory!))}',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  List<String> _getExpenseCategories() {
    // Standard categories + custom ones
    final standards = [
      'makan',
      'minum',
      'transport',
      'hiburan',
      'belanja',
      'kesehatan',
      'pendidikan',
      'tagihan'
    ];
    final custom = txC.customExpenseCategories.map((e) => e.name).toList();
    return {...standards, ...custom}.toList();
  }

  void _saveBudget() {
    if (selectedCategory == null || _limitController.text.isEmpty) {
      Get.snackbar('Error', 'Lengkapi kategori dan limit budget');
      return;
    }

    final limit = cleanCurrency(_limitController.text);
    if (limit <= 0) {
      Get.snackbar('Error', 'Limit harus lebih dari 0');
      return;
    }

    budgetC.addBudget(selectedCategory!, limit);
    _limitController.clear();
    setState(() {
      selectedCategory = null;
    });

    Get.snackbar('Berhasil', 'Budget kategori ini berhasil disimpan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }

  void _showEditBudget(BudgetModel budget) {
    _limitController.text = budget.monthlyLimit.toStringAsFixed(0);
    selectedCategory = budget.categoryId;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Budget ${budget.categoryId.capitalizeFirst}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Limit Baru',
                prefixText: 'Rp ',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                final clean = cleanCurrency(value);
                final formatted = CurrencyFormat.format(clean)
                    .replaceAll(RegExp(r'Rp\.?\s*'), '');

                if (value != formatted) {
                  _limitController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final limit = cleanCurrency(_limitController.text);
                if (limit > 0) {
                  budgetC.addBudget(budget.categoryId, limit);
                  Get.back();
                }
              },
              child: const Text('Update Budget'),
            )
          ],
        ),
      ),
    );
  }
}
