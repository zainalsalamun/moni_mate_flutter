import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/format_currency.dart';
import '../controllers/net_worth_controller.dart';
import 'net_worth_page.dart';

class NetWorthCard extends StatelessWidget {
  const NetWorthCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NetWorthController>()) {
      Get.put(NetWorthController());
    }
    final nwc = Get.find<NetWorthController>();

    return Obx(() {
      final isPositive = nwc.monthlyGrowth.value >= 0;
      final growthText = '${isPositive ? '+' : ''}${nwc.monthlyGrowth.value.toStringAsFixed(1)}%';
      final growthColor = isPositive ? Colors.green : Colors.redAccent;
      final growthIcon = isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: GestureDetector(
          onTap: () => Get.to(() => const NetWorthPage()),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2D3748)
                    : const Color(0xFFEDF2F7),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.diamond_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Worth',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyFormat.format(nwc.netWorth.value),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: growthColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(growthIcon, color: growthColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            growthText,
                            style: TextStyle(
                              color: growthColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'vs bulan lalu',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
