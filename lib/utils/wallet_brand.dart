import 'package:flutter/material.dart';

/// Provides brand-specific icons, colors, styles, and logo URLs for known wallet/bank names.
class WalletBrand {
  final String icon;
  final Color color;
  final Color? backgroundColor;
  final String?
      logoAssetPath; // local asset path (e.g. 'assets/images/banks/bca_logo.png')
  final String?
      logoUrl; // remote URL for the real logo (loaded via CachedNetworkImage)

  const WalletBrand({
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.logoAssetPath,
    this.logoUrl,
  });

  /// Get brand info based on wallet name (case-insensitive matching)
  static WalletBrand getBrand(String name, String type) {
    final lower = name.toLowerCase();

    // ─── Indonesian Banks ───
    if (lower.contains('bca')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF003DA5),
        backgroundColor: Color(0xFFE8F0FE),
        logoAssetPath: 'assets/images/banks/bca_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Bank_Central_Asia.svg/2048px-Bank_Central_Asia.svg.png',
      );
    }
    if (lower.contains('mandiri')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF003D6B),
        backgroundColor: Color(0xFFE6EDF5),
        logoAssetPath: 'assets/images/banks/mandiri_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Bank_Mandiri_logo_2016.svg/2560px-Bank_Mandiri_logo_2016.svg.png',
      );
    }
    if (lower.contains('bni')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFFED1C24),
        backgroundColor: Color(0xFFFDE8E9),
        logoAssetPath: 'assets/images/banks/bni_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/id/thumb/5/55/BNI_logo.svg/1200px-BNI_logo.svg.png',
      );
    }
    if (lower.contains('bri')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF003DA5),
        backgroundColor: Color(0xFFE8F0FE),
        logoAssetPath: 'assets/images/banks/bri_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/BANK_BRI_logo.svg/1280px-BANK_BRI_logo.svg.png',
      );
    }
    if (lower.contains('bsi')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF1A6B3C),
        backgroundColor: Color(0xFFE8F5EE),
        logoAssetPath: 'assets/images/banks/bsi_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Bank_Syariah_Indonesia_logo.svg/1200px-Bank_Syariah_Indonesia_logo.svg.png',
      );
    }
    if (lower.contains('cimb')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF8B0000),
        backgroundColor: Color(0xFFFCE8E8),
        logoAssetPath: 'assets/images/banks/cimb_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/CIMB_Niaga_logo.svg/2560px-CIMB_Niaga_logo.svg.png',
      );
    }
    if (lower.contains('btn')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFFFF6600),
        backgroundColor: Color(0xFFFFF3E8),
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Bank_BTN_logo.svg/1200px-Bank_BTN_logo.svg.png',
      );
    }
    if (lower.contains('danamon')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF003DA5),
        backgroundColor: Color(0xFFE8F0FE),
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Danamon_logo.svg/2560px-Danamon_logo.svg.png',
      );
    }
    if (lower.contains('permata')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF6A1B9A),
        backgroundColor: Color(0xFFF3E8FD),
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/PermataBank_logo.svg/1200px-PermataBank_logo.svg.png',
      );
    }
    if (lower.contains('jago')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF00B894),
        backgroundColor: Color(0xFFE5F9F3),
        logoAssetPath: 'assets/images/banks/jago_logo.jpeg',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Bank_Jago_logo.svg/1200px-Bank_Jago_logo.svg.png',
      );
    }
    if (lower.contains('seabank') || lower.contains('sea bank')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFFF58220),
        backgroundColor: Color(0xFFFFF3E8),
        logoAssetPath: 'assets/images/banks/seabank_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/SeaBank_Indonesia_logo.svg/1200px-SeaBank_Indonesia_logo.svg.png',
      );
    }
    if (lower.contains('muamalat')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF006741),
        backgroundColor: Color(0xFFE5F5ED),
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Bank_Muamalat_logo.svg/1200px-Bank_Muamalat_logo.svg.png',
      );
    }
    if (lower.contains('mega')) {
      return const WalletBrand(
        icon: '🏦',
        color: Color(0xFF004EA2),
        backgroundColor: Color(0xFFE5EFFA),
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Bank_Mega_logo.svg/1200px-Bank_Mega_logo.svg.png',
      );
    }

    // ─── E-Wallets ───
    if (lower.contains('gopay') || lower.contains('go-pay')) {
      return const WalletBrand(
        icon: '📱',
        color: Color(0xFF00AED6),
        backgroundColor: Color(0xFFE5F7FB),
        logoAssetPath: 'assets/images/banks/gopay_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Gopay_logo.svg/1200px-Gopay_logo.svg.png',
      );
    }
    if (lower.contains('ovo')) {
      return const WalletBrand(
        icon: '📱',
        color: Color(0xFF4C3494),
        backgroundColor: Color(0xFFEDEAF5),
        logoAssetPath: 'assets/images/banks/ovo_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/ovo_logo.svg/1200px-ovo_logo.svg.png',
      );
    }
    if (lower.contains('dana')) {
      return const WalletBrand(
        icon: '📱',
        color: Color(0xFF108EE9),
        backgroundColor: Color(0xFFE4F3FC),
        logoAssetPath: 'assets/images/banks/dana_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Dana_logo.svg/1200px-Dana_logo.svg.png',
      );
    }
    if (lower.contains('shopeepay') || lower.contains('shopee')) {
      return const WalletBrand(
        icon: '📱',
        color: Color(0xFFEE4D2D),
        backgroundColor: Color(0xFFFDEAE5),
        logoAssetPath: 'assets/images/banks/shoppe_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Shopeepay_logo.svg/1200px-Shopeepay_logo.svg.png',
      );
    }
    if (lower.contains('linkaja') || lower.contains('link aja')) {
      return const WalletBrand(
        icon: '📱',
        color: Color(0xFFDD2C2E),
        backgroundColor: Color(0xFFFDE8E8),
        logoAssetPath: 'assets/images/banks/linkaja_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/LinkAja_logo.svg/1200px-LinkAja_logo.svg.png',
      );
    }
    if (lower.contains('isaku')) {
      return const WalletBrand(
        icon: '📱',
        color: Color(0xFF00A85A),
        backgroundColor: Color(0xFFE5F7ED),
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Isaku_logo.svg/1200px-Isaku_logo.svg.png',
      );
    }

    // ─── QRIS ───
    if (lower.contains('qris')) {
      return const WalletBrand(
        icon: '📱',
        color: Color(0xFF0066CC),
        backgroundColor: Color(0xFFE3F2FD),
        logoAssetPath: 'assets/images/banks/qris_logo.png',
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/QRIS_logo.svg/1200px-QRIS_logo.svg.png',
      );
    }

    // ─── Investment ───
    if (lower.contains('bibit')) {
      return const WalletBrand(
        icon: '📈',
        color: Color(0xFF00A85A),
        backgroundColor: Color(0xFFE5F7ED),
        logoAssetPath: 'assets/images/banks/bitbit_logo.png',
        logoUrl: 'https://bibit.id/img/logo-bibit-primary.svg',
      );
    }
    if (lower.contains('stockbit')) {
      return const WalletBrand(
        icon: '📈',
        color: Color(0xFF1A73E8),
        backgroundColor: Color(0xFFE8F0FE),
        logoUrl: 'https://assets.stockbit.com/logos/stockbit-primary-logo.png',
      );
    }
    if (lower.contains('tokopedia') || lower.contains('tokped')) {
      return const WalletBrand(
        icon: '🛒',
        color: Color(0xFF42B549),
        backgroundColor: Color(0xFFE8F7E9),
        logoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Tokopedia_logo.svg/1200px-Tokopedia_logo.svg.png',
      );
    }

    // ─── Default based on type ───
    switch (type) {
      case 'cash':
        return const WalletBrand(
          icon: '💵',
          color: Color(0xFF4CAF50),
          backgroundColor: Color(0xFFE8F5E9),
          logoAssetPath: 'assets/images/banks/cash_logo.jpeg',
        );
      case 'bank':
        return const WalletBrand(
          icon: '🏦',
          color: Color(0xFF1565C0),
          backgroundColor: Color(0xFFE3F2FD),
        );
      case 'ewallet':
        return const WalletBrand(
          icon: '📱',
          color: Color(0xFF00ACC1),
          backgroundColor: Color(0xFFE0F7FA),
        );
      case 'investment':
        return const WalletBrand(
          icon: '📈',
          color: Color(0xFF6A1B9A),
          backgroundColor: Color(0xFFF3E5F5),
        );
      default:
        return const WalletBrand(
          icon: '💰',
          color: Color(0xFF757575),
          backgroundColor: Color(0xFFF5F5F5),
        );
    }
  }

  /// Get a fallback icon widget when image assets are not available
  static IconData getFallbackIcon(String name, String type) {
    final lower = name.toLowerCase();

    // Banks
    if (lower.contains('bca') ||
        lower.contains('mandiri') ||
        lower.contains('bni') ||
        lower.contains('bri') ||
        lower.contains('bsi') ||
        lower.contains('cimb') ||
        lower.contains('btn') ||
        lower.contains('danamon') ||
        lower.contains('permata') ||
        lower.contains('jago') ||
        lower.contains('seabank') ||
        lower.contains('muamalat') ||
        lower.contains('mega')) {
      return Icons.account_balance_rounded;
    }

    // E-Wallets
    if (lower.contains('gopay') ||
        lower.contains('go-pay') ||
        lower.contains('ovo') ||
        lower.contains('dana') ||
        lower.contains('shopee') ||
        lower.contains('link') ||
        lower.contains('isaku')) {
      return Icons.account_balance_wallet_rounded;
    }

    // Investment
    if (lower.contains('bibit') ||
        lower.contains('stockbit') ||
        lower.contains('tokopedia')) {
      return Icons.trending_up_rounded;
    }

    // Default
    switch (type) {
      case 'cash':
        return Icons.payments_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      case 'ewallet':
        return Icons.account_balance_wallet_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      default:
        return Icons.wallet_rounded;
    }
  }
}
