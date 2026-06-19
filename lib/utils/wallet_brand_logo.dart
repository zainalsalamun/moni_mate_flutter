import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'wallet_brand.dart';

/// A reusable widget that displays a wallet/bank brand logo.
///
/// Priority:
/// 1. If the brand has a `logoUrl`, load the real logo from network.
/// 2. If the brand has a `logoAssetPath`, show the local asset image.
/// 3. Otherwise, fall back to the brand's colored gradient + first letter initial.
class WalletBrandLogo extends StatelessWidget {
  final String name;
  final String type;
  final double size;
  final double borderRadius;

  const WalletBrandLogo({
    super.key,
    required this.name,
    required this.type,
    this.size = 48,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final brand = WalletBrand.getBrand(name, type);
    final hasUrl = brand.logoUrl != null && brand.logoUrl!.isNotEmpty;
    final hasAsset =
        brand.logoAssetPath != null && brand.logoAssetPath!.isNotEmpty;
    final hasLogo = hasUrl || hasAsset;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: hasLogo ? Colors.white : null,
        gradient: hasLogo
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  brand.color,
                  brand.color.withOpacity(0.75),
                ],
              ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (hasLogo ? Colors.black : brand.color)
                .withOpacity(hasLogo ? 0.08 : 0.3),
            blurRadius: hasLogo ? 4 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: hasUrl
          ? _buildNetworkLogo(brand)
          : hasAsset
              ? _buildAssetLogo(brand)
              : _buildInitial(brand),
    );
  }

  Widget _buildInitial(WalletBrand brand) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildNetworkLogo(WalletBrand brand) {
    return Padding(
      padding: EdgeInsets.all(size * 0.08),
      child: FittedBox(
        fit: BoxFit.contain,
        child: CachedNetworkImage(
          imageUrl: brand.logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          placeholder: (context, url) => SizedBox(
            width: size * 0.35,
            height: size * 0.35,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: brand.color.withOpacity(0.5),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            if (brand.logoAssetPath != null &&
                brand.logoAssetPath!.isNotEmpty) {
              return _buildAssetLogo(brand);
            }
            return _buildInitial(brand);
          },
        ),
      ),
    );
  }

  Widget _buildAssetLogo(WalletBrand brand) {
    return Padding(
      padding: EdgeInsets.all(size * 0.08),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Image.asset(
          brand.logoAssetPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildInitial(brand),
        ),
      ),
    );
  }
}
