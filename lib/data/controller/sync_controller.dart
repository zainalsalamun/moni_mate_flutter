import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/sync_service.dart';

/// SyncController — GetX reactive controller for sync state management.
/// Manages sync status, auto-sync toggle, connectivity monitoring, and
/// lifecycle-aware sync triggers.
class SyncController extends GetxController with WidgetsBindingObserver {
  // ─── Reactive State ────────────────────────────
  final RxBool isOnline = false.obs;
  final RxBool isSyncing = false.obs;
  final RxBool isSignedIn = false.obs;
  final RxBool autoSyncEnabled = false.obs;
  final Rx<DateTime?> lastSyncTime = Rx<DateTime?>(null);
  final RxString syncStatusMessage = 'Belum pernah sync'.obs;
  final RxInt unsyncedCount = 0.obs;
  final RxString userEmail = ''.obs;
  final RxString userName = ''.obs;

  // ─── Internal ──────────────────────────────────
  final _storage = GetStorage();
  StreamSubscription? _connectivitySub;
  Timer? _autoSyncTimer;

  static const String _lastSyncKey = 'last_sync_time';
  static const String _autoSyncKey = 'auto_sync_enabled';

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadPersistedState();
    _startConnectivityMonitoring();
    _initAuth();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    _autoSyncTimer?.cancel();
    super.onClose();
  }

  // ─── App Lifecycle ─────────────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectivity();
      if (autoSyncEnabled.value && isSignedIn.value) {
        syncNow();
      }
    }
  }

  // ─── Initialization ────────────────────────────
  void _loadPersistedState() {
    // Load last sync time
    final lastSyncStr = _storage.read<String>(_lastSyncKey);
    if (lastSyncStr != null) {
      lastSyncTime.value = DateTime.tryParse(lastSyncStr);
      _updateStatusMessage();
    }

    // Load auto-sync preference
    autoSyncEnabled.value = _storage.read<bool>(_autoSyncKey) ?? false;
  }

  Future<void> _initAuth() async {
    final success = await SyncService.trySilentSignIn();
    isSignedIn.value = success;
    if (success) {
      userEmail.value = SyncService.userEmail ?? '';
      userName.value = SyncService.userName ?? '';
      _refreshUnsyncedCount();
    }
  }

  // ─── Connectivity Monitoring ───────────────────
  void _startConnectivityMonitoring() {
    _checkConnectivity();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      isOnline.value = !results.contains(ConnectivityResult.none);
      _updateStatusMessage();

      // Auto-sync when coming online
      if (isOnline.value && autoSyncEnabled.value && isSignedIn.value) {
        syncNow();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    isOnline.value = await SyncService.isOnline();
    _updateStatusMessage();
  }

  // ─── Sign In / Out ─────────────────────────────
  Future<bool> signIn() async {
    try {
      final success = await SyncService.signIn();
      isSignedIn.value = success;
      if (success) {
        userEmail.value = SyncService.userEmail ?? '';
        userName.value = SyncService.userName ?? '';
        _refreshUnsyncedCount();
      }
      return success;
    } catch (e) {
      debugPrint('SyncController signIn error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await SyncService.signOut();
    isSignedIn.value = false;
    userEmail.value = '';
    userName.value = '';
    syncStatusMessage.value = 'Belum terhubung';
  }

  // ─── Sync Actions ──────────────────────────────
  Future<bool> syncNow() async {
    if (isSyncing.value) return false;
    if (!isSignedIn.value) return false;

    isSyncing.value = true;
    syncStatusMessage.value = 'Menyinkronkan...';

    try {
      final success = await SyncService.syncData();

      if (success) {
        lastSyncTime.value = DateTime.now();
        _storage.write(_lastSyncKey, lastSyncTime.value!.toIso8601String());
        _refreshUnsyncedCount();
        _updateStatusMessage();
        return true;
      } else {
        syncStatusMessage.value = isOnline.value
            ? 'Sync gagal, coba lagi nanti'
            : 'Offline — sync tertunda';
        return false;
      }
    } catch (e) {
      debugPrint('SyncController syncNow error: $e');
      syncStatusMessage.value = 'Sync gagal: ${e.toString().substring(0, 50)}';
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  // ─── Auto Sync Toggle ─────────────────────────
  void toggleAutoSync(bool value) {
    autoSyncEnabled.value = value;
    _storage.write(_autoSyncKey, value);

    if (value) {
      _startAutoSyncTimer();
    } else {
      _autoSyncTimer?.cancel();
      _autoSyncTimer = null;
    }
  }

  void _startAutoSyncTimer() {
    _autoSyncTimer?.cancel();
    // Sync every 15 minutes when auto-sync is enabled
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      if (isOnline.value && isSignedIn.value && !isSyncing.value) {
        syncNow();
      }
    });
  }

  // ─── Helpers ───────────────────────────────────
  void _refreshUnsyncedCount() {
    unsyncedCount.value = SyncService.getUnsyncedCount();
  }

  void _updateStatusMessage() {
    if (!isSignedIn.value) {
      syncStatusMessage.value = 'Belum terhubung ke Google';
      return;
    }

    if (isSyncing.value) {
      syncStatusMessage.value = 'Menyinkronkan...';
      return;
    }

    if (!isOnline.value) {
      syncStatusMessage.value = 'Offline — data tersimpan lokal';
      return;
    }

    if (lastSyncTime.value != null) {
      final diff = DateTime.now().difference(lastSyncTime.value!);
      if (diff.inMinutes < 1) {
        syncStatusMessage.value = 'Disinkronkan baru saja';
      } else if (diff.inMinutes < 60) {
        syncStatusMessage.value =
            'Disinkronkan ${diff.inMinutes} menit lalu';
      } else if (diff.inHours < 24) {
        syncStatusMessage.value =
            'Disinkronkan ${diff.inHours} jam lalu';
      } else {
        syncStatusMessage.value =
            'Disinkronkan ${diff.inDays} hari lalu';
      }
    } else {
      syncStatusMessage.value = 'Belum pernah sync';
    }
  }

  /// Call this whenever local data changes to update the badge count.
  void notifyDataChanged() {
    _refreshUnsyncedCount();
  }
}
