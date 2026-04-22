# 💰 MoniMate — Personal Finance Tracker (AI Powered)

> Kelola keuanganmu dengan cerdas, bahkan tanpa koneksi internet.

---

## 🌟 Deskripsi

**MoniMate** adalah aplikasi pencatat keuangan pribadi berbasis **Flutter** yang mengutamakan privasi dengan pendekatan **offline-first**. Aplikasi ini didesain dengan antarmuka **Fintech Modern** yang elegan, mendukung Light/Dark mode, dan kini dilengkapi dengan teknologi **AI Receipt Scanner** untuk pencatatan transaksi yang super cepat.

Aplikasi ini memudahkan pengguna untuk:
1. Mencatat pemasukan dan pengeluaran secara manual maupun otomatis via Hybrid AI (Gemini + ML Kit).
2. Memantau kesehatan keuangan melalui grafik statistik yang interaktif dan dashboard modern.
3. Melakukan backup data ke file CSV.
4. Menjalankan fungsi utama secara offline (dengan dukungan AI cerdas saat online).

---

## 🔥 Fitur Unggulan

- 🧠 **Hybrid AI Receipt Scanner** — Scan struk belanja menggunakan kamera. Menggunakan **Google Gemini API** untuk ekstraksi data dengan akurasi tinggi (nominal dan nama merchant), dan otomatis *fallback* ke **Google ML Kit** (offline) jika terjadi masalah koneksi atau limit API.
- 🎯 **Smart Budgeting** — Atur budget bulanan per kategori. Pantau penggunaan secara real-time dengan progress bar interaktif:
  - 🟢 < 70%: Hemat (Ocean Toska)
  - 🟠 70-90%: Waspada (Orange)
  - 🔴 > 90%: Bahaya (Red + Shake Animation)
- 🔒 **Strict Mode** — Fitur keamanan finansial level pro yang mencegah pencatatan transaksi jika sudah melebihi budget yang ditentukan.
- 💡 **AI Financial Insights** — Analisis otomatis perilaku keuangan (analisis akhir pekan, tren pengeluaran bulanan, dan deteksi kebiasaan ngopi).
- 🕒 **Recurring Transactions** — Otomatisasi pencatatan tagihan rutin atau pendapatan berkala (gaji, bonus) untuk kemudahan jangka panjang.
- 🔔 **Smart Alerts** — Notifikasi lokal otomatis yang mengingatkanmu saat pengeluaran mencapai 80% dan 100% dari limit.
- 🌊 **Modern Fintech UI** — Antarmuka premium dengan kombinasi warna *Ocean Toska* (`#0288D1` & `#4FC3F7`), pemformatan Rupiah otomatis (`Rp. 1.000.000`), animasi yang halus, dan layout responsif untuk pengalaman pengguna yang maksimal.
- 📊 **Smart Statistics** — Visualisasi pengeluaran bulanan menggunakan *Pie Chart* dan tren mingguan dengan *Bar Chart*.
- 🌓 **Dynamic Theme** — Dukungan penuh untuk Mode Terang (Light) dan Mode Gelap (Dark).
- 📅 **Calendar View** — Lihat riwayat transaksi berdasarkan tanggal dengan mudah lewat antarmuka kalender.
- 🔒 **Privacy Focused** — Data disimpan secara lokal menggunakan database Hive yang cepat dan aman.
- 📤 **Data Export** — Ekspor seluruh riwayat transaksi ke format CSV untuk keperluan laporan eksternal.

---

## ⚙️ Tech Stack

| Komponen | Teknologi |
|----------|------------|
| **Core Framework** | Flutter (3.24+) |
| **State Management** | GetX |
| **Local Database** | Hive |
| **AI Engine** | Google Gemini API & Google ML Kit (Text Recognition) |
| **Local Notifications** | flutter_local_notifications |
| **Animation & Feedback** | confetti, vibration |
| **Charts** | fl_chart |
| **State Persistence** | GetStorage |
| **UI Components** | Google Fonts (Outfit), Lucide Icons |

---

## 🧰 Struktur Proyek

| Folder | Deskripsi |
| --- | --- |
| `lib/features/budget/` | **[NEW]** Sistem budget pintar, AI insights engine, dan UI monitoring budget. |
| `lib/data/` | Model data utama, controller (Mutasi, Rutinitas), dan layanan (Hive, Export). |
| `lib/pages/` | Halaman Dashboard, Statistik, Kalender, dan Pengaturan. |
| `lib/theme/` | Konfigurasi tema warna, gradasi, dan gaya teks aplikasi. |
| `lib/utils/` | Fungsi format mata uang, tanggal, dan helper pembersihan teks. |

---

## 🧾 Preview (Screenshots)

Versi Light & Dark Mode
<table> 
  <tr> 
    <td><img src="assets/screenshots/dashboard_light.png" width="230"></td> 
    <td><img src="assets/screenshots/add_light.png" width="230"></td> 
    <td><img src="assets/screenshots/stats_light.png" width="230"></td> 
    <td><img src="assets/screenshots/settings_light.png" width="230"></td> 
  </tr> 
  <tr> 
    <th>Dashboard</th> <th>AI Scanner / Add</th> <th>Statistik</th> <th>Settings</th> 
  </tr> 
</table>

---

## 👨‍💻 Kontributor

**Zainal Salamun**  
Android & Flutter Developer  
💼 7+ tahun pengalaman di ekosistem Mobile Development.  
🌍 Indonesia  
📬 [LinkedIn](https://www.linkedin.com/in/zainal-salamun-660a9598/) • [Threads](https://www.threads.com/@zainalsalamun)

---

## 🛠️ Cara Menjalankan

1. **Clone & Install**:
   ```bash
   git clone https://github.com/zainalsalamun/moni_mate_flutter
   cd moni_mate_flutter
   flutter pub get
   ```

2. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

3. **Build APK untuk Android**:
   ```bash
   # Build APK Universal (ukuran lebih besar)
   flutter build apk --release

   # Build APK terpisah berdasarkan arsitektur (ukuran lebih kecil dan efisien)
   flutter build apk --split-per-abi

   # Build APK untuk arsitektur spesifik (contoh: ARM64 untuk HP modern)
   flutter build apk --target-platform android-arm64 --release
   ```

4. **Build AppBundle (AAB) untuk Google Play Store**:
   ```bash
   flutter build appbundle --release
   ```

5. **Build iOS (IPA) untuk App Store**:
   ```bash
   flutter build ipa --release
   ```

---

## 🏷️ Tagline

> **MoniMate** — *Teman cerdas finansialmu, kapan saja, di mana saja, bahkan tanpa sinyal.*
