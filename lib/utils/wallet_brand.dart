import 'package:flutter/material.dart';

/// Provides brand-specific icons, colors, and styles for known wallet/bank names.
class WalletBrand {
  final String icon;
  final Color color;
  final Color? backgroundColor;

  const WalletBrand({
    required this.icon,
    required this.color,
    this.backgroundColor,
  });

  /// Get brand info based on wallet name (case-insensitive matching)
  static WalletBrand getBrand(String name, String type) {
    final lower = name.toLowerCase();

    // Indonesian Banks
    if (lower.contains('bca')) {
      return WalletBrand(
        icon: 'assets/images/wallet/bca.png',
        color: const Color(0xFF003DA5),
        backgroundColor: const Color(0xFFE8F0FE),
      );
    }
    if (lower.contains('mandiri')) {
      return WalletBrand(
        icon: 'assets/images/wallet/mandiri.png',
        color: const Color(0xFF003D6B),
        backgroundColor: const Color(0xFFE6EDF5),
      );
    }
    if (lower.contains('bni')) {
      return WalletBrand(
        icon: 'assets/images/wallet/bni.png',
        color: const Color(0xFFED1C24),
        backgroundColor: const Color(0xFFFDE8E9),
      );
    }
    if (lower.contains('bri')) {
      return WalletBrand(
        icon: 'assets/images/wallet/bri.png',
        color: const Color(0xFF003DA5),
        backgroundColor: const Color(0xFFE8F0FE),
      );
    }
    if (lower.contains('bsi')) {
      return WalletBrand(
        icon: 'assets/images/wallet/bsi.png',
        color: const Color(0xFF1A6B3C),
        backgroundColor: const Color(0xFFE8F5EE),
      );
    }
    if (lower.contains('cimb')) {
      return WalletBrand(
        icon: 'assets/images/wallet/cimb.png',
        color: const Color(0xFF8B0000),
        backgroundColor: const Color(0xFFFCE8E8),
      );
    }
    if (lower.contains('btn')) {
      return WalletBrand(
        icon: 'assets/images/wallet/btn.png',
        color: const Color(0xFFFF6600),
        backgroundColor: const Color(0xFFFFF3E8),
      );
    }
    if (lower.contains('danamon')) {
      return WalletBrand(
        icon: 'assets/images/wallet/danamon.png',
        color: const Color(0xFF003DA5),
        backgroundColor: const Color(0xFFE8F0FE),
      );
    }
    if (lower.contains('permata')) {
      return WalletBrand(
        icon: 'assets/images/wallet/permata.png',
        color: const Color(0xFF6A1B9A),
        backgroundColor: const Color(0xFFF3E8FD),
      );
    }

    // E-Wallets
    if (lower.contains('gopay') || lower.contains('go-pay')) {
      return WalletBrand(
        icon: 'assets/images/wallet/gopay.png',
        color: const Color(0xFF00AED6),
        backgroundColor: const Color(0xFFE5F7FB),
      );
    }
    if (lower.contains('ovo')) {
      return WalletBrand(
        icon: 'assets/images/wallet/ovo.png',
        color: const Color(0xFF4C3494),
        backgroundColor: const Color(0xFFEDEAF5),
      );
    }
    if (lower.contains('dana')) {
      return WalletBrand(
        icon: 'assets/images/wallet/dana.png',
        color: const Color(0xFF108EE9),
        backgroundColor: const Color(0xFFE4F3FC),
      );
    }
    if (lower.contains('shopeepay') || lower.contains('shopee')) {
      return WalletBrand(
        icon: 'assets/images/wallet/shopeepay.png',
        color: const Color(0xFFEE4D2D),
        backgroundColor: const Color(0xFFFDEAE5),
      );
    }
    if (lower.contains('linkaja') || lower.contains('link aja')) {
      return WalletBrand(
        icon: 'assets/images/wallet/linkaja.png',
        color: const Color(0xFFDD2C2E),
        backgroundColor: const Color(0xFFFDE8E8),
      );
    }
    if (lower.contains('isaku')) {
      return WalletBrand(
        icon: 'assets/images/wallet/isaku.png',
        color: const Color(0xFF00A85A),
        backgroundColor: const Color(0xFFE5F7ED),
      );
    }

    // Investment
    if (lower.contains('bibit')) {
      return WalletBrand(
        icon: 'assets/images/wallet/bibit.png',
        color: const Color(0xFF00A85A),
        backgroundColor: const Color(0xFFE5F7ED),
      );
    }
    if (lower.contains('stockbit')) {
      return WalletBrand(
        icon: 'assets/images/wallet/stockbit.png',
        color: const Color(0xFF1A73E8),
        backgroundColor: const Color(0xFFE8F0FE),
      );
    }
    if (lower.contains('tokopedia') || lower.contains('tokped')) {
      return WalletBrand(
        icon: 'assets/images/wallet/tokopedia.png',
        color: const Color(0xFF42B549),
        backgroundColor: const Color(0xFFE8F7E9),
      );
    }

    // Default based on type
    switch (type) {
      case 'cash':
        return WalletBrand(
          icon: '',
          color: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFFE8F5E9),
        );
      case 'bank':
        return WalletBrand(
          icon: '',
          color: const Color(0xFF1565C0),
          backgroundColor: const Color(0xFFE3F2FD),
        );
      case 'ewallet':
        return WalletBrand(
          icon: '',
          color: const Color(0xFF00ACC1),
          backgroundColor: const Color(0xFFE0F7FA),
        );
      case 'investment':
        return WalletBrand(
          icon: '',
          color: const Color(0xFF6A1B9A),
          backgroundColor: const Color(0xFFF3E5F5),
        );
      default:
        return WalletBrand(
          icon: '',
          color: const Color(0xFF757575),
          backgroundColor: const Color(0xFFF5F5F5),
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
        lower.contains('permata')) {
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
