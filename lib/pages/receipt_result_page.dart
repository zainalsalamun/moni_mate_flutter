import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/utils/format_currency.dart';

class ReceiptResultPage extends StatelessWidget {
  final Map<String, dynamic> result;
  final String imagePath;

  const ReceiptResultPage({
    super.key,
    required this.result,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final merchant = result["merchant"] ?? "-";
    final tanggal = result["tanggal"] ?? "-";
    final rawTotal = result["total"];

    final amount =
        rawTotal != null ? double.tryParse(rawTotal.toString()) ?? 0 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EB),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Get.back(),
              ),
            ),
            const SizedBox(height: 8),
            _successIcon(),
            const SizedBox(height: 16),
            const Text("Struk Berhasil Dibaca",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              "Silakan cek detail di bawah ini.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: ListView(
                  children: [
                    _row("Merchant", merchant),
                    _row("Tanggal", tanggal),
                    _row("Total", CurrencyFormat.format(amount)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48C6EF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Get.until((route) => route.settings.name == "/add");

                        Get.back(result: {
                          "amount": amount,
                          "merchant": merchant,
                          "date": tanggal,
                          "rawText": result["raw"] ?? "",
                        });
                      },
                      child: const Text("Simpan ke MoniMate"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(val, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _successIcon() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_circle, size: 60, color: Colors.green),
    );
  }
}
