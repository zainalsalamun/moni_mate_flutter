import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/data/controller/transaction_controller.dart';
import 'package:monimate/data/services/hive_service.dart';
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

  /// Max chat history messages to keep for AI context
  static const int _maxHistoryForAI = 20;

  @override
  void onInit() {
    super.onInit();
    _loadChatHistory();
  }

  /// Load chat history from Hive local storage
  void _loadChatHistory() {
    try {
      final savedHistory = HiveService.getChatHistory();
      if (savedHistory.isNotEmpty) {
        // Reconstruct ChatMessage objects from saved data
        for (final msg in savedHistory) {
          messages.add(ChatMessage(
            text: msg['text'] ?? '',
            isUser: msg['isUser'] == 'true',
            timestamp:
                DateTime.tryParse(msg['timestamp'] ?? '') ?? DateTime.now(),
            action: msg['action'] != null && msg['action']!.isNotEmpty
                ? _parseAction(msg['action']!)
                : null,
          ));
        }
        debugPrint(
            "Loaded ${messages.length} chat messages from local storage");
      }
    } catch (e) {
      debugPrint("Error loading chat history: $e");
    }

    // Always ensure at least a welcome message
    if (messages.isEmpty) {
      messages.add(ChatMessage(
        text:
            'Halo! 👋 Aku MoniMate AI, asisten keuanganmu.\n\nKamu bisa:\n💰 Tambah pengeluaran/pemasukan\n📊 Tanya kondisi keuangan\n💡 Minta tips hemat\n\nCoba ketik: "Tambah pengeluaran makan 25000"',
        isUser: false,
      ));
    }
  }

  Map<String, dynamic> _parseAction(String actionJson) {
    try {
      if (actionJson.startsWith('{')) {
        final decoded = jsonDecode(actionJson);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
    } catch (_) {}
    return {};
  }

  /// Save chat history to Hive local storage
  Future<void> _saveChatHistory() async {
    try {
      final List<Map<String, String>> historyData = [];
      for (final msg in messages) {
        historyData.add({
          'text': msg.text,
          'isUser': msg.isUser.toString(),
          'timestamp': msg.timestamp.toIso8601String(),
          if (msg.action != null) 'action': jsonEncode(msg.action),
        });
      }
      await HiveService.saveChatHistory(historyData);
      debugPrint("Chat history saved: ${historyData.length} messages");
    } catch (e) {
      debugPrint("Error saving chat history: $e");
    }
  }

  /// Clear all chat history
  Future<void> clearChatHistory() async {
    messages.clear();
    await HiveService.clearChatHistory();
    // Re-add welcome message
    messages.add(ChatMessage(
      text:
          'Halo! 👋 Aku MoniMate AI, asisten keuanganmu.\n\nKamu bisa:\n💰 Tambah pengeluaran/pemasukan\n📊 Tanya kondisi keuangan\n💡 Minta tips hemat\n\nCoba ketik: "Tambah pengeluaran makan 25000"',
      isUser: false,
    ));
  }

  /// Build chat history for AI context (role/content format)
  List<Map<String, String>> _buildChatHistoryForAI() {
    final List<Map<String, String>> history = [];
    // Skip welcome message, take recent messages
    final startIdx = messages.length > _maxHistoryForAI
        ? messages.length - _maxHistoryForAI
        : 0;

    for (var i = startIdx; i < messages.length; i++) {
      final msg = messages[i];
      // Only include user and AI text messages, skip action cards
      history.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      });
    }
    return history;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(ChatMessage(text: text.trim(), isUser: true));
    textController.clear();
    isLoading.value = true;

    // Save after user message
    await _saveChatHistory();

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

      final chatHistory = _buildChatHistoryForAI();

      final response = await AiChatService.sendMessage(
        text,
        transactionSummary: recentTxs,
        totalIncome: txController.totalIncome.value,
        totalExpense: txController.totalExpense.value,
        chatHistory: chatHistory,
      );

      final String reply = response['reply'] ?? 'Maaf, aku tidak mengerti.';

      String? actionTypeRaw = response['action_type']?.toString() ??
          response['actionType']?.toString() ??
          response['actiontype']?.toString();

      final String? actionType =
          actionTypeRaw?.replaceAll('_', '').replaceAll(' ', '').toLowerCase();
      Map<String, dynamic>? action;
      if (response['action'] is Map) {
        action = Map<String, dynamic>.from(response['action']);
      } else if (response['action'] is String) {
        try {
          action = jsonDecode(response['action']);
        } catch (_) {}
      }

      // Execute action if present
      if (actionType == 'addtransaction' && action != null) {
        final String type = action['type'] ?? 'expense';
        final String category = action['category'] ?? 'lainnya';

        // Safely parse amount whether it's a string or number
        double amount = 0;
        final rawAmount = action['amount'];
        if (rawAmount is num) {
          amount = rawAmount.toDouble();
        } else if (rawAmount is String) {
          String cleanStr = rawAmount.replaceAll(RegExp(r'[^0-9.]'), '');
          // Fix for Indonesian formatting "25.000" where dot is thousand separator
          if (cleanStr.contains('.') && cleanStr.split('.').last.length == 3) {
            cleanStr = cleanStr.replaceAll('.', '');
          }
          amount = double.tryParse(cleanStr) ?? 0;
        }

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

      // Save after AI reply
      await _saveChatHistory();
    } catch (e, stackTrace) {
      debugPrint("--- AI CHAT CONTROLLER: ERROR ---");
      debugPrint("Error: $e");
      debugPrint("Stack Trace: $stackTrace");
      debugPrint("--------------------------------");
      messages.add(ChatMessage(
        text: 'Oops! Ada gangguan nih, coba lagi ya 😅',
        isUser: false,
      ));
      await _saveChatHistory();
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
