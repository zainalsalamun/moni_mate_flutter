import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/goal_model.dart';
import '../controllers/goals_controller.dart';

class CreateGoalPage extends StatefulWidget {
  final GoalModel? editGoal;
  const CreateGoalPage({super.key, this.editGoal});

  @override
  State<CreateGoalPage> createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends State<CreateGoalPage> {
  final _amountController = TextEditingController();
  late final TextEditingController _titleController;
  
  double _targetAmount = 0.0;
  DateTime? _targetDate;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);

  final GoalsController _goalsController = Get.find<GoalsController>();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);

    if (widget.editGoal != null) {
      _titleController = TextEditingController(text: widget.editGoal!.title);
      _targetAmount = widget.editGoal!.targetAmount;
      _targetDate = widget.editGoal!.targetDate;
      // Gunakan post frame agar listener tidak memicu trigger loop saat initial set
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _amountController.text = _currencyFormat.format(_targetAmount);
      });
    } else {
      _titleController = TextEditingController(text: "Target Baru");
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isNotEmpty) {
      final value = double.parse(text);
      if (value != _targetAmount) {
        setState(() {
          _targetAmount = value;
        });
      }
    } else {
      setState(() {
        _targetAmount = 0;
      });
    }
  }

  void _addAmount(double add) {
    setState(() {
      _targetAmount += add;
      _amountController.text = _currencyFormat.format(_targetAmount);
    });
  }

  void _setDateByMonths(int months) {
    setState(() {
      _targetDate = DateTime.now().add(Duration(days: 30 * months));
    });
  }

  int get _monthsRemaining {
    if (_targetDate == null) return 0;
    final now = DateTime.now();
    int months = (_targetDate!.year - now.year) * 12 + _targetDate!.month - now.month;
    return months > 0 ? months : 1;
  }

  double get _monthlySaving => _monthsRemaining > 0 ? (_targetAmount / _monthsRemaining) : 0;

  void _confirmDelete() {
    Get.defaultDialog(
      title: 'Hapus Goal?',
      middleText: 'Apakah Anda yakin ingin menghapus target ini? Riwayat tabungan juga akan ikut terhapus.',
      textCancel: 'Batal',
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey[800],
      onConfirm: () {
        _goalsController.deleteGoal(widget.editGoal!.id);
        final messenger = ScaffoldMessenger.of(context);
        Get.back(); // tutup dialog
        Get.back(); // tutup halaman edit
        messenger.showSnackBar(const SnackBar(content: Text('Goal berhasil dihapus!'), backgroundColor: Colors.green));
      }
    );
  }

  void _submit() {
    if (_targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target nominal tidak boleh kosong'), backgroundColor: Colors.red));
      return;
    }
    if (_targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan tentukan target waktu'), backgroundColor: Colors.red));
      return;
    }

    if (widget.editGoal != null) {
      widget.editGoal!.title = _titleController.text.isEmpty ? 'Target Baru' : _titleController.text;
      widget.editGoal!.targetAmount = _targetAmount;
      widget.editGoal!.targetDate = _targetDate!;
      
      if (widget.editGoal!.currentAmount >= widget.editGoal!.targetAmount) {
        widget.editGoal!.status = 'completed';
      } else {
        widget.editGoal!.status = 'active';
      }
      
      widget.editGoal!.save();
      _goalsController.fetchGoals();
      final messenger = ScaffoldMessenger.of(context);
      Get.back();
      messenger.showSnackBar(const SnackBar(content: Text('Goal berhasil diperbarui!'), backgroundColor: Colors.green));
    } else {
      final newGoal = GoalModel(
        title: _titleController.text.isEmpty ? 'Target Baru' : _titleController.text,
        targetAmount: _targetAmount,
        targetDate: _targetDate!,
        colorHex: '#4FC3F7',
      );

      _goalsController.addGoal(newGoal);
      final messenger = ScaffoldMessenger.of(context);
      Get.back();
      messenger.showSnackBar(const SnackBar(content: Text('Goal berhasil dibuat!'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF), 
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  Column(
                    children: [
                      Text(widget.editGoal != null ? 'Edit Goal' : 'Tambah Goal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(widget.editGoal != null ? 'Perbarui target finansialmu' : 'Tentukan target yang ingin kamu capai', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  if (widget.editGoal != null)
                    InkWell(
                      onTap: _confirmDelete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red[700], size: 16),
                            const SizedBox(width: 4),
                            Text('Hapus', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 16),
                          const SizedBox(width: 4),
                          Text('Tips', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    )
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: "Nama Goal (Misal: Beli Motor)",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
  
                    _buildNominalCard(),
                    const SizedBox(height: 16),
                    
                    _buildWaktuCard(),
                    const SizedBox(height: 16),
  
                    if (_targetAmount > 0 && _targetDate != null)
                      _buildPreviewCard(),
                      
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: Text(widget.editGoal != null ? 'Perbarui Goal' : 'Simpan Goal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNominalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[100]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.account_balance_wallet, color: Colors.blue[600]),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Target Nominal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Berapa jumlah yang ingin kamu capai?', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.blue[200]!), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: const BorderRadius.horizontal(left: Radius.circular(11))),
                  child: Text('Rp', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      hintText: "0",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                  onPressed: () {
                    _amountController.clear();
                    setState(() => _targetAmount = 0);
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _nominalChip('+ 1 Jt', 1000000),
                _nominalChip('+ 5 Jt', 5000000),
                _nominalChip('+ 10 Jt', 10000000),
                _nominalChip('+ 25 Jt', 25000000),
                _nominalChip('+ 50 Jt', 50000000),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.stars, color: Colors.blue[400], size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target besar, semangat!', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Mulai dari langkah kecil untuk hasil yang besar.', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.blue[300]),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _nominalChip(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _addAmount(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[100]!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildWaktuCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[100]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.calendar_today, color: Colors.green[600]),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Target Waktu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Kapan kamu ingin mencapai target ini?', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _timeChip('3 Bulan', 3),
                _timeChip('6 Bulan', 6),
                _timeChip('1 Tahun', 12),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) setState(() => _targetDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        const Text('Pilih Tanggal', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          if (_targetDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12), color: Colors.grey[50]),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text(DateFormat('dd MMMM yyyy').format(_targetDate!), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.schedule, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Waktu tersisa: $_monthsRemaining bulan', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Dari hari ini (${DateFormat('dd MMM yyyy').format(DateTime.now())})', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _timeChip(String label, int months) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _setDateByMonths(months),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.blue[100]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.remove_red_eye, color: Colors.blue[800]),
              const SizedBox(width: 8),
              const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Perkiraan perhitungan berdasarkan target kamu', style: TextStyle(color: Colors.blue[800], fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _previewData('Target', 'Rp ${_currencyFormat.format(_targetAmount)}')),
              Expanded(child: _previewData('Waktu', '$_monthsRemaining bulan')),
              Expanded(child: _previewData('Kekurangan', 'Rp ${_currencyFormat.format(_targetAmount)}')),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kamu perlu menabung:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Rp ${_currencyFormat.format(_monthlySaving)} / bulan', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      const Text('Agar target tercapai tepat waktu', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.track_changes, color: Colors.white, size: 40),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _previewData(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.blue[800], fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
