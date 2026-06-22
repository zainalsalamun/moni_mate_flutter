import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/utils/format_currency.dart';
import '../controllers/ai_chat_controller.dart';

class AiChatPage extends StatelessWidget {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AiChatController controller = Get.put(AiChatController());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.deepPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MoniMate AI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Asisten Keuangan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Chat messages
            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty) {
                  return const Center(
                    child: Text('Mulai percakapan dengan MoniMate AI!'),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.messages.length +
                      (controller.isLoading.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (controller.isLoading.value && index == 0) {
                      return _buildLoadingBubble(context);
                    }

                    final messageIndex = controller.messages.length -
                        1 -
                        (controller.isLoading.value ? index - 1 : index);
                    final message = controller.messages[messageIndex];
                    return _buildChatBubble(context, message);
                  },
                );
              }),
            ),

            // Quick suggestions (only show at beginning or after AI reply)
            _buildQuickSuggestions(context, controller),

            // Input area
            _buildInputArea(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, ChatMessage message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : isDark
                        ? const Color(0xFF2D3748)
                        : const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message.isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(6),
                  bottomRight: message.isUser
                      ? const Radius.circular(6)
                      : const Radius.circular(20),
                ),
                border: message.isUser
                    ? null
                    : Border.all(
                        color: isDark
                            ? const Color(0xFF4A5568).withOpacity(0.6)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI label
                  if (!message.isUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MoniMate AI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Message text
                  if (message.isUser)
                    Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    )
                  else
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),

                  // Transaction action card
                  if (message.action != null) ...[
                    const SizedBox(height: 8),
                    _buildActionCard(context, message.action!),
                  ],
                ],
              ),
            ),

            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 10,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action) {
    final type = action['type'] ?? 'expense';
    final category = action['category'] ?? '';
    final amount = (action['amount'] as num?)?.toDouble() ?? 0;
    final description = action['description'] ?? '';

    final isIncome = type == 'income';
    final color = isIncome ? Colors.green : Colors.redAccent;
    final icon =
        isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isIncome ? "Pemasukan" : "Pengeluaran"} · ${category.replaceAll('_', ' ')}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${CurrencyFormat.format(amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D3748)
              : const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF4A5568)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Berpikir...',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions(
      BuildContext context, AiChatController controller) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final suggestions = [
      {
        'icon': Icons.restaurant_rounded,
        'text': 'Tambah makan 25rb',
        'msg': 'Tambah pengeluaran makan 25000'
      },
      {
        'icon': Icons.directions_bus_rounded,
        'text': 'Tambah transport 15rb',
        'msg': 'Tambah pengeluaran transport 15000'
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'text': 'Cek saldo',
        'msg': 'Berapa total pengeluaranku?'
      },
      {
        'icon': Icons.trending_down_rounded,
        'text': 'Tips hemat',
        'msg': 'Beri tips hemat uang bulanan'
      },
      {
        'icon': Icons.shopping_bag_rounded,
        'text': 'Tambah belanja 100rb',
        'msg': 'Tambah pengeluaran belanja 100000'
      },
      {
        'icon': Icons.savings_rounded,
        'text': 'Tips nabung',
        'msg': 'Beri tips menabung'
      },
    ];

    // Only show suggestions when there are no messages besides welcome or last message is AI
    final shouldShow =
        controller.messages.length <= 1 || (!controller.messages.last.isUser);

    if (!shouldShow) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = suggestions[index];
          return ActionChip(
            avatar: Icon(s['icon'] as IconData, size: 16, color: primaryColor),
            label: Text(
              s['text'] as String,
              style: TextStyle(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: primaryColor.withOpacity(0.08),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () => controller.sendMessage(s['msg'] as String),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, AiChatController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: bottomPadding > 0 ? bottomPadding + 12 : 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A202C) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Quick action buttons
            IconButton(
              onPressed: () => _showAddTransactionOptions(context, controller),
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Contoh: Tambah pengeluaran',
            ),

            // Text input
            Expanded(
              child: TextField(
                controller: controller.textController,
                style: const TextStyle(fontSize: 14),
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    controller.sendMessage(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2D3748)
                      : const Color(0xFFF7FAFC),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF4A5568)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF4A5568)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Send button
            Obx(() {
              return IconButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        final text = controller.textController.text;
                        if (text.trim().isNotEmpty) {
                          controller.sendMessage(text);
                        }
                      },
                icon: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: controller.textController.text.isEmpty
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3)
                            : Theme.of(context).colorScheme.primary,
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionOptions(
      BuildContext context, AiChatController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saran Prompt Cepat',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih contoh ini agar AI langsung mencatat tanpa perlu mengetik',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.arrow_upward_rounded,
                      color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Text('Pengeluaran',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPromptChip(context, controller, 'Catat beli kopi 25rb'),
                  _buildPromptChip(
                      context, controller, 'Catat makan siang 50rb'),
                  _buildPromptChip(
                      context, controller, 'Catat isi bensin 50rb'),
                  _buildPromptChip(
                      context, controller, 'Catat bayar parkir 5rb'),
                  _buildPromptChip(
                      context, controller, 'Catat ongkos ojol 20rb'),
                  _buildPromptChip(
                      context, controller, 'Catat beli cemilan 15rb'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.arrow_downward_rounded,
                      color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text('Pemasukan',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPromptChip(context, controller, 'Catat gajian 5jt'),
                  _buildPromptChip(
                      context, controller, 'Catat dapat bonus 500rb'),
                  _buildPromptChip(
                      context, controller, 'Catat hasil freelance 1jt'),
                  _buildPromptChip(
                      context, controller, 'Catat dikasih uang 100rb'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptChip(
      BuildContext context, AiChatController controller, String prompt) {
    return ActionChip(
      label: Text(prompt, style: const TextStyle(fontSize: 13)),
      backgroundColor:
          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
      side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        Navigator.pop(context);
        controller.sendMessage(prompt);
      },
    );
  }
}
