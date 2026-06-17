import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../data/models/wallet_model.dart';

class WalletManagePage extends StatelessWidget {
  const WalletManagePage({super.key});

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
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
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _parseColor(wallet.colorHex).withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(wallet.icon, style: const TextStyle(fontSize: 24)),
          ),
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
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${_walletTypeLabel(wallet.type)} • Rp ${_formatBalance(wallet.balance)}',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'set_default') {
              walletC.setActiveWallet(wallet.id);
              Get.snackbar('Berhasil', '${wallet.name} dijadikan dompet aktif',
                  snackPosition: SnackPosition.TOP);
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
    String selectedType = 'cash';
    String selectedIcon = '💰';
    String selectedColor = '#0288D1';

    final icons = ['💰', '🏦', '📱', '💳', '🪙', '💎', '🏧', '🫰'];
    final colors = [
      '#0288D1',
      '#4CAF50',
      '#FF9800',
      '#9C27B0',
      '#E91E63',
      '#00BCD4',
      '#607D8B',
      '#795548',
    ];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 20),
                  const Text(
                    'Tambah Dompet Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameC,
                    decoration: InputDecoration(
                      labelText: 'Nama Dompet',
                      hintText: 'Contoh: BCA, GoPay, Cash',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tipe Dompet',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _typeChip('cash', '💵 Tunai', selectedType,
                          (v) => setState(() => selectedType = v)),
                      _typeChip('bank', '🏦 Bank', selectedType,
                          (v) => setState(() => selectedType = v)),
                      _typeChip('ewallet', '📱 E-Wallet', selectedType,
                          (v) => setState(() => selectedType = v)),
                      _typeChip('investment', '📈 Investasi', selectedType,
                          (v) => setState(() => selectedType = v)),
                      _typeChip('other', '📦 Lainnya', selectedType,
                          (v) => setState(() => selectedType = v)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Ikon',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: icons
                        .map((icon) => GestureDetector(
                              onTap: () => setState(() => selectedIcon = icon),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: selectedIcon == icon
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.15)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: selectedIcon == icon
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2)
                                      : null,
                                ),
                                child: Center(
                                    child: Text(icon,
                                        style: const TextStyle(fontSize: 22))),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Warna',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colors
                        .map((color) => GestureDetector(
                              onTap: () =>
                                  setState(() => selectedColor = color),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _parseColor(color),
                                  shape: BoxShape.circle,
                                  border: selectedColor == color
                                      ? Border.all(
                                          color: Colors.white, width: 3)
                                      : null,
                                  boxShadow: selectedColor == color
                                      ? [
                                          BoxShadow(
                                            color: _parseColor(color)
                                                .withOpacity(0.5),
                                            blurRadius: 8,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameC.text.trim().isEmpty) {
                          Get.snackbar('Error', 'Nama dompet wajib diisi',
                              snackPosition: SnackPosition.TOP);
                          return;
                        }
                        walletC.addWallet(
                          name: nameC.text.trim(),
                          type: selectedType,
                          icon: selectedIcon,
                          colorHex: selectedColor,
                        );
                        Get.back();
                        Get.snackbar('Berhasil',
                            'Dompet "${nameC.text.trim()}" ditambahkan',
                            snackPosition: SnackPosition.TOP);
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
                  const SizedBox(height: 16),
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
              walletC.deleteWallet(wallet.id);
              Get.back();
              Get.snackbar('Terhapus', 'Dompet "${wallet.name}" dihapus',
                  snackPosition: SnackPosition.TOP);
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

  static Color _parseColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
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

  static String _formatBalance(double balance) {
    if (balance >= 1000000000) {
      return '${(balance / 1000000000).toStringAsFixed(1)}M';
    } else if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(1)}jt';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(1)}rb';
    }
    return balance.toStringAsFixed(0);
  }
}
