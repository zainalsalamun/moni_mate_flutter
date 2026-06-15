# 🚀 Roadmap Fitur Pembeda MoniMate

> Dokumentasi ide fitur untuk membedakan MoniMate dari aplikasi keuangan lainnya.
> Dikerjakan secara bertahap (gradual implementation).

---

## 📊 Analisis Fitur yang Sudah Ada

| Kategori | Fitur Saat Ini |
|----------|---------------|
| 🤖 AI | Receipt Scanner (Gemini + ML Kit), Financial Insights |
| 💰 Budget | Smart Budgeting, Strict Mode, Progress Bar |
| 🎯 Goals | Financial Goals, Achievements & Gamification |
| 📊 Stats | Pie Chart, Bar Chart, Calendar View |
| ☁️ Sync | Google Drive Cloud Sync |
| 🔒 Privacy | Hive Local DB, Offline-First |
| 📤 Export | CSV Export & Share |
| 🔄 Recurring | Auto Recurring Transactions |
| 🔔 Alerts | Smart Budget Alerts |

---

## 💡 Ide Fitur Pembeda (10 Ide Utama)

### 1. 🏦 Virtual Envelope / Tabungan Amplop

**Konsep:** Metode "envelope budgeting" — alokasikan uang ke dalam "amplop virtual" per tujuan.

**Mengapa berbeda:** Kebanyakan app hanya menampilkan budget per kategori. MoniMate memvisualisasikan uang yang "dikunci" untuk tujuan tertentu.

**Detail:**
- Buat amplop virtual: "Dana Darurat", "Liburan", "Sekolah Anak"
- Setiap transaksi bisa dialokasikan ke amplop tertentu
- Visualisasi amplop dengan animasi terisi/kosong
- Sisa uang "bebas" (tidak teralokasi) ditampilkan jelas
- Quick allocate dari transaksi yang sudah ada

**Estimasi:** 3-4 hari

---

### 2. 📱 Biometric Lock & Private Mode

**Konsep:** Kunci aplikasi dengan fingerprint / PIN / Face ID untuk privasi ekstra.

**Mengapa berbeda:** Banyak app keuangan yang tidak punya lock screen, atau hanya basic PIN.

**Detail:**
- Fingerprint / Face ID unlock
- PIN fallback (6 digit)
- "Private Mode" — sembunyikan saldo di dashboard (tap untuk reveal)
- Auto-lock setelah X menit tidak aktif
- Sembunyikan notifikasi preview (saldo, nominal transaksi)

**Estimasi:** 2-3 hari

---

### 3. 🔮 Cash Flow Forecasting (Prediksi Arus Kas)

**Konsep:** Prediksi saldo di masa depan berdasarkan pola transaksi historis.

**Mengapa berbeda:** App lain hanya menampilkan data masa lalu. MoniMate memprediksi masa depan.

**Detail:**
- Grafik garis prediksi saldo 30 hari ke depan
- Hitung rata-rata pengeluaran harian/mingguan
- Prediksi kapan saldo akan habis (jika pola berlanjut)
- Warning: "Berdasarkan pola, kamu akan kehabisan budget makan di tanggal 22"
- Visualisasi garis putus-putus di chart untuk forecast

**Estimasi:** 4-5 hari

---

### 4. 🏷️ Smart Tags & Custom Fields

**Konsep:** Sistem tagging fleksibel untuk pencatatan yang lebih kaya.

**Mengapa berbeda:** App lain hanya ada kategori. MoniMate memungkinkan tagging silang (cross-cutting).

**Detail:**
- Tag custom: #liburan, #work, #lembur, #traktir
- Multi-tag per transaksi (bisa lebih dari 1)
- Custom fields opsional: lokasi, siapa yang bayar, mood
- Filter transaksi berdasarkan tag (AND/OR)
- Tag-based analytics: "Berapa total belanja #work bulan ini?"
- Tag suggestion berdasarkan history

**Estimasi:** 3-4 hari

---

### 5. 🔄 Subscription Tracker

**Konsep:** Pantau semua langganan (Netflix, Spotify, Domain, dll) dalam satu tempat.

**Mengapa berbeda:** Subscription sering "lupa" dan terus memotong saldo. Fitur ini belum umum di app keuangan Indonesia.

**Detail:**
- Daftar semua subscription aktif (nama, nominal, billing cycle)
- Hitung total pengeluaran subscription per bulan/tahun
- Reminder sebelum jatuh tempo (H-3, H-1)
- Status: aktif / paused / cancelled
- Rekomendasi: "Kamu bayar Rp 350rb/bulan untuk 5 subscription. Potensi hemat: Rp 100rb"
- Chart perbandingan subscription vs total pengeluaran

**Estimasi:** 3-4 hari

---

### 6. 💸 Debt Tracker & Split Bills

**Konsep:** Lacak utang piutang dan bagi tagihan dengan teman/keluarga.

**Mengapa berbeda:** Fitur yang sangat dibutuhkan tapi jarang ada di app keuangan pribadi.

**Detail:**
- Catat utang: siapa berutang, nominal, tanggal, status
- Reminder otomatis untuk tagihan jatuh tempo
- Split bills: bagi tagihan makan/sewa dengan beberapa orang
- Settlement tracker: sudah lunas / belum
- Dashboard card: total utang masuk vs utang keluar
- Export laporan utang ke CSV

**Estimasi:** 4-5 hari

---

### 7. 🎮 Savings Challenge (Tantangan Menabung)

**Konsep:** Mini-games menabung yang memotivasi dan menyenangkan.

**Mengapa berbeda:** Gamifikasi yang lebih interaktif dari sekadar achievement badge.

**Detail:**
- **52 Week Challenge:** Tabung Rp 10rb di minggu 1, Rp 20rb di minggu 2, dst
- **No-Spend Day:** Challenge tidak belanja di hari tertentu
- **Savings Sprint:** "Hemat Rp 500rb dalam 7 hari"
- Streak counter dan progress visualization (pohon tumbuh 🌱→🌳)
- Confetti animation saat challenge selesai 🎉
- Leaderboard pribadi (compare bulan ini vs bulan lalu)
- Share progress ke sosial media

**Estimasi:** 3-4 hari

---

### 8. 🤖 AI Financial Chat

**Konsep:** Chatbot AI yang bisa diajak konsultasi keuangan pribadi.

**Mengapa berbeda:** Kebanyakan app hanya menampilkan grafik. MoniMate punya "financial advisor" pribadi.

**Detail:**
- Chat interface dengan AI (Gemini)
- Analisis otomatis dari data transaksi pengguna
- Contoh pertanyaan yang bisa dijawab:
  - "Kenapa pengeluaran makan minggu ini naik?"
  - "Berapa rata-rata belanja kopi saya per bulan?"
  - "Bulan ini pengeluaran saya lebih besar dari bulan lalu?"
  - "Saran untuk hemat bulan ini?"
- Response dengan data aktual dari database lokal
- History chat tersimpan

**Estimasi:** 5-7 hari

---

### 9. 📊 Merchant & Tempat Favorit Analytics

**Konsep:** Analisis pengeluaran berdasarkan merchant/toko/lokasi.

**Mengapa berbeda:** Insight yang sangat personal tapi jarang ada di app lain.

**Detail:**
- Top 10 merchant by total spending
- Peta distribusi pengeluaran (integrasi maps)
- Perbandingan harga: "Kopi di Starbucks = Rp 55rb, di Kopi Kenangan = Rp 28rb"
- Merchant trend: apakah belanja di merchant tertentu naik/turun
- "Kamu sudah ke Starbucks 12 kali bulan ini, total Rp 660rb"
- Rekomendasi merchant serupa dengan harga lebih murah

**Estimasi:** 4-5 hari

---

### 10. 🌙 Mood-Based Spending Journal

**Konsep:** Catat mood saat belanja untuk analisis emotional spending.

**Mengapa berbeda:** Pendekatan psikologis keuangan yang belum ada di app Indonesia.

**Detail:**
- Pilih mood saat add transaksi: 😊 Happy, 😰 Stressed, 😤 Frustrated, 😌 Calm, 🤩 Excited
- Mood picker sederhana (1 tap)
- Analytics: "Kamu paling banyak belanja saat mood Stressed"
- Weekly mood-spending correlation chart
- Insight: "Pengeluaran impulsif meningkat 40% saat kamu stressed"
- Financial wellness tips berdasarkan pola mood-spending

**Estimasi:** 3-4 hari

---

## 📋 Prioritas & Estimasi Implementasi

| # | Fitur | Prioritas | Estimasi | Kategori |
|---|-------|-----------|----------|----------|
| 1 | Virtual Envelope | ⭐⭐⭐ | 3-4 hari | Budget |
| 2 | Biometric Lock | ⭐⭐⭐ | 2-3 hari | Security |
| 3 | Cash Flow Forecasting | ⭐⭐ | 4-5 hari | Analytics |
| 4 | Smart Tags | ⭐⭐ | 3-4 hari | Categorization |
| 5 | Subscription Tracker | ⭐⭐⭐ | 3-4 hari | Tracking |
| 6 | Debt Tracker & Split Bills | ⭐⭐ | 4-5 hari | Social |
| 7 | Savings Challenge | ⭐⭐ | 3-4 hari | Gamification |
| 8 | AI Financial Chat | ⭐⭐⭐ | 5-7 hari | AI |
| 9 | Merchant Analytics | ⭐ | 4-5 hari | Analytics |
| 10 | Mood-Based Journal | ⭐ | 3-4 hari | Psychology |

---

## ✅ Checklist Implementasi (Bertahap)

### Fase 1 — Quick Wins (1-2 minggu)
- [ ] Biometric Lock & Private Mode (#2)
- [ ] Subscription Tracker (#5)
- [ ] Smart Tags & Custom Fields (#4)

### Fase 2 — Core Differentiators (2-3 minggu)
- [ ] Virtual Envelope / Tabungan Amplop (#1)
- [ ] Savings Challenge (#7)
- [ ] Cash Flow Forecasting (#3)

### Fase 3 — Advanced Features (3-4 minggu)
- [ ] Debt Tracker & Split Bills (#6)
- [ ] AI Financial Chat (#8)
- [ ] Mood-Based Spending Journal (#10)

### Fase 4 — Analytics Powerhouse (2-3 minggu)
- [ ] Merchant & Tempat Favorit Analytics (#9)
- [ ] Advanced Reporting & Export Enhancement
- [ ] Widget Home Screen (Quick Add & Saldo)

---

## 💡 Tips Implementasi

1. **Mulai dari Fase 1** — Quick wins yang langsung terasa manfaatnya
2. **Manfaatkan infra yang sudah ada** — Hive DB, Gemini API, Google Drive Sync
3. **Incremental delivery** — Rilis fitur satu per satu
4. **Test di web juga** — Pastikan fitur baru kompatibel dengan web version
5. **User feedback** — Setelah setiap fase, kumpulkan feedback
6. **Offline-first** — Semua fitur harus tetap jalan tanpa internet

---

> **Catatan:** Semua fitur dirancang untuk menjaga DNA MoniMate: **Offline-First**, **Privacy-Focused**, dan **AI-Powered**.

*Last updated: 15 June 2026*
