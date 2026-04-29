import 'package:flutter/material.dart';

/// Widget reusable untuk menampilkan icon kategori transaksi.
///
/// Gunakan widget ini di mana saja yang sebelumnya menggunakan emoji string.
/// Contoh:
/// ```dart
/// CategoryIcon(category: 'makan')
/// CategoryIcon(category: 'gaji', size: 28, backgroundColor: Colors.green)
/// CategoryIcon.circle(category: 'transport', radius: 24)
/// ```
class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double? containerSize;
  final double borderRadius;
  final BoxBorder? border;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 22,
    this.color,
    this.backgroundColor,
    this.containerSize,
    this.borderRadius = 14,
    this.border,
  });

  /// Factory untuk membuat CategoryIcon dalam bentuk lingkaran (CircleAvatar style).
  factory CategoryIcon.circle({
    Key? key,
    required String category,
    double radius = 24,
    double iconSize = 22,
    Color? color,
    Color? backgroundColor,
    BoxBorder? border,
  }) {
    return CategoryIcon(
      key: key,
      category: category,
      size: iconSize,
      color: color,
      backgroundColor: backgroundColor,
      containerSize: radius * 2,
      borderRadius: radius,
      border: border,
    );
  }

  // ── Keyword mapping untuk auto-generate icon dari nama kategori ──
  static const Map<String, IconData> _keywordIcons = {
    // Makanan & Minuman
    'makan': Icons.restaurant_rounded,
    'makanan': Icons.restaurant_rounded,
    'food': Icons.restaurant_rounded,
    'sarapan': Icons.free_breakfast_rounded,
    'breakfast': Icons.free_breakfast_rounded,
    'makan siang': Icons.lunch_dining_rounded,
    'lunch': Icons.lunch_dining_rounded,
    'makan malam': Icons.dinner_dining_rounded,
    'dinner': Icons.dinner_dining_rounded,
    'snack': Icons.bakery_dining_rounded,
    'jajanan': Icons.bakery_dining_rounded,
    'kue': Icons.cake_rounded,
    'kopi': Icons.coffee_rounded,
    'minum': Icons.local_cafe_rounded,
    'minuman': Icons.local_cafe_rounded,
    'drink': Icons.local_cafe_rounded,

    // Transportasi
    'transport': Icons.directions_car_rounded,
    'transportasi': Icons.directions_car_rounded,
    'mobil': Icons.directions_car_rounded,
    'motor': Icons.two_wheeler_rounded,
    'ojek': Icons.two_wheeler_rounded,
    'ojol': Icons.two_wheeler_rounded,
    'grab': Icons.two_wheeler_rounded,
    'gojek': Icons.two_wheeler_rounded,
    'taxi': Icons.local_taxi_rounded,
    'taksi': Icons.local_taxi_rounded,
    'bus': Icons.directions_bus_rounded,
    'kereta': Icons.train_rounded,
    'krl': Icons.train_rounded,
    'mrt': Icons.subway_rounded,
    'pesawat': Icons.flight_rounded,
    'bensin': Icons.local_gas_station_rounded,
    'bbm': Icons.local_gas_station_rounded,
    'parkir': Icons.local_parking_rounded,
    'tol': Icons.toll_rounded,

    // Rumah & Tempat Tinggal
    'kos': Icons.house_rounded,
    'kost': Icons.house_rounded,
    'kontrakan': Icons.house_rounded,
    'sewa': Icons.house_rounded,
    'rumah': Icons.home_rounded,
    'apartemen': Icons.apartment_rounded,
    'listrik': Icons.bolt_rounded,
    'air': Icons.water_drop_rounded,
    'pdam': Icons.water_drop_rounded,
    'gas': Icons.propane_tank_rounded,

    // Komunikasi & Internet
    'internet': Icons.wifi_rounded,
    'wifi': Icons.wifi_rounded,
    'pulsa': Icons.phone_android_rounded,
    'telepon': Icons.phone_rounded,
    'telpon': Icons.phone_rounded,
    'hp': Icons.smartphone_rounded,
    'paket data': Icons.signal_cellular_alt_rounded,
    'kuota': Icons.signal_cellular_alt_rounded,

    // Kesehatan
    'kesehatan': Icons.medical_services_rounded,
    'obat': Icons.medication_rounded,
    'dokter': Icons.local_hospital_rounded,
    'rumah sakit': Icons.local_hospital_rounded,
    'rs': Icons.local_hospital_rounded,
    'klinik': Icons.local_hospital_rounded,
    'asuransi': Icons.health_and_safety_rounded,
    'bpjs': Icons.health_and_safety_rounded,
    'gym': Icons.fitness_center_rounded,
    'olahraga': Icons.fitness_center_rounded,
    'fitness': Icons.fitness_center_rounded,

    // Pendidikan
    'pendidikan': Icons.school_rounded,
    'sekolah': Icons.school_rounded,
    'kuliah': Icons.school_rounded,
    'kursus': Icons.menu_book_rounded,
    'les': Icons.menu_book_rounded,
    'belajar': Icons.menu_book_rounded,
    'buku': Icons.book_rounded,
    'sertifikasi': Icons.workspace_premium_rounded,

    // Hiburan
    'hiburan': Icons.sports_esports_rounded,
    'game': Icons.sports_esports_rounded,
    'film': Icons.movie_rounded,
    'bioskop': Icons.movie_rounded,
    'netflix': Icons.smart_display_rounded,
    'spotify': Icons.headphones_rounded,
    'musik': Icons.music_note_rounded,
    'konser': Icons.stadium_rounded,
    'liburan': Icons.beach_access_rounded,
    'wisata': Icons.travel_explore_rounded,
    'hotel': Icons.hotel_rounded,
    'traveling': Icons.flight_takeoff_rounded,
    'foto': Icons.camera_alt_rounded,
    'streaming': Icons.smart_display_rounded,

    // Kerja & Penghasilan
    'gaji': Icons.work_rounded,
    'salary': Icons.work_rounded,
    'upah': Icons.work_rounded,
    'freelance': Icons.laptop_rounded,
    'proyek': Icons.assignment_rounded,
    'project': Icons.assignment_rounded,
    'bisnis': Icons.business_center_rounded,
    'usaha': Icons.storefront_rounded,
    'toko': Icons.storefront_rounded,
    'jualan': Icons.storefront_rounded,

    // Belanja
    'belanja': Icons.shopping_bag_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'baju': Icons.checkroom_rounded,
    'pakaian': Icons.checkroom_rounded,
    'fashion': Icons.checkroom_rounded,
    'sepatu': Icons.ice_skating_rounded,
    'elektronik': Icons.devices_rounded,
    'gadget': Icons.devices_rounded,
    'perabotan': Icons.chair_rounded,
    'furniture': Icons.chair_rounded,

    // Keuangan
    'tagihan': Icons.receipt_long_rounded,
    'cicilan': Icons.credit_card_rounded,
    'kredit': Icons.credit_card_rounded,
    'utang': Icons.money_off_rounded,
    'hutang': Icons.money_off_rounded,
    'pinjaman': Icons.account_balance_rounded,
    'tabungan': Icons.savings_rounded,
    'deposito': Icons.savings_rounded,
    'investasi': Icons.trending_up_rounded,
    'saham': Icons.candlestick_chart_rounded,
    'crypto': Icons.currency_bitcoin_rounded,
    'bonus': Icons.card_giftcard_rounded,
    'hadiah': Icons.redeem_rounded,
    'pajak': Icons.account_balance_rounded,
    'zakat': Icons.volunteer_activism_rounded,
    'sedekah': Icons.volunteer_activism_rounded,
    'donasi': Icons.volunteer_activism_rounded,
    'infaq': Icons.volunteer_activism_rounded,

    // Perawatan & Kecantikan
    'salon': Icons.content_cut_rounded,
    'barbershop': Icons.content_cut_rounded,
    'potong rambut': Icons.content_cut_rounded,
    'skincare': Icons.face_retouching_natural_rounded,
    'kecantikan': Icons.face_retouching_natural_rounded,
    'laundry': Icons.local_laundry_service_rounded,
    'cuci': Icons.local_laundry_service_rounded,

    // Hewan
    'hewan': Icons.pets_rounded,
    'kucing': Icons.pets_rounded,
    'anjing': Icons.pets_rounded,
    'pet': Icons.pets_rounded,

    // Keagamaan
    'ibadah': Icons.mosque_rounded,
    'umroh': Icons.mosque_rounded,
    'haji': Icons.mosque_rounded,
    'qurban': Icons.mosque_rounded,

    // Anak & Keluarga
    'anak': Icons.child_care_rounded,
    'bayi': Icons.child_friendly_rounded,
    'keluarga': Icons.family_restroom_rounded,
    'susu': Icons.local_drink_rounded,
    'popok': Icons.child_friendly_rounded,

    // Default/Lainnya
    'lainnya': Icons.category_rounded,
    'lainnya_masuk': Icons.category_rounded,
  };

  // ── Keyword mapping untuk auto-generate warna ──
  static const Map<String, Color> _keywordColors = {
    // Makanan (warm orange/amber)
    'makan': Color(0xFF6F86D6),
    'makanan': Color(0xFF6F86D6),
    'food': Color(0xFF6F86D6),
    'sarapan': Color(0xFFF59E0B),
    'lunch': Color(0xFFF59E0B),
    'dinner': Color(0xFFF59E0B),
    'snack': Color(0xFFFF8A65),
    'jajanan': Color(0xFFFF8A65),
    'kue': Color(0xFFFF8A65),
    'kopi': Color(0xFF795548),
    'minum': Color(0xFF654444),
    'minuman': Color(0xFF654444),

    // Transport (blue/teal)
    'transport': Color(0xFF48C6EF),
    'transportasi': Color(0xFF48C6EF),
    'mobil': Color(0xFF48C6EF),
    'motor': Color(0xFF26A69A),
    'ojek': Color(0xFF26A69A),
    'bensin': Color(0xFF78909C),
    'parkir': Color(0xFF78909C),

    // Rumah (indigo)
    'kos': Color(0xFF5C6BC0),
    'kost': Color(0xFF5C6BC0),
    'rumah': Color(0xFF5C6BC0),
    'sewa': Color(0xFF5C6BC0),
    'listrik': Color(0xFFFFA726),
    'air': Color(0xFF29B6F6),

    // Internet (purple)
    'internet': Color(0xFF7C4DFF),
    'wifi': Color(0xFF7C4DFF),
    'pulsa': Color(0xFF7C4DFF),

    // Kesehatan (pink/red)
    'kesehatan': Color(0xFFFB7185),
    'obat': Color(0xFFFB7185),
    'dokter': Color(0xFFEF5350),
    'asuransi': Color(0xFF42A5F5),
    'gym': Color(0xFF66BB6A),
    'olahraga': Color(0xFF66BB6A),

    // Pendidikan (purple)
    'pendidikan': Color(0xFF8B5CF6),
    'sekolah': Color(0xFF8B5CF6),
    'kuliah': Color(0xFF8B5CF6),
    'buku': Color(0xFF8B5CF6),

    // Hiburan (green)
    'hiburan': Color(0xFF22C55E),
    'game': Color(0xFF22C55E),
    'film': Color(0xFFAB47BC),
    'netflix': Color(0xFFE53935),
    'spotify': Color(0xFF1DB954),
    'liburan': Color(0xFF26C6DA),
    'wisata': Color(0xFF26C6DA),

    // Kerja (amber)
    'gaji': Color(0xFFF59E0B),
    'freelance': Color(0xFF8B5CF6),
    'bisnis': Color(0xFF0288D1),

    // Belanja (pink)
    'belanja': Color(0xFFE879F9),
    'shopping': Color(0xFFE879F9),
    'baju': Color(0xFFE879F9),
    'elektronik': Color(0xFF546E7A),

    // Keuangan (green/blue)
    'tagihan': Color(0xFFFFA500),
    'cicilan': Color(0xFFEF5350),
    'kredit': Color(0xFFEF5350),
    'tabungan': Color(0xFF4CAF50),
    'investasi': Color(0xFF10B981),
    'saham': Color(0xFF10B981),
    'bonus': Color(0xFFEC4899),
    'hadiah': Color(0xFFEC4899),
    'donasi': Color(0xFF26A69A),
    'zakat': Color(0xFF26A69A),
    'pajak': Color(0xFF78909C),

    // Perawatan
    'salon': Color(0xFFEC407A),
    'laundry': Color(0xFF42A5F5),

    // Hewan
    'hewan': Color(0xFF8D6E63),
    'kucing': Color(0xFF8D6E63),

    // Keagamaan
    'ibadah': Color(0xFF26A69A),
    'umroh': Color(0xFF26A69A),

    // Anak
    'anak': Color(0xFFFFB74D),
    'bayi': Color(0xFFFFB74D),
    'keluarga': Color(0xFF66BB6A),
  };

  /// Auto-generate icon berdasarkan nama kategori menggunakan keyword matching.
  /// Cocok untuk kategori custom yang dibuat user.
  static IconData autoIcon(String name) {
    final lower = name.toLowerCase().trim();

    // 1. Exact match dulu
    if (_keywordIcons.containsKey(lower)) {
      return _keywordIcons[lower]!;
    }

    // 2. Contains match — cari keyword terpanjang dulu supaya lebih spesifik
    final sortedKeys = _keywordIcons.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final keyword in sortedKeys) {
      if (lower.contains(keyword)) {
        return _keywordIcons[keyword]!;
      }
    }

    // 3. Fallback
    return Icons.widgets_rounded;
  }

  /// Auto-generate warna berdasarkan nama kategori menggunakan keyword matching.
  static Color autoColor(String name) {
    final lower = name.toLowerCase().trim();

    // 1. Exact match
    if (_keywordColors.containsKey(lower)) {
      return _keywordColors[lower]!;
    }

    // 2. Contains match
    final sortedKeys = _keywordColors.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final keyword in sortedKeys) {
      if (lower.contains(keyword)) {
        return _keywordColors[keyword]!;
      }
    }

    // 3. Hash-based fallback
    final hash = lower.codeUnits.fold(0, (prev, element) => prev + element);
    return Colors.primaries[hash % Colors.primaries.length];
  }

  /// Mengembalikan IconData berdasarkan key kategori.
  /// Untuk kategori default gunakan exact match, untuk custom gunakan autoIcon.
  static IconData getIcon(String key) {
    switch (key.toLowerCase()) {
      case 'makan':
        return Icons.restaurant_rounded;
      case 'minum':
        return Icons.local_cafe_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'hiburan':
        return Icons.sports_esports_rounded;
      case 'gaji':
        return Icons.work_rounded;
      case 'belanja':
        return Icons.shopping_bag_rounded;
      case 'kesehatan':
        return Icons.medical_services_rounded;
      case 'pendidikan':
        return Icons.school_rounded;
      case 'tagihan':
        return Icons.receipt_long_rounded;
      case 'bonus':
        return Icons.card_giftcard_rounded;
      case 'investasi':
        return Icons.trending_up_rounded;
      case 'freelance':
        return Icons.laptop_rounded;
      case 'hadiah':
        return Icons.redeem_rounded;
      case 'lainnya':
      case 'lainnya_masuk':
        return Icons.category_rounded;
      default:
        // Untuk kategori custom, coba auto-match
        return autoIcon(key);
    }
  }

  /// Mengembalikan warna berdasarkan key kategori.
  static Color getColor(String key) {
    switch (key.toLowerCase()) {
      case 'makan':
        return const Color(0xFF6F86D6);
      case 'minum':
        return const Color(0xFF654444);
      case 'transport':
        return const Color(0xFF48C6EF);
      case 'hiburan':
        return const Color(0xFF22C55E);
      case 'gaji':
        return const Color(0xFFF59E0B);
      case 'belanja':
        return const Color(0xFFE879F9);
      case 'kesehatan':
        return const Color(0xFFFB7185);
      case 'pendidikan':
        return const Color(0xFF8B5CF6);
      case 'tagihan':
        return const Color(0xFFFFA500);
      case 'bonus':
        return const Color(0xFFEC4899);
      case 'investasi':
        return const Color(0xFF10B981);
      case 'freelance':
        return const Color(0xFF8B5CF6);
      case 'hadiah':
        return const Color(0xFFEC4899);
      default:
        // Untuk kategori custom, coba auto-match
        return autoColor(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = getIcon(category);
    final catColor = color ?? getColor(category);
    final bgColor = backgroundColor ?? catColor.withOpacity(0.15);
    final cSize = containerSize ?? (size * 2.2);

    return Container(
      width: cSize,
      height: cSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData,
        size: size,
        color: catColor,
      ),
    );
  }
}
