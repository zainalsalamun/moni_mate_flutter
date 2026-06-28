import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../shell.dart';
import '../../features/financial_goals/views/financial_goals_page.dart';
import '../../features/wallet/views/wallet_manage_page.dart';
import '../../features/financial_inbox/pages/financial_inbox_page.dart';
import '../../features/daily_brief/views/financial_brief_page.dart';
import '../../data/services/receipt_scanner_service.dart';
import '../../data/controller/quick_actions_controller.dart';
import 'quick_actions_edit_sheet.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aksi Cepat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    const QuickActionsEditSheet(),
                    isScrollControlled: true,
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final controller = Get.find<QuickActionsController>();
            final actions = controller.selectedActions
                .map((id) => controller.availableActions.firstWhere((a) => a['id'] == id))
                .toList();

            return Row(
              children: actions.map((action) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: action == actions.last ? 0 : 12),
                    child: _buildActionItem(
                      context,
                      icon: _getIconData(action['icon_name']),
                      label: action['label'],
                      color: _getColor(action['color_name']),
                      onTap: () => _handleActionTap(action['id']),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'add_circle_outline_rounded': return Icons.add_circle_outline_rounded;
      case 'document_scanner_rounded': return Icons.document_scanner_rounded;
      case 'track_changes_rounded': return Icons.track_changes_rounded;
      case 'account_balance_wallet_rounded': return Icons.account_balance_wallet_rounded;
      case 'mail_outline_rounded': return Icons.mail_outline_rounded;
      case 'wb_sunny_outlined': return Icons.wb_sunny_outlined;
      case 'pie_chart_outline_rounded': return Icons.pie_chart_outline_rounded;
      default: return Icons.star_border;
    }
  }

  Color _getColor(String name) {
    switch (name) {
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      case 'teal': return Colors.teal;
      case 'orange': return Colors.orange;
      case 'red': return Colors.red;
      case 'amber': return Colors.amber;
      case 'indigo': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  void _handleActionTap(String id) async {
    switch (id) {
      case 'add_transaction':
        Get.find<ShellController>().changeTab(2);
        break;
      case 'scan_receipt':
        final result = await ReceiptScannerService.scanReceipt();
        if (result != null) {
          final shell = Get.find<ShellController>();
          shell.pendingScanResult.value = result;
          shell.changeTab(2);
        }
        break;
      case 'goal':
        Get.to(() => const FinancialGoalsPage());
        break;
      case 'wallet':
        Get.to(() => const WalletManagePage());
        break;
      case 'inbox':
        Get.to(() => const FinancialInboxPage());
        break;
      case 'daily_brief':
        Get.to(() => const FinancialBriefPage());
        break;
      case 'budget':
        Get.snackbar('Segera Hadir', 'Fitur Budget sedang dalam pengembangan.');
        break;
    }
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
