# 🤖 Agent Guide — MoniMate Flutter

> Panduan lengkap untuk AI Agent (atau developer baru) yang bekerja di codebase MoniMate.

---

## 📌 Project Overview

**MoniMate** adalah aplikasi pencatat keuangan pribadi berbasis Flutter dengan pendekatan **offline-first** dan **AI-powered**. Aplikasi ini menggunakan:

- **GetX** untuk state management & dependency injection
- **Hive** sebagai local database (NoSQL)
- **Google Gemini API** untuk AI features (receipt scanning, financial insights)
- **Google ML Kit** untuk OCR offline (fallback saat tidak ada internet)

**Target Platform:** Android & iOS (dan eksperimental Web)

---

## 🏗️ Arsitektur & Struktur Folder

```
lib/
├── main.dart                    # Entry point, inisialisasi GetMaterialApp
├── theme/
│   └── app_theme.dart           # ThemeData (Light & Dark), Ocean Toska gradient
├── data/
│   ├── models/                  # Data models (Hive TypeAdapters)
│   │   ├── transaction_model.dart
│   │   ├── category_model.dart
│   │   ├── recurring_transaction_model.dart
│   │   ├── goal_model.dart
│   │   ├── contribution_model.dart
│   │   └── *.g.dart             # Generated Hive adapters (jangan edit manual!)
│   ├── controller/              # GetX Controllers (business logic)
│   │   ├── transaction_controller.dart
│   │   ├── theme_controller.dart
│   │   ├── recurring_controller.dart
│   │   └── sync_controller.dart
│   └── services/                # Service layer (data access, API calls)
│       ├── hive_service.dart        # Central Hive DB access
│       ├── notification_service.dart
│       ├── export_service.dart
│       ├── receipt_scanner_service.dart  # Gemini + ML Kit
│       ├── sync_service.dart        # Google Drive sync
│       └── seeder_service.dart      # Seed data awal
├── features/
│   ├── budget/                  # Modular feature: Smart Budgeting
│   │   ├── model/budget_model.dart
│   │   ├── controller/budget_controller.dart
│   │   ├── engine/budget_engine.dart
│   │   └── view/                # Budget UI components
│   └── financial_goals/         # Modular feature: Financial Goals
│       ├── controllers/goals_controller.dart
│       └── views/               # Goals UI components
├── pages/                       # Halaman utama (top-level)
│   ├── shell.dart               # Bottom Navigation Bar & page routing
│   ├── splash_page.dart
│   ├── dashboard_page.dart
│   ├── transactions_page.dart
│   ├── add_page.dart
│   ├── stats_page.dart
│   ├── settings_page.dart
│   ├── scan_receipt_page.dart
│   ├── receipt_result_page.dart
│   ├── analyze_receipt_page.dart
│   ├── recurring_manager_page.dart
│   ├── sync_page.dart
│   └── transactions_page_shell.dart
└── utils/                       # Helper functions
    ├── format_currency.dart     # Format "Rp 1.000.000"
    ├── date_formater.dart       # Format tanggal Indonesia
    ├── category_icon.dart       # Emoji/icon per kategori
    └── clean_currency.dart      # Parse user input ke angka
```

---

## 🎨 Design System & Warna

| Token | Hex | Kegunaan |
|-------|-----|----------|
| Primary | `#0288D1` | Warna utama, button, aksen |
| Secondary | `#4FC3F7` | Gradient, highlight |
| Accent | `#00E5FF` | Aksen tambahan |
| Light BG | `#F7FAFC` | Background light mode |
| Dark BG | `#0B1220` | Background dark mode |
| Dark Card | `#131E32` | Card di dark mode |

**Font:** Poppins (via Google Fonts)
**Icons:** Lucide Icons
**Border Radius:** Card = 20, Button = 14, Input = 14

---

## 📐 Patterns & Conventions

### 1. State Management — GetX

Semua controller menggunakan **GetX** dengan pattern reactive:

```dart
class TransactionController extends GetxController {
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxDouble totalIncome = 0.0.obs;
  
  // Gunakan .obs untuk reactive state
  // Akses value: totalIncome.value
  // Di UI: Obx(() => Text(totalIncome.value.toString()))
}
```

**Rules:**
- Controller didaftarkan via `Get.put()` atau `Get.lazyPut()`
- Gunakan `Get.find<Controller>()` untuk mengakses controller
- Register permanent controllers di `ShellController` (nav index)
- Non-permanent controllers dihapus otomatis saat page dispose

### 2. Data Layer — Hive

**Model Pattern:**
```dart
@HiveType(typeId: X)  // Pastikan typeId unik!
class MyModel extends HiveObject {
  @HiveField(0)
  String id;
  
  // ... fields lainnya
}
```

**Rules:**
- Jangan edit file `.g.dart` manual — gunakan `dart run build_runner build`
- Untuk menambah field baru ke model yang sudah ada, gunakan `@HiveField(N)` dengan N yang belum terpakai
- Setiap model harus diregistrasi di `HiveService.init()`
- Gunakan `const Uuid().v4()` untuk generate ID unik

### 3. Feature Module Pattern

Fitur yang cukup kompleks dikelompokkan di `lib/features/`:
```
features/
└── feature_name/
    ├── model/        # Data model
    ├── controller/   # GetX controller
    └── view/         # UI widgets/pages
```

Fitur sederhana bisa langsung di `lib/pages/`.

### 4. Page Navigation

- **Bottom Nav:** Diatur di `Shell` (shell.dart) dengan index-based routing
- **Named Routes:** Belum digunakan secara luas — kebanyakan push manual
- **Full-screen pages:** Push via `Get.to(() => PageName())`

### 5. Currency & Date Format

```dart
// Currency — selalu gunakan helper
CurrencyFormat.format(amount)  // "Rp 1.000.000"

// Date
DateFormatter.format(date)     // "15 Juni 2026"
```

---

## 🔧 Cara Kerja

### Menambah Transaksi Baru
```
User input → AddPage → TransactionController.addTransaction()
                     → HiveService.addTransaction() → Hive DB
                     → SyncController.notifyDataChanged() → auto sync
```

### Receipt Scanner Flow
```
User scan → ScanReceiptPage → ReceiptScannerService
                            → Coba Gemini API (online)
                            → Fallback ke ML Kit (offline)
                            → ReceiptResultPage (review & edit)
                            → Save ke Hive DB
```

### Budget Monitoring Flow
```
Transaction added → BudgetController checks
                 → BudgetEngine.calculate() → persentase usage
                 → Jika > 80%: trigger notification
                 → Jika > 90%: shake animation + strict mode
```

---

## 📝 Checklist untuk Menambah Fitur Baru

1. **Model** — Buat/modify model di `lib/data/models/` dengan `@HiveType`
2. **Hive Registration** — Daftarkan adapter di `HiveService.init()`
3. **Controller** — Buat GetX controller di `lib/data/controller/` atau `lib/features/`
4. **Service** (jika perlu) — Buat service di `lib/data/services/`
5. **UI** — Buat page/widget di `lib/pages/` atau `lib/features/`
6. **Navigation** — Tambah akses ke page baru (bottom nav, button, dll)
7. **Notification** (jika perlu) — Update `NotificationService`
8. **Sync** — Pastikan sync compatibility jika ada perubahan model
9. **Seed Data** (jika perlu) — Update `SeederService`
10. **Test** — Jalankan `flutter run` di Android/iOS/Web

---

## ⚠️ Hal Penting yang Harus Diperhatikan

### DO ✅
- Gunakan `CurrencyFormat.format()` untuk semua nominal uang
- Gunakan `Obx(() => ...)` untuk reactive UI
- Handle dark mode — cek `Theme.of(context).brightness`
- Test di kedua tema (light & dark)
- Ikuti naming convention: `snake_case` untuk file, `PascalCase` untuk class
- Register Hive adapter baru di `HiveService.init()`
- Gunakan `const` constructor jika memungkinkan

### DON'T ❌
- Jangan edit file `.g.dart` manual
- Jangan hardcode warna — gunakan `Theme.of(context).colorScheme` atau constant di `AppTheme`
- Jangan lupa `Get.isRegistered<SyncController>()` check sebelum notify sync
- Jangan gunakan `setState` di luar `StatefulWidget` — gunakan `.obs` + `Obx()`
- Jangan skip null check untuk field optional di model
- Jangan lupa handle case offline untuk fitur AI

---

## 🧪 Testing

```bash
# Run di Android
flutter run -d <device-id>

# Run di Web
flutter run -d chrome

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Regenerate Hive adapters
dart run build_runner build --delete-conflicting-outputs
```

---

## 🌐 Environment Variables

File `.env` di root project:

```
GEMINI_API_KEY=your_api_key_here
```

Akses via: `dotenv.env['GEMINI_API_KEY']`

**⚠️ Jangan commit `.env` ke Git — sudah di-.gitignore**

---

## 🔄 Sync Architecture

```
Local (Hive) ←→ SyncController ←→ Google Drive
                      ↓
              connectivity_plus (monitor)
                      ↓
              Auto sync saat online
```

**Rules:**
- Setiap perubahan data panggil `SyncController.notifyDataChanged()`
- Sync hanya jalan saat ada koneksi internet
- Conflict resolution: last-write-wins (berdasarkan `updatedAt`)

---

## 📚 Dependencies Penting

| Package | Fungsi |
|---------|--------|
| `get` | State management, DI, navigation |
| `hive` + `hive_flutter` | Local NoSQL database |
| `google_generative_ai` | Gemini API (AI features) |
| `google_mlkit_text_recognition` | OCR offline |
| `flutter_local_notifications` | Push notification lokal |
| `fl_chart` | Pie chart & bar chart |
| `table_calendar` | Calendar view |
| `lottie` | Animasi JSON |
| `confetti` | Efek confetti celebration |
| `flutter_dotenv` | Environment variables |
| `googleapis` + `google_sign_in` | Google Drive sync |
| `connectivity_plus` | Network status monitoring |

---

## 🚀 Quick Reference

| Task | Command/Code |
|------|-------------|
| Tambah model Hive | Buat class + `@HiveType`, jalankan `build_runner` |
| Tambah controller | `class XController extends GetxController {}` |
| Register controller | `Get.put(XController())` atau `Get.lazyPut(() => XController())` |
| Akses controller | `Get.find<XController>()` |
| Format rupiah | `CurrencyFormat.format(amount)` |
| Generate UUID | `const Uuid().v4()` |
| Trigger sync | `Get.find<SyncController>().notifyDataChanged()` |
| Notification | `NotificationService.showNotification(...)` |
| Push page | `Get.to(() => TargetPage())` |
| Show snackbar | `Get.snackbar('Title', 'Message')` |

---

> **Last Updated:** 15 June 2026
> **Maintainer:** Zainal Salamun
