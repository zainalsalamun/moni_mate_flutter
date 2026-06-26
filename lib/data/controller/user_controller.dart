import 'package:get/get.dart';
import 'package:monimate/data/services/hive_service.dart';

class UserController extends GetxController {
  final RxString userName = 'Bang Jay'.obs;

  static const String _storageKey = 'user_name';

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
  }

  void _loadUserName() {
    final box = HiveService.settingsBox;
    final String? storedName = box.get(_storageKey);
    
    if (storedName != null && storedName.isNotEmpty) {
      userName.value = storedName;
    }
  }

  void updateUserName(String newName) {
    if (newName.trim().isEmpty) return;
    
    userName.value = newName.trim();
    HiveService.settingsBox.put(_storageKey, userName.value);
  }
}
