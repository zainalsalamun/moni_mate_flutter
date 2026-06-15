# 🚀 MoniMate — Future Feature Roadmap

> Daftar ide fitur pembeda untuk MoniMate agar berbeda dari aplikasi keuangan lainnya.
> Dikerjakan secara bertahap (gradual).

---

## 📋 Prioritas Implementasi

| # | Prioritas | Estimasi | Status |
|---|-----------|----------|--------|
| 1 | P1 — High | 3-5 hari | ⬜ Belum |
| 2 | P2 — Medium | 2-4 hari | ⬜ Belum |
| 3 | P3 — Medium | 2-3 hari | ⬜ Belum |
| 4 | P4 — Medium | 3-5 hari | ⬜ Belum |
| 5 | P5 — Low | 2-3 hari | ⬜ Belum |
| 6 | P6 — Low | 2-4 hari | ⬜ Belum |
| 7 | P7 — Low | 3-5 hari | ⬜ Belum |
| 8 | P8 — Low | 2-3 hari | ⬜ Belum |
| 9 | P9 — Low | 3-5 hari | ⬜ Belum |
| 10 | P10 — Low | 2-4 hari | ⬜ Belum |

---

## 1. 🤖 AI Financial Advisor (Smart Chatbot)

**Mengapa berbeda:** Kebanyakan app hanya menampilkan data. MoniMate akan punya "penasihat keuangan pribadi" yang bisa diajak ngobrol.

**Deskripsi:**
- Chatbot AI berbasis Gemini yang bisa menjawab pertanyaan keuangan pengguna
- Analisis pola belanja dan memberikan saran personalisasi
- Contoh: "Kenapa pengeluaran makan minggu ini naik 30%?"
- Rekomendasi bulanan: "Kamu bisa hemat Rp 500rb dengan mengurangi belanja online"

**Tech:**
- Integrasikan Gemini API untuk analisis kontekstual dari data transaksi
- Buat prompt template yang mengambil data transaksi aktual
- Chat UI dengan streaming response

---

## 2. 💰 Wallet / Dompet Virtual Multi-Akun

**Mengapa berbeda:** App lain hanya mencatat transaksi. MoniMate akan memetakan "dompet" digital pengguna.

**Deskripsi:**
- Buat multiple "wallet": Cash, Bank BCA, GoPay, Dana, Kartu Kredit, dll
- Setiap transaksi dihubungkan ke wallet tertentu
- Dashboard menampilkan total saldo semua wallet
- Transfer antar wallet (misal: "tarik tunai dari BCA ke Cash")
- Monitoring pengeluaran per wallet

**Tech:**
- Model baru: `WalletModel` dengan field: name, type, balance, icon, color
- Controller baru: `WalletController`
- UI: Wallet section di dashboard dengan ringkasan per wallet

---

## 3. 📸 Smart Receipt Scanner v2 — Multi-Item Extraction

**Mengapa berbeda:** App lain hanya scan total nominal. MoniMate akan extract per item belanja.

**Deskripsi:**
- Scan struk → otomatis extract setiap item belanja (nama, harga, qty)
- Hitung total otomatis dan bandingkan dengan total di struk
- Simpan transaksi dengan detail itemized
- Grafik "pembelian per item" untuk analisis pola belanja

**Tech:**
- Enhance Gemini prompt untuk extract itemized list dari receipt
- Model baru: `ReceiptItemModel` (name, qty, unitPrice, total)
- UI: Review page dengan editable item list

---

## 4. 🎯 Savings Challenge / Tantangan Menabung

**Mengapa berbeda:** Fitur gamification yang belum ada di app keuangan lain.

**Deskripsi:**
- **52 Week Challenge:** Tabung Rp 10.000 di minggu 1, Rp 20.000 di minggu 2, dst
- **No Spend Day:** Tantangan tidak belanja di hari tertentu
- **Cashback Quest:** "Hemat Rp 200rb dari budget makan bulan ini"
- Streak counter dan achievement badge
- Progress visualization yang menyenangkan (pohon tumbuh, rumah terbang, dll)

**Tech:**
- Model: `ChallengeModel` (type, target, current, startDate, status)
- Controller: `ChallengeController`
- Confetti animation saat challenge selesai

---

## 5. 📊 Predictive Analytics — Prediksi Pengeluaran

**Mengapa berbeda:** App lain hanya menampilkan data masa lalu. MoniMate akan memprediksi masa depan.

**Deskripsi:**
- Prediksi total pengeluaran bulan ini berdasarkan tren 3 bulan terakhir
- Warning jika diprediksi akan over budget
- Forecast saldo akhir bulan
- "Kamu akan kehabisan budget makan di tanggal 22 jika tetap belanja seperti ini"

**Tech:**
- Algoritma simple moving average dari data transaksi
- Visualisasi garis prediksi di chart (garis putus-putus)
- Notifikasi cerdas berdasarkan prediksi

---

## 6. 👨‍👩‍👧‍👦 Shared Finance / Keuangan Keluarga

**Mengapa berbeda:** MoniMate menjadi app keuangan untuk seluruh keluarga, bukan hanya个人.

**Deskripsi:**
- Buat "Group" untuk keluarga (Ayah, Ibu, Anak)
- Setiap anggota punya role (admin/viewer/editor)
- Budget keluarga dengan alokasi per anggota
- Dashboard gabungan untuk melihat keuangan keluarga
- Split bill tracker (siapa bayar apa)

**Tech:**
- Model: `FamilyGroup`, `FamilyMember`
- Sync antar device via Google Drive (sudah ada infra)
- Permission system sederhana

---

## 7. 🌍 Multi-Currency Support

**Mengapa berbeda:** MoniMate bisa digunakan traveler dan pekerja lintas negara.

**Deskripsi:**
- Support multi mata uang (IDR, USD, EUR, JPY, SGD, dll)
- Auto konversi berdasarkan lokasi atau manual
- Riwayat transaksi tetap dalam mata uang asli
- Ringkasan dalam satu mata uang utama (base currency)
- Helpful untuk: liburan ke luar negeri, freelancer remote

**Tech:**
- API kurs mata uang (ExchangeRate API atau similar)
- Model: currency field pada transaction
- Settings: pilih base currency

---

## 8. 📅 Bill Split & Debt Tracker

**Mengapa berbeda:** Fitur "utang piutang" yang sering dilupakan app lain.

**Deskripsi:**
- Catat siapa yang berutang ke kamu
- Catat ke mana kamu berutang
- Reminder otomatis untuk tagihan jatuh tempo
- Settlement tracker (sudah lunas / belum)
- Export laporan utang piutang

**Tech:**
- Model: `DebtModel` (creditor, debtor, amount, dueDate, status)
- Notification: reminder H-3, H-1 jatuh tempo
- UI: Debt summary card di dashboard

---

## 9. 🏷️ Smart Tags & Custom Fields

**Mengapa berbeda:** Fleksibilitas pencatatan yang lebih tinggi dari app lain.

**Deskripsi:**
- Tambahkan tag custom ke transaksi: #liburan, #work, #personal
- Filter dan cari transaksi berdasarkan tag
- Custom fields: misal "lokasi", "siapa yang traktir", "mood belanja"
- Tag-based analytics: "Berapa banyak saya belanja untuk #work bulan ini?"

**Tech:**
- Model: tag list pada TransactionModel
- UI: Tag picker di form transaksi
- Filter: multi-select tags

---

## 10. 🎨 Theme Customizer & Widgets

**Mengapa berbeda:** Personalisasi yang lebih dalam dari sekadar dark/light mode.

**Deskripsi:**
- Pilih warna tema sendiri (bukan hanya blue)
- Widget home screen (Android & iOS) untuk quick add
- Widget saldo di notification bar
- Custom icon kategori

**Tech:**
- Flutter dynamic theming (ThemeData customization)
- Home screen widget: `home_widget` package
- Settings: color picker untuk theme

---

## 📝 Checklist Implementasi

- [ ] **Fase 1:** Wallet Multi-Akun (#2)
- [ ] **Fase 2:** AI Financial Advisor (#1)
- [ ] **Fase 3:** Receipt Scanner v2 (#3)
- [ ] **Fase 4:** Savings Challenge (#4)
- [ ] **Fase 5:** Predictive Analytics (#5)
- [ ] **Fase 6:** Debt Tracker (#8)
- [ ] **Fase 7:** Smart Tags (#9)
- [ ] **Fase 8:** Bill Split / Shared Finance (#6)
- [ ] **Fase 9:** Multi-Currency (#7)
- [ ] **Fase 10:** Theme Customizer & Widgets (#10)

---

## 💡 Tips Implementasi

1. **Mulai dari yang paling sering dipakai** — Wallet dan tag adalah fitur yang langsung terasa manfaatnya.
2. **Manfaatkan infra yang sudah ada** — Google Drive sync, Gemini API, Hive database.
3. **Incremental delivery** — Rilis fitur satu per satu, jangan sekaligus.
4. **User feedback loop** — Setelah setiap fase, minta feedback dari user.
5. **Test coverage** — Pastikan setiap fitur baru punya unit test.

---

> **Catatan:** Semua fitur di atas dirancang untuk menjaga MoniMate tetap **offline-first** dan **privacy-focused** sebagai DNA utama aplikasi.

*Last updated: 15 June 2026*
