double cleanCurrency(String text) {
  // Hapus semua kecuali angka, titik, koma
  text = text.replaceAll(RegExp(r'[^0-9.,]'), '');

  // Ubah format IDR -> decimal
  // contoh: 56.200 -> 56200
  text = text.replaceAll('.', '').replaceAll(',', '.');

  return double.tryParse(text) ?? 0.0;
}
