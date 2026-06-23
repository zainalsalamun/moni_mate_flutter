import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/goal_model.dart';
import '../models/contribution_model.dart';
import '../../features/budget/model/budget_model.dart';
import '../../features/emergency_fund/controllers/emergency_fund_controller.dart';
import '../../features/emergency_fund/models/emergency_fund_profile.dart';
import '../../features/net_worth/models/net_worth_snapshot_model.dart';
import 'hive_service.dart';
import 'package:get/get.dart';

/// SyncService handles bidirectional sync between local Hive storage and Google Drive.
/// Uses incremental sync (only unsynced data) + Last-Write-Wins conflict resolution.
class SyncService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  static GoogleSignInAccount? _currentUser;
  static drive.DriveApi? _driveApi;

  // Google Drive folder and file names
  static const String _folderName = 'MoniMate';
  static const String _fileName = 'backup_latest.json';

  // ─────────────────────────────────────────────
  // Authentication
  // ─────────────────────────────────────────────

  /// Sign in to Google and initialize the Drive API client.
  static Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser == null) return false;

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return false;

      _driveApi = drive.DriveApi(httpClient);
      return true;
    } catch (e) {
      debugPrint('SyncService signIn error: $e');
      return false;
    }
  }

  /// Sign out and clear cached references.
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  /// Check if user is currently signed in.
  static bool get isSignedIn => _currentUser != null;

  /// Get the current signed-in user's display name.
  static String? get userName => _currentUser?.displayName;

  /// Get the current signed-in user's email.
  static String? get userEmail => _currentUser?.email;

  /// Try to silently sign in (restore session).
  static Future<bool> trySilentSignIn() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser == null) return false;

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return false;

      _driveApi = drive.DriveApi(httpClient);
      return true;
    } catch (e) {
      debugPrint('SyncService silent sign-in failed: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Connectivity Check
  // ─────────────────────────────────────────────

  /// Check if the device currently has internet connectivity.
  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  // ─────────────────────────────────────────────
  // Main Sync Logic
  // ─────────────────────────────────────────────

  /// Main entry point — runs full bidirectional sync.
  /// Returns true on success, false on failure/offline.
  static Future<bool> syncData() async {
    if (!isSignedIn) {
      debugPrint('SyncService: Not signed in, skipping sync');
      return false;
    }

    if (!await isOnline()) {
      debugPrint('SyncService: Offline, skipping sync');
      return false;
    }

    try {
      // Step 1: Download remote data and merge (conflict resolution)
      await downloadRemoteData();

      // Step 2: Upload local changes to cloud
      await uploadLocalChanges();

      debugPrint('SyncService: Sync completed successfully');
      return true;
    } catch (e) {
      debugPrint('SyncService syncData error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Upload (Local → Cloud)
  // ─────────────────────────────────────────────

  /// Serialize ALL local data to JSON and upload to Google Drive.
  /// After successful upload, marks all items as isSynced = true.
  static Future<void> uploadLocalChanges() async {
    final jsonData = _serializeAllData();
    final jsonString = jsonEncode(jsonData);

    // Upload to Google Drive
    final folderId = await _getOrCreateFolder();
    await _uploadFile(folderId, _fileName, jsonString);

    // Mark all items as synced
    await _markAllSynced();

    debugPrint('SyncService: Upload completed (${jsonString.length} bytes)');
  }

  // ─────────────────────────────────────────────
  // Download (Cloud → Local)
  // ─────────────────────────────────────────────

  /// Download remote data from Google Drive and merge with local data.
  /// Uses Last-Write-Wins strategy based on updatedAt timestamp.
  static Future<void> downloadRemoteData() async {
    final folderId = await _getOrCreateFolder();
    final remoteJson = await _downloadFile(folderId, _fileName);

    if (remoteJson == null) {
      debugPrint('SyncService: No remote backup found, skipping download');
      return;
    }

    try {
      final Map<String, dynamic> remoteData = jsonDecode(remoteJson);
      await _mergeRemoteData(remoteData);
      debugPrint('SyncService: Download & merge completed');
    } catch (e) {
      debugPrint('SyncService: Failed to parse remote data: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Data Serialization
  // ─────────────────────────────────────────────

  /// Serialize all Hive boxes to a single JSON map.
  static Map<String, dynamic> _serializeAllData() {
    return {
      'version': 1,
      'syncedAt': DateTime.now().toIso8601String(),
      'transactions': HiveService.box.values
          .map((t) => {
                'id': t.id,
                'type': t.type,
                'category': t.category,
                'amount': t.amount,
                'description': t.description,
                'date': t.date.toIso8601String(),
                'updatedAt': (t.updatedAt ?? DateTime.now()).toIso8601String(),
              })
          .toList(),
      'categories': HiveService.categoryBox.values
          .map((c) => {
                'id': c.id,
                'type': c.type,
                'name': c.name,
                'emoji': c.emoji,
                'isCustom': c.isCustom,
                'updatedAt': (c.updatedAt ?? DateTime.now()).toIso8601String(),
              })
          .toList(),
      'recurringTransactions': HiveService.recurringBox.values
          .map((r) => {
                'id': r.id,
                'title': r.title,
                'amount': r.amount,
                'category': r.category,
                'type': r.type,
                'repeatType': r.repeatType,
                'startDate': r.startDate.toIso8601String(),
                'endDate': r.endDate?.toIso8601String(),
                'interval': r.interval,
                'nextExecutionDate': r.nextExecutionDate.toIso8601String(),
                'isActive': r.isActive,
                'updatedAt': (r.updatedAt ?? DateTime.now()).toIso8601String(),
              })
          .toList(),
      'budgets': HiveService.budgetBox.values
          .map((b) => {
                'id': b.id,
                'categoryId': b.categoryId,
                'monthlyLimit': b.monthlyLimit,
                'startMonth': b.startMonth.toIso8601String(),
                'isActive': b.isActive,
                'period': b.period.index,
                'updatedAt': (b.updatedAt ?? DateTime.now()).toIso8601String(),
              })
          .toList(),
      'goals': HiveService.goalBox.values
          .map((g) => {
                'id': g.id,
                'title': g.title,
                'targetAmount': g.targetAmount,
                'currentAmount': g.currentAmount,
                'targetDate': g.targetDate.toIso8601String(),
                'status': g.status,
                'iconPath': g.iconPath,
                'colorHex': g.colorHex,
                'createdAt': g.createdAt.toIso8601String(),
                'updatedAt': (g.updatedAt ?? DateTime.now()).toIso8601String(),
              })
          .toList(),
      'contributions': HiveService.contributionBox.values
          .map((c) => {
                'id': c.id,
                'goalId': c.goalId,
                'amount': c.amount,
                'date': c.date.toIso8601String(),
                'note': c.note,
                'updatedAt': (c.updatedAt ?? DateTime.now()).toIso8601String(),
              })
          .toList(),
      'emergencyFundProfile': {
        'type': HiveService.getEmergencyFundProfile().type,
        'customMultiplier': HiveService.getEmergencyFundProfile().customMultiplier,
        'updatedAt': HiveService.getEmergencyFundProfile().updatedAt.toIso8601String(),
      },
      'netWorthSnapshots': HiveService.netWorthSnapshotBox.values
          .map((s) => {
                'id': s.id,
                'year': s.year,
                'month': s.month,
                'snapshotDate': s.snapshotDate.toIso8601String(),
                'totalAssets': s.totalAssets,
                'totalLiabilities': s.totalLiabilities,
                'netWorth': s.netWorth,
                'growthPercentMoM': s.growthPercentMoM,
                'growthPercentYoY': s.growthPercentYoY,
                'createdAt': s.createdAt.toIso8601String(),
                'updatedAt': s.createdAt.toIso8601String(),
              })
          .toList(),
    };
  }

  // ─────────────────────────────────────────────
  // Data Merge (Conflict Resolution)
  // ─────────────────────────────────────────────

  /// Merge remote data into local Hive storage using Last-Write-Wins.
  static Future<void> _mergeRemoteData(Map<String, dynamic> remoteData) async {
    // Merge transactions
    final remoteTxList = remoteData['transactions'] as List? ?? [];
    for (final rtx in remoteTxList) {
      final localTx = HiveService.box.get(rtx['id']);
      final remoteUpdatedAt = DateTime.parse(rtx['updatedAt']);

      if (localTx == null) {
        // New item from remote → insert
        await HiveService.box.put(
          rtx['id'],
          TransactionModel(
            id: rtx['id'],
            type: rtx['type'],
            category: rtx['category'],
            amount: (rtx['amount'] as num).toDouble(),
            description: rtx['description'] ?? '',
            date: DateTime.parse(rtx['date']),
            updatedAt: remoteUpdatedAt,
            isSynced: true,
          ),
        );
      } else if (remoteUpdatedAt.isAfter(localTx.updatedAt ?? DateTime(2000))) {
        // Remote is newer → replace local
        localTx.type = rtx['type'];
        localTx.category = rtx['category'];
        localTx.amount = (rtx['amount'] as num).toDouble();
        localTx.description = rtx['description'] ?? '';
        localTx.date = DateTime.parse(rtx['date']);
        localTx.updatedAt = remoteUpdatedAt;
        localTx.isSynced = true;
        await localTx.save();
      }
      // else: local is newer → keep local (will be uploaded)
    }

    // Merge categories
    final remoteCatList = remoteData['categories'] as List? ?? [];
    for (final rc in remoteCatList) {
      final localCat = HiveService.categoryBox.get(rc['id']);
      final remoteUpdatedAt = DateTime.parse(rc['updatedAt']);

      if (localCat == null) {
        await HiveService.categoryBox.put(
          rc['id'],
          CategoryModel(
            id: rc['id'],
            type: rc['type'],
            name: rc['name'],
            emoji: rc['emoji'],
            isCustom: rc['isCustom'] ?? false,
            updatedAt: remoteUpdatedAt,
            isSynced: true,
          ),
        );
      } else if (remoteUpdatedAt
          .isAfter(localCat.updatedAt ?? DateTime(2000))) {
        localCat.type = rc['type'];
        localCat.name = rc['name'];
        localCat.emoji = rc['emoji'];
        localCat.isCustom = rc['isCustom'] ?? false;
        localCat.updatedAt = remoteUpdatedAt;
        localCat.isSynced = true;
        await localCat.save();
      }
    }

    // Merge recurring transactions
    final remoteRecList = remoteData['recurringTransactions'] as List? ?? [];
    for (final rr in remoteRecList) {
      final localRec = HiveService.recurringBox.get(rr['id']);
      final remoteUpdatedAt = DateTime.parse(rr['updatedAt']);

      if (localRec == null) {
        await HiveService.recurringBox.put(
          rr['id'],
          RecurringTransactionModel(
            id: rr['id'],
            title: rr['title'],
            amount: (rr['amount'] as num).toDouble(),
            category: rr['category'],
            type: rr['type'],
            repeatType: rr['repeatType'],
            startDate: DateTime.parse(rr['startDate']),
            endDate:
                rr['endDate'] != null ? DateTime.parse(rr['endDate']) : null,
            interval: rr['interval'],
            nextExecutionDate: DateTime.parse(rr['nextExecutionDate']),
            isActive: rr['isActive'] ?? true,
            updatedAt: remoteUpdatedAt,
            isSynced: true,
          ),
        );
      } else if (remoteUpdatedAt
          .isAfter(localRec.updatedAt ?? DateTime(2000))) {
        localRec.title = rr['title'];
        localRec.amount = (rr['amount'] as num).toDouble();
        localRec.category = rr['category'];
        localRec.type = rr['type'];
        localRec.repeatType = rr['repeatType'];
        localRec.startDate = DateTime.parse(rr['startDate']);
        localRec.endDate =
            rr['endDate'] != null ? DateTime.parse(rr['endDate']) : null;
        localRec.interval = rr['interval'];
        localRec.nextExecutionDate = DateTime.parse(rr['nextExecutionDate']);
        localRec.isActive = rr['isActive'] ?? true;
        localRec.updatedAt = remoteUpdatedAt;
        localRec.isSynced = true;
        await localRec.save();
      }
    }

    // Merge budgets
    final remoteBudgetList = remoteData['budgets'] as List? ?? [];
    for (final rb in remoteBudgetList) {
      final localBudget = HiveService.budgetBox.get(rb['id']);
      final remoteUpdatedAt = DateTime.parse(rb['updatedAt']);

      if (localBudget == null) {
        await HiveService.budgetBox.put(
          rb['id'],
          BudgetModel(
            id: rb['id'],
            categoryId: rb['categoryId'],
            monthlyLimit: (rb['monthlyLimit'] as num).toDouble(),
            startMonth: DateTime.parse(rb['startMonth']),
            isActive: rb['isActive'] ?? true,
            period: BudgetPeriod.values[rb['period'] ?? 1],
            updatedAt: remoteUpdatedAt,
            isSynced: true,
          ),
        );
      } else if (remoteUpdatedAt
          .isAfter(localBudget.updatedAt ?? DateTime(2000))) {
        localBudget.categoryId = rb['categoryId'];
        localBudget.monthlyLimit = (rb['monthlyLimit'] as num).toDouble();
        localBudget.startMonth = DateTime.parse(rb['startMonth']);
        localBudget.isActive = rb['isActive'] ?? true;
        localBudget.period = BudgetPeriod.values[rb['period'] ?? 1];
        localBudget.updatedAt = remoteUpdatedAt;
        localBudget.isSynced = true;
        await localBudget.save();
      }
    }

    // Merge goals
    final remoteGoalList = remoteData['goals'] as List? ?? [];
    for (final rg in remoteGoalList) {
      final localGoal = HiveService.goalBox.get(rg['id']);
      final remoteUpdatedAt = DateTime.parse(rg['updatedAt']);

      if (localGoal == null) {
        await HiveService.goalBox.put(
          rg['id'],
          GoalModel(
            id: rg['id'],
            title: rg['title'],
            targetAmount: (rg['targetAmount'] as num).toDouble(),
            currentAmount: (rg['currentAmount'] as num).toDouble(),
            targetDate: DateTime.parse(rg['targetDate']),
            status: rg['status'] ?? 'active',
            iconPath: rg['iconPath'] ?? '',
            colorHex: rg['colorHex'] ?? '#E1F5FE',
            createdAt: DateTime.parse(rg['createdAt']),
            updatedAt: remoteUpdatedAt,
            isSynced: true,
          ),
        );
      } else if (remoteUpdatedAt
          .isAfter(localGoal.updatedAt ?? DateTime(2000))) {
        localGoal.title = rg['title'];
        localGoal.targetAmount = (rg['targetAmount'] as num).toDouble();
        localGoal.currentAmount = (rg['currentAmount'] as num).toDouble();
        localGoal.targetDate = DateTime.parse(rg['targetDate']);
        localGoal.status = rg['status'] ?? 'active';
        localGoal.iconPath = rg['iconPath'] ?? '';
        localGoal.colorHex = rg['colorHex'] ?? '#E1F5FE';
        localGoal.updatedAt = remoteUpdatedAt;
        localGoal.isSynced = true;
        await localGoal.save();
      }
    }

    // Merge contributions
    final remoteContribList = remoteData['contributions'] as List? ?? [];
    for (final rcb in remoteContribList) {
      final localContrib = HiveService.contributionBox.get(rcb['id']);
      final remoteUpdatedAt = DateTime.parse(rcb['updatedAt']);

      if (localContrib == null) {
        await HiveService.contributionBox.put(
          rcb['id'],
          ContributionModel(
            id: rcb['id'],
            goalId: rcb['goalId'],
            amount: (rcb['amount'] as num).toDouble(),
            date: DateTime.parse(rcb['date']),
            note: rcb['note'] ?? '',
            updatedAt: remoteUpdatedAt,
            isSynced: true,
          ),
        );
      } else if (remoteUpdatedAt
          .isAfter(localContrib.updatedAt ?? DateTime(2000))) {
        // ContributionModel fields are final, so we replace
        await HiveService.contributionBox.put(
          rcb['id'],
          ContributionModel(
            id: rcb['id'],
            goalId: rcb['goalId'],
            amount: (rcb['amount'] as num).toDouble(),
            date: DateTime.parse(rcb['date']),
            note: rcb['note'] ?? '',
            updatedAt: remoteUpdatedAt,
            isSynced: true,
          ),
        );
      }
    }

    // Merge Emergency Fund Profile
    final remoteEmergencyFund = remoteData['emergencyFundProfile'] as Map<String, dynamic>?;
    if (remoteEmergencyFund != null) {
      final localProfile = HiveService.getEmergencyFundProfile();
      final remoteUpdatedAt = DateTime.parse(remoteEmergencyFund['updatedAt']);
      
      if (remoteUpdatedAt.isAfter(localProfile.updatedAt)) {
        final newProfile = EmergencyFundProfile(
          id: localProfile.id, // keep local ID to overwrite
          type: remoteEmergencyFund['type'],
          customMultiplier: remoteEmergencyFund['customMultiplier'] ?? 3,
          updatedAt: remoteUpdatedAt,
          isSynced: true,
        );
        await HiveService.updateEmergencyFundProfile(newProfile);

        // Trigger recalculation if controller is active
        if (Get.isRegistered<EmergencyFundController>()) {
          Get.find<EmergencyFundController>().profile.value = newProfile;
          Get.find<EmergencyFundController>().calculateMetrics();
        }
      }
    }

    // Merge NetWorthSnapshots
    final remoteNwList = remoteData['netWorthSnapshots'] as List? ?? [];
    for (final rnw in remoteNwList) {
      final localNw = HiveService.netWorthSnapshotBox.get(rnw['id']);
      final remoteUpdatedAt = DateTime.parse(rnw['updatedAt'] ?? rnw['createdAt']);

      if (localNw == null) {
        // New item
        await HiveService.netWorthSnapshotBox.put(
          rnw['id'],
          NetWorthSnapshotModel(
            id: rnw['id'],
            year: rnw['year'],
            month: rnw['month'],
            snapshotDate: DateTime.parse(rnw['snapshotDate']),
            totalAssets: (rnw['totalAssets'] as num).toDouble(),
            totalLiabilities: (rnw['totalLiabilities'] as num).toDouble(),
            netWorth: (rnw['netWorth'] as num).toDouble(),
            growthPercentMoM: (rnw['growthPercentMoM'] as num).toDouble(),
            growthPercentYoY: (rnw['growthPercentYoY'] as num).toDouble(),
            createdAt: DateTime.parse(rnw['createdAt']),
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  // Mark All Data as Synced
  // ─────────────────────────────────────────────

  static Future<void> _markAllSynced() async {
    for (var t in HiveService.box.values) {
      if (!t.isSynced) {
        t.isSynced = true;
        await t.save();
      }
    }
    for (var c in HiveService.categoryBox.values) {
      if (!c.isSynced) {
        c.isSynced = true;
        await c.save();
      }
    }
    for (var r in HiveService.recurringBox.values) {
      if (!r.isSynced) {
        r.isSynced = true;
        await r.save();
      }
    }
    for (var b in HiveService.budgetBox.values) {
      if (!b.isSynced) {
        b.isSynced = true;
        await b.save();
      }
    }
    for (var g in HiveService.goalBox.values) {
      if (!g.isSynced) {
        g.isSynced = true;
        await g.save();
      }
    }
    for (var cb in HiveService.contributionBox.values) {
      if (!cb.isSynced) {
        cb.isSynced = true;
        await cb.save();
      }
    }

    final efp = HiveService.getEmergencyFundProfile();
    if (!efp.isSynced) {
      efp.isSynced = true;
      await HiveService.updateEmergencyFundProfile(efp);
    }
  }

  // ─────────────────────────────────────────────
  // Google Drive File Operations
  // ─────────────────────────────────────────────

  /// Find or create the "MoniMate" folder in Google Drive root.
  static Future<String> _getOrCreateFolder() async {
    final api = _driveApi!;

    // Search for existing folder
    final folderSearch = await api.files.list(
      q: "name = '$_folderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    if (folderSearch.files != null && folderSearch.files!.isNotEmpty) {
      return folderSearch.files!.first.id!;
    }

    // Create folder
    final folderMetadata = drive.File()
      ..name = _folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final folder = await api.files.create(folderMetadata);
    return folder.id!;
  }

  /// Upload a JSON string as a file to the given Drive folder.
  /// If the file already exists, update it; otherwise create it.
  static Future<void> _uploadFile(
      String folderId, String fileName, String content) async {
    final api = _driveApi!;

    // Search for existing file
    final fileSearch = await api.files.list(
      q: "name = '$fileName' and '$folderId' in parents and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    final media = drive.Media(
      Stream.value(utf8.encode(content)),
      utf8.encode(content).length,
    );

    if (fileSearch.files != null && fileSearch.files!.isNotEmpty) {
      // Update existing file
      await api.files.update(
        drive.File()..name = fileName,
        fileSearch.files!.first.id!,
        uploadMedia: media,
      );
    } else {
      // Create new file
      final fileMetadata = drive.File()
        ..name = fileName
        ..parents = [folderId];

      await api.files.create(
        fileMetadata,
        uploadMedia: media,
      );
    }
  }

  /// Download the content of a file from the given Drive folder.
  /// Returns null if the file doesn't exist.
  static Future<String?> _downloadFile(String folderId, String fileName) async {
    final api = _driveApi!;

    final fileSearch = await api.files.list(
      q: "name = '$fileName' and '$folderId' in parents and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    if (fileSearch.files == null || fileSearch.files!.isEmpty) {
      return null;
    }

    final fileId = fileSearch.files!.first.id!;
    final response = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytes = <int>[];
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
    }

    return utf8.decode(bytes);
  }

  // ─────────────────────────────────────────────
  // Unsynced Count (for badge/indicator)
  // ─────────────────────────────────────────────

  /// Returns the total number of unsynced items across all boxes.
  static int getUnsyncedCount() {
    int count = 0;
    count += HiveService.box.values.where((e) => !e.isSynced).length;
    count += HiveService.categoryBox.values.where((e) => !e.isSynced).length;
    count += HiveService.recurringBox.values.where((e) => !e.isSynced).length;
    count += HiveService.budgetBox.values.where((e) => !e.isSynced).length;
    count += HiveService.goalBox.values.where((e) => !e.isSynced).length;
        HiveService.contributionBox.values.where((e) => !e.isSynced).length;
    
    if (!HiveService.getEmergencyFundProfile().isSynced) count += 1;

    return count;
  }
}
