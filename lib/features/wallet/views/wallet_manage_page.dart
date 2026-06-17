import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../data/models/wallet_model.dart';
import '../../../utils/wallet_brand.dart';

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
    final brand = WalletBrand.getBrand(wallet.name, wallet.type);
    final fallbackIcon = WalletBrand.getFallbackIcon(wallet.name, wallet.type);

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
        leading: _buildBrandLogo(brand, fallbackIcon),
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

  /// Build a beautiful brand-style logo with gradient background
  Widget _buildBrandLogo(WalletBrand brand, IconData fallbackIcon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            brand.color,
            brand.color.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: brand.color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  void _showAddWalletSheet(BuildContext context, WalletController walletC) {
    final nameC = TextEditingController();
    String selectedType = 'cash';

    // Popular bank/wallet presets with brand colors and icons
    final presets = <Map<String, dynamic>>[
      {
        'name': 'BCA',
        'type': 'bank',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF003DA5)
      },
      {
        'name': 'Mandiri',
        'type': 'bank',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF003D6B)
      },
      {
        'name': 'BNI',
        'type': 'bank',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFFED1C24)
      },
      {
        'name': 'BRI',
        'type': 'bank',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF003DA5)
      },
      {
        'name': 'BSI',
        'type': 'bank',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF1A6B3C)
      },
      {
        'name': 'CIMB Niaga',
        'type': 'bank',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF8B0000)
      },
      {
        'name': 'GoPay',
        'type': 'ewallet',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF00AED6)
      },
      {
        'name': 'OVO',
        'type': 'ewallet',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF4C3494)
      },
      {
        'name': 'DANA',
        'type': 'ewallet',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF108EE9)
      },
      {
        'name': 'ShopeePay',
        'type': 'ewallet',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFFEE4D2D)
      },
      {
        'name': 'LinkAja',
        'type': 'ewallet',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFFDD2C2E)
      },
      {
        'name': 'Bibit',
        'type': 'investment',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF00A85A)
      },
      {
        'name': 'Cash',
        'type': 'cash',
        'icon': Icons.payments_rounded,
        'color': const Color(0xFF4CAF50)
      },
    ];

    Map<String, dynamic>? selectedPreset;

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
                    'Pilih Dompet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih bank/e-wallet favorit atau buat custom',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Dompet Populer',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  // Grid of brand presets
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
                      final isSelected = selectedPreset?['name'] == p['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPreset = p;
                            selectedType = p['type'] as String;
                            nameC.text = p['name'] as String;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    p['color'] as Color,
                                    (p['color'] as Color).withOpacity(0.75),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (p['color'] as Color).withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                p['icon'] as IconData,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p['name'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Atau Buat Custom',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                      _typeChip('investment', '📈 Investasi', selectedType,
                          (v) => setState(() => selectedType = v)),
                      _typeChip('other', '📦 Lainnya', selectedType,
                          (v) => setState(() => selectedType = v)),
                    ],
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
                        // Determine icon & color from preset or fallback
                        String iconEmoji = '💰';
                        String colorHex = '#0288D1';
                        if (selectedPreset != null) {
                          final brandColor = selectedPreset!['color'] as Color;
                          colorHex =
                              '#${brandColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                          // Map icon to emoji for storage
                          final iconData = selectedPreset!['icon'] as IconData;
                          iconEmoji = _iconToEmoji(iconData, selectedType);
                        } else {
                          // Auto-pick icon & color based on type
                          final fallback = WalletBrand.getFallbackIcon(
                              nameC.text, selectedType);
                          iconEmoji = _iconToEmoji(fallback, selectedType);
                          final brand =
                              WalletBrand.getBrand(nameC.text, selectedType);
                          colorHex =
                              '#${brand.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                        }

                        walletC.addWallet(
                          name: nameC.text.trim(),
                          type: selectedType,
                          icon: iconEmoji,
                          colorHex: colorHex,
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

  /// Convert IconData to emoji for storage
  static String _iconToEmoji(IconData icon, String type) {
    if (icon == Icons.account_balance_rounded) {
      switch (type) {
        case 'bank':
          return '🏦';
        default:
          return '🏦';
      }
    }
    if (icon == Icons.account_balance_wallet_rounded) return '📱';
    if (icon == Icons.payments_rounded) return '💵';
    if (icon == Icons.trending_up_rounded) return '📈';
    if (icon == Icons.wallet_rounded) return '💰';
    return '💰';
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
