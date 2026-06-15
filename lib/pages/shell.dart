import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_page.dart';
import 'transactions_page.dart';
import 'add_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';
import '../features/ai_chat/views/ai_chat_page.dart';

class ShellController extends GetxController {
  final RxInt index = 0.obs;
  void changeTab(int i) => index.value = i;
}

class DraggableAIButton extends StatefulWidget {
  final VoidCallback onPressed;
  const DraggableAIButton({super.key, required this.onPressed});

  @override
  State<DraggableAIButton> createState() => _DraggableAIButtonState();
}

class _DraggableAIButtonState extends State<DraggableAIButton> {
  late double posX;
  late double posY;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // Default position: bottom-right area
    posX = 0;
    posY = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        posX = size.width - 80;
        posY = size.height - 250;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Positioned(
      left: posX,
      top: posY,
      child: GestureDetector(
        onPanStart: (_) => _isDragging = false,
        onPanUpdate: (details) {
          setState(() {
            posX += details.delta.dx;
            posY += details.delta.dy;
            // Clamp within screen bounds
            final size = MediaQuery.of(context).size;
            posX = posX.clamp(0, size.width - 60);
            posY = posY.clamp(0, size.height - bottomPadding - 140);
            _isDragging = true;
          });
        },
        onTap: () {
          if (!_isDragging) {
            widget.onPressed();
          }
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final ShellController shellC = Get.put(ShellController(), permanent: true);

  final pages = const [
    DashboardPage(),
    TransactionsPage(),
    AddPage(),
    StatsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: KeyedSubtree(
                    child: pages[shellC.index.value],
                  ),
                )),
          ),
          DraggableAIButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AiChatPage(),
                ),
              );
            },
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Obx(() => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              left: 20,
              right: 20,
            ),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A202C).withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavTab(0, Icons.home_rounded, 'Home'),
                    _buildNavTab(1, Icons.receipt_long_rounded, 'Histori'),
                    _buildNavTab(2, Icons.add_circle_rounded, 'Tambah'),
                    _buildNavTab(3, Icons.bar_chart_rounded, 'Stat'),
                    _buildNavTab(4, Icons.settings_rounded, 'Setting'),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildNavTab(int index, IconData icon, String label) {
    final isSelected = shellC.index.value == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.4);

    return Expanded(
      child: GestureDetector(
        onTap: () => shellC.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
            if (isSelected)
              AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
