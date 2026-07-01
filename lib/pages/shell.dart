import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'dashboard_page.dart';
import 'add_page.dart';
import 'activity_page.dart';
import 'insights_page.dart';
import 'profile_page.dart';
import '../features/ai_chat/views/ai_chat_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShellController extends GetxController {
  final RxInt index = 0.obs;
  final pendingScanResult = Rxn<Map<String, dynamic>>();
  void changeTab(int i) => index.value = i;
}

class DraggableAIButton extends StatefulWidget {
  final VoidCallback onPressed;
  const DraggableAIButton({super.key, required this.onPressed});

  @override
  State<DraggableAIButton> createState() => _DraggableAIButtonState();
}

class _DraggableAIButtonState extends State<DraggableAIButton> with TickerProviderStateMixin {
  late double posX;
  late double posY;
  bool _isDragging = false;
  bool _showTooltip = true;
  
  Timer? _periodicTimer;
  Timer? _hideTimer;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _eyeController;
  late Animation<double> _eyeAnimation;

  @override
  void initState() {
    super.initState();
    // Default position: bottom-right area
    posX = 0;
    posY = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        posX = size.width - 100; // Adjust for vertical layout with right margin
        posY = size.height - 250;
      });
    });

    // Floating animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Eye movement animation
    _eyeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();

    _eyeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30), // Center
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 2.5).chain(CurveTween(curve: Curves.easeInOut)), weight: 10), // Move right
      TweenSequenceItem(tween: ConstantTween(2.5), weight: 15), // Hold right
      TweenSequenceItem(tween: Tween(begin: 2.5, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 10), // Move center
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 10), // Center
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -2.5).chain(CurveTween(curve: Curves.easeInOut)), weight: 10), // Move left
      TweenSequenceItem(tween: ConstantTween(-2.5), weight: 5), // Hold left
      TweenSequenceItem(tween: Tween(begin: -2.5, end: 0.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 10), // Move center
    ]).animate(_eyeController);

    // Initial hide tooltip after 10 seconds
    _hideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _showTooltip = false);
    });

    // Periodic show tooltip every 45 seconds
    _periodicTimer = Timer.periodic(const Duration(seconds: 45), (timer) {
      if (mounted && !_isDragging) {
        setState(() => _showTooltip = true);
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(seconds: 10), () {
          if (mounted) setState(() => _showTooltip = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _periodicTimer?.cancel();
    _floatController.dispose();
    _eyeController.dispose();
    super.dispose();
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
            posX = posX.clamp(
                0.0, size.width - 90.0); // Allow dragging flush to the right
            posY = posY.clamp(0.0, size.height - bottomPadding - 140.0);
            _isDragging = true;
          });
        },
        onPanEnd: (_) {
          if (mounted) setState(() => _isDragging = false);
        },
        onPanCancel: () {
          if (mounted) setState(() => _isDragging = false);
        },
        onTap: () {
          if (!_isDragging) {
            if (_showTooltip) {
              setState(() => _showTooltip = false);
            }
            widget.onPressed();
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Tooltip Chat Bubble
            Positioned(
              right: 76, // 72 (button width) + 4 (spacing)
              child: AnimatedOpacity(
                opacity: _showTooltip && !_isDragging ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF2D3748) 
                        : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Hai! Butuh bantuan?',
                        style: TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _showTooltip = false),
                        child: Icon(
                          Icons.close_rounded, 
                          size: 14, 
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Main Button
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _isDragging ? 0 : _floatAnimation.value),
                  child: child,
                );
              },
              child: AnimatedScale(
                scale: _isDragging ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        _isDragging 
                            ? 'assets/images/ai_assistant/assistant_pressed.svg' 
                            : 'assets/images/ai_assistant/assistant_default.svg',
                        width: 72,
                        height: 72,
                      ),
                      // Animated Eyes Overlay
                      AnimatedBuilder(
                        animation: _eyeAnimation,
                        builder: (context, _) {
                          return Transform.translate(
                            offset: Offset(_eyeAnimation.value, 0),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 3.5), // Shift slightly up to match SVG face
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 4.5, 
                                    height: 4.5, 
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)
                                  ),
                                  const SizedBox(width: 4.5), // Gap between eyes
                                  Container(
                                    width: 4.5, 
                                    height: 4.5, 
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final ShellController shellC = Get.put(ShellController(), permanent: true);

  final pages = const [
    DashboardPage(),
    ActivityPage(),
    AddPage(),
    InsightsPage(),
    ProfilePage(),
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
                    _buildNavTab(1, Icons.receipt_long_rounded, 'Activity'),
                    _buildNavTab(2, Icons.add_circle_rounded, 'Add'),
                    _buildNavTab(3, Icons.bar_chart_rounded, 'Insights'),
                    _buildNavTab(4, Icons.person_rounded, 'Profile'),
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
