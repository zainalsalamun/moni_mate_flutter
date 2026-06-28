import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/quick_actions_controller.dart';

class QuickActionsEditSheet extends StatelessWidget {
  const QuickActionsEditSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuickActionsController>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Aksi Cepat',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Pilih maksimal 4 aksi cepat yang akan ditampilkan di halaman utama.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: controller.availableActions.length,
              itemBuilder: (context, index) {
                final action = controller.availableActions[index];
                final id = action['id'] as String;
                final label = (action['label'] as String).replaceAll('\n', ' ');
                
                return Obx(() {
                  final isSelected = controller.selectedActions.contains(id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      final success = controller.toggleAction(id);
                      if (!success && value == true) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Batas Maksimal'),
                            content: const Text('Anda hanya bisa memilih 4 aksi cepat.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Mengerti'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(action['icon_name']),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 20),
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
}
