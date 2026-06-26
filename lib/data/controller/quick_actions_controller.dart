import 'package:get/get.dart';
import 'package:monimate/data/services/hive_service.dart';

class QuickActionsController extends GetxController {
  final RxList<String> selectedActions = <String>[].obs;

  static const String _storageKey = 'quick_actions_list';
  
  // Semua aksi yang tersedia
  final List<Map<String, dynamic>> availableActions = [
    {
      'id': 'add_transaction',
      'label': 'Tambah\nTransaksi',
      'icon_name': 'add_circle_outline_rounded',
      'color_name': 'blue',
    },
    {
      'id': 'scan_receipt',
      'label': 'Scan Struk',
      'icon_name': 'document_scanner_rounded',
      'color_name': 'purple',
    },
    {
      'id': 'goal',
      'label': 'Goal',
      'icon_name': 'track_changes_rounded',
      'color_name': 'teal',
    },
    {
      'id': 'wallet',
      'label': 'Wallet',
      'icon_name': 'account_balance_wallet_rounded',
      'color_name': 'orange',
    },
    {
      'id': 'inbox',
      'label': 'Pesan',
      'icon_name': 'mail_outline_rounded',
      'color_name': 'red',
    },
    {
      'id': 'daily_brief',
      'label': 'Brief\nHarian',
      'icon_name': 'wb_sunny_outlined',
      'color_name': 'amber',
    },
    {
      'id': 'budget',
      'label': 'Budget',
      'icon_name': 'pie_chart_outline_rounded',
      'color_name': 'indigo',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadActions();
  }

  void _loadActions() {
    final box = HiveService.settingsBox;
    final List<dynamic>? stored = box.get(_storageKey);
    
    if (stored != null && stored.isNotEmpty) {
      selectedActions.assignAll(stored.cast<String>());
    } else {
      // Default actions
      selectedActions.assignAll(['add_transaction', 'scan_receipt', 'goal', 'wallet']);
      _saveActions();
    }
  }

  void _saveActions() {
    HiveService.settingsBox.put(_storageKey, selectedActions.toList());
  }

  bool toggleAction(String id) {
    if (selectedActions.contains(id)) {
      selectedActions.remove(id);
      _saveActions();
      return true;
    } else {
      if (selectedActions.length >= 4) {
        return false; // Maksimal 4
      }
      selectedActions.add(id);
      _saveActions();
      return true;
    }
  }
}
