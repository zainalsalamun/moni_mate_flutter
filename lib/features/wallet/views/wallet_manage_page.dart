import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../data/models/wallet_model.dart';
import '../../../utils/wallet_brand.dart';
import '../../../utils/wallet_brand_logo.dart';
import '../../../utils/format_currency.dart';

class WalletManagePage extends StatelessWidget {
  const WalletManagePage({super.key});

  void _showSnack(String title, String message) {
    final messenger = ScaffoldMessenger.of(Get.context!);
    messenger.showSnackBar(
      SnackBar(
        content: Text('$title: $message'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletC = Get.find<WalletController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Dompet'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (walletC.wallets.isEmpty) {
          return const Center(child: Text('Belum ada dompet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: walletC.wallets.length,
          itemBuilder: (context, index) {
            final wallet = walletC.wallets[index];
            final isActive = walletC.activeWallet.value?.id == wallet.id;
            return _buildWalletCard(context, wallet, isActive, walletC);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWalletSheet(context, walletC),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Dompet'),
      ),
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    WalletModel wallet,
    bool isActive,
    WalletController walletC,
  ) {
    final brand = WalletBrand.getBrand(wallet.name, wallet.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(
                color: brand.color,
                width: 2,
              )
            : Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
              ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: brand.color.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: WalletBrandLogo(
          name: wallet.name,
          type: wallet.type,
          size: 48,
          borderRadius: 14,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                wallet.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: brand.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: brand.color,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${_walletTypeLabel(wallet.type)} • ${CurrencyFormat.format(wallet.balance)}',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'set_default') {
              walletC.setActiveWallet(wallet.id);
              _showSnack('Berhasil', '${wallet.name} dijadikan dompet aktif');
            } else if (value == 'edit') {
              _showEditWalletSheet(context, walletC, wallet);
            } else if (value == 'delete') {
              _confirmDelete(context, walletC, wallet);
            }
          },
          itemBuilder: (context) => [
            if (!isActive)
              const PopupMenuItem(
                value: 'set_default',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Jadikan Aktif'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (walletC.wallets.length > 1)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 20, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
        onTap: () => walletC.setActiveWallet(wallet.id),
      ),
    );
  }

  void _showAddWalletSheet(BuildContext context, WalletController walletC) {
    final nameC = TextEditingController();
    final balanceC = TextEditingController();
    String selectedType = 'cash';

    // Popular bank/wallet presets with brand colors and icons
    final presets = <Map<String, dynamic>>[
      {'name': 'Bank BCA', 'type': 'bank', 'color': const Color(0xFF0033A0)},
      {
        'name': 'Bank Mandiri',
        'type': 'bank',
        'color': const Color(0xFF003D79)
      },
      {'name': 'Bank BRI', 'type': 'bank', 'color': const Color(0xFF003D79)},
      {'name': 'Bank BNI', 'type': 'bank', 'color': const Color(0xFFEE7623)},
      {'name': 'SeaBank', 'type': 'bank', 'color': const Color(0xFFF58220)},
      {'name': 'GoPay', 'type': 'ewallet', 'color': const Color(0xFF00AED6)},
      {'name': 'OVO', 'type': 'ewallet', 'color': const Color(0xFF4C3494)},
      {'name': 'DANA', 'type': 'ewallet', 'color': const Color(0xFF108EE9)},
      {
        'name': 'ShopeePay',
        'type': 'ewallet',
        'color': const Color(0xFFEE4D2D)
      },
      {'name': 'LinkAja', 'type': 'ewallet', 'color': const Color(0xFFDD2C2E)},
      {'name': 'Bibit', 'type': 'investment', 'color': const Color(0xFF00A85A)},
      {'name': 'Cash', 'type': 'cash', 'color': const Color(0xFF4CAF50)},
    ];

    Map<String, dynamic>? selectedPreset;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          final mediaQuery = MediaQuery.of(context);
          final maxH = mediaQuery.size.height * 0.85;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Container(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 24, bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih Dompet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih bank/e-wallet favorit atau buat custom',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dompet Populer',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: presets.length,
                            itemBuilder: (context, idx) {
                              final p = presets[idx];
                              final isSelected =
                                  selectedPreset?['name'] == p['name'];
                              final presetName = p['name'] as String;
                              final presetType = p['type'] as String;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedPreset = p;
                                    selectedType = presetType;
                                    nameC.text = presetName;
                                  });
                                },
                                child: Column(
                                  children: [
                                    WalletBrandLogo(
                                      name: presetName,
                                      type: presetType,
                                      size: 56,
                                      borderRadius: 16,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      presetName,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Atau Buat Custom',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: nameC,
                            onChanged: (_) {
                              if (selectedPreset != null) {
                                setState(() => selectedPreset = null);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Nama Dompet',
                              hintText: 'Ketik nama dompet...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              prefixIcon: const Icon(Icons.edit),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Tipe Dompet',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _typeChip('cash', '💵 Tunai', selectedType,
                                  (v) => setState(() => selectedType = v)),
                              _typeChip('bank', '🏦 Bank', selectedType,
                                  (v) => setState(() => selectedType = v)),
                              _typeChip('ewallet', '📱 E-Wallet', selectedType,
                                  (v) => setState(() => selectedType = v)),
                              _typeChip(
                                  'investment',
                                  '📈 Investasi',
                                  selectedType,
                                  (v) => setState(() => selectedType = v)),
                              _typeChip('other', '📦 Lainnya', selectedType,
                                  (v) => setState(() => selectedType = v)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: balanceC,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CurrencyInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Saldo Awal',
                              hintText: '0',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              prefixIcon:
                                  const Icon(Icons.account_balance_wallet),
                              prefixText: 'Rp ',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameC.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama dompet wajib diisi'),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(12),
                            ),
                          );
                          return;
                        }
                        final brand =
                            WalletBrand.getBrand(nameC.text, selectedType);
                        String colorHex =
                            '#${brand.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                        if (selectedPreset != null) {
                          final brandColor = selectedPreset!['color'] as Color;
                          colorHex =
                              '#${brandColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                        }

                        final initialBalance = double.tryParse(
                                balanceC.text.replaceAll('.', '')) ??
                            0.0;

                        final walletName = nameC.text.trim();
                        walletC.addWallet(
                          name: walletName,
                          type: selectedType,
                          icon: '',
                          colorHex: colorHex,
                          initialBalance: initialBalance,
                        );
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          final messenger = ScaffoldMessenger.of(Get.context!);
                          messenger.showSnackBar(SnackBar(
                            content: Text('Dompet "${nameC.text}" ditambahkan'),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ));
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showEditWalletSheet(
      BuildContext context, WalletController walletC, WalletModel wallet) {
    final nameC = TextEditingController(text: wallet.name);
    final balanceC = TextEditingController(
      text: wallet.balance > 0
          ? CurrencyFormat.format(wallet.balance).replaceAll('Rp ', '')
          : '',
    );
    String selectedType = wallet.type;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          final mediaQuery = MediaQuery.of(context);
          final maxH = mediaQuery.size.height * 0.85;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Container(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 24, bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Edit Dompet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ubah nama atau tipe dompet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Preview
                          Center(
                            child: WalletBrandLogo(
                              name: nameC.text,
                              type: selectedType,
                              size: 64,
                              borderRadius: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nameC,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Nama Dompet',
                              hintText: 'Ketik nama dompet...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              prefixIcon: const Icon(Icons.edit),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Tipe Dompet',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _typeChip('cash', '💵 Tunai', selectedType,
                                  (v) => setState(() => selectedType = v)),
                              _typeChip('bank', '🏦 Bank', selectedType,
                                  (v) => setState(() => selectedType = v)),
                              _typeChip('ewallet', '📱 E-Wallet', selectedType,
                                  (v) => setState(() => selectedType = v)),
                              _typeChip(
                                  'investment',
                                  '📈 Investasi',
                                  selectedType,
                                  (v) => setState(() => selectedType = v)),
                              _typeChip('other', '📦 Lainnya', selectedType,
                                  (v) => setState(() => selectedType = v)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: balanceC,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CurrencyInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Saldo',
                              hintText: '0',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              prefixIcon:
                                  const Icon(Icons.account_balance_wallet),
                              prefixText: 'Rp ',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameC.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nama dompet wajib diisi'),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(12),
                            ),
                          );
                          return;
                        }
                        final brand =
                            WalletBrand.getBrand(nameC.text, selectedType);
                        String colorHex =
                            '#${brand.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

                        final newBalance = double.tryParse(
                                balanceC.text.replaceAll('.', '')) ??
                            wallet.balance;

                        wallet.name = nameC.text.trim();
                        wallet.type = selectedType;
                        wallet.colorHex = colorHex;
                        wallet.balance = newBalance;
                        wallet.updatedAt = DateTime.now();
                        walletC.updateWallet(wallet);

                        final walletName = nameC.text.trim();
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          final messenger = ScaffoldMessenger.of(Get.context!);
                          messenger.showSnackBar(SnackBar(
                            content: Text('Dompet "$walletName" diperbarui'),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 2),
                          ));
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(
      BuildContext context, WalletController walletC, WalletModel wallet) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Dompet?'),
        content: Text(
            'Dompet "${wallet.name}" akan dihapus. Transaksi terkait tidak akan terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final walletName = wallet.name;
              walletC.deleteWallet(wallet.id);
              Get.back();
              Future.delayed(const Duration(milliseconds: 500), () {
                final messenger = ScaffoldMessenger.of(Get.context!);
                messenger.showSnackBar(SnackBar(
                  content: Text('Dompet "$walletName" dihapus'),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ));
              });
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Widget _typeChip(
      String value, String label, String selected, Function(String) onTap) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? null : null,
        side: isSelected ? null : BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static String _walletTypeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Tunai';
      case 'bank':
        return 'Bank';
      case 'ewallet':
        return 'E-Wallet';
      case 'investment':
        return 'Investasi';
      default:
        return 'Lainnya';
    }
  }
}
