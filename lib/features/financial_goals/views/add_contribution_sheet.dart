import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/goal_model.dart';
import '../controllers/goals_controller.dart';

class AddContributionSheet extends StatefulWidget {
  final GoalModel goal;
  const AddContributionSheet({super.key, required this.goal});

  @override
  State<AddContributionSheet> createState() => _AddContributionSheetState();
}

class _AddContributionSheetState extends State<AddContributionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
  final GoalsController _goalsController = Get.find<GoalsController>();
  double _amount = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isNotEmpty) {
        setState(() => _amount = double.parse(text));
      } else {
        setState(() => _amount = 0);
      }
    });
    
    // Secara otomatis merekomendasikan nominal cicilan per bulan
    final req = _goalsController.calculateRequiredMonthly(widget.goal);
    if (req > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _amountController.text = _currencyFormat.format(req);
      });
    }
  }

  void _submit() {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nominal tabungan tidak boleh kosong'), backgroundColor: Colors.red));
      return;
    }
    
    // Proteksi agar tidak menabung lebih dari sisa yang dibutuhkan
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
    final actualAmount = _amount > remaining ? remaining : _amount;

    _goalsController.addContribution(widget.goal.id, actualAmount, _noteController.text.isEmpty ? 'Tabungan rutin' : _noteController.text);
    final messenger = ScaffoldMessenger.of(context);
    Get.back();
    messenger.showSnackBar(SnackBar(content: Text('Tabungan berhasil ditambahkan ke ${widget.goal.title}!'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 16,
        left: 20, right: 20, top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Isi Tabungan Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text('Target: ${widget.goal.title}', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                labelText: 'Nominal Tabungan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Catatan (Contoh: Gaji bulan April)',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0288D1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submit,
                child: const Text('Simpan Tabungan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
