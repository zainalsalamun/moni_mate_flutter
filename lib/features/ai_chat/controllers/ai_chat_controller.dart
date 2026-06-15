import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import '../services/ai_chat_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? action;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.action,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiChatController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Welcome message
    messages.add(ChatMessage(
      text:
          'Halo! 👋 Aku MoniMate AI, asisten keuanganmu.\n\nKamu bisa:\n💰 Tambah pengeluaran/pemasukan\n📊 Tanya kondisi keuangan\n💡 Minta tips hemat\n\nCoba ketik: "Tambah pengeluaran makan 25000"',
      isUser: false,
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(ChatMessage(text: text.trim(), isUser: true));
    textController.clear();
    isLoading.value = true;

    debugPrint("--- AI CHAT CONTROLLER: Processing message... ---");
    debugPrint("User input: '$text'");

    try {
      final txController = Get.find<TransactionController>();

      // Build transaction summary for AI context
      final recentTxs = txController.recentTransactions.take(10).map((tx) {
        return {
          'type': tx.type,
          'category': tx.category,
          'amount': tx.amount.toStringAsFixed(0),
          'description': tx.description,
          'date': tx.date.toIso8601String(),
        };
      }).toList();

      debugPrint("--- AI CHAT CONTROLLER: Sending to AI service... ---");
      debugPrint("Transaction summary count: ${recentTxs.length}");
      debugPrint(
          "Income: Rp ${txController.totalIncome.value.toStringAsFixed(0)}, Expense: Rp ${txController.totalExpense.value.toStringAsFixed(0)}");

      final response = await AiChatService.sendMessage(
        text,
        transactionSummary: recentTxs,
        totalIncome: txController.totalIncome.value,
        totalExpense: txController.totalExpense.value,
      );

      debugPrint("--- AI CHAT CONTROLLER: Response received ---");
      debugPrint("Reply: ${response['reply']}");
      debugPrint("Action type: ${response['action_type']}");

      final String reply = response['reply'] ?? 'Maaf, aku tidak mengerti.';
      final String? actionType = response['action_type'];
      final Map<String, dynamic>? action = response['action'];

      debugPrint("--- AI CHAT CONTROLLER: Processing action... ---");

      // Execute action if present
      if (actionType == 'add_transaction' && action != null) {
        final String type = action['type'] ?? 'expense';
        final String category = action['category'] ?? 'lainnya';
        final double amount = (action['amount'] as num?)?.toDouble() ?? 0;
        final String description = action['description'] ?? '';

        if (amount > 0) {
          txController.addTransaction(type, category, amount, description);

          messages.add(ChatMessage(
            text: reply,
            isUser: false,
            action: action,
          ));
        } else {
          messages.add(ChatMessage(
            text:
                '$reply\n\n⚠️ Tapi nominalnya 0 nih, coba sebut nominalnya ya!',
            isUser: false,
          ));
        }
      } else {
        messages.add(ChatMessage(
          text: reply,
          isUser: false,
          action: action,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint("--- AI CHAT CONTROLLER: ERROR ---");
      debugPrint("Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      debugPrint("--------------------------------");
      messages.add(ChatMessage(
        text: 'Oops! Ada gangguan nih, coba lagi ya 😅',
        isUser: false,
      ));
    } finally {
      debugPrint("--- AI CHAT CONTROLLER: Processing complete ---");
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
