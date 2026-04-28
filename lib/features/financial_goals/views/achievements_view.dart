import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/goals_controller.dart';

class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final GoalsController controller = Get.find<GoalsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: Obx(() {
          final list = controller.achievementsList;
          final unlockedCount = list.where((a) => a.isUnlocked).length;
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[200]!)),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF0288D1).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Total Pencapaian', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text('$unlockedCount / ${list.length} Unlocked', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Daftar Achievement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final ach = list[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: ach.isUnlocked ? ach.color.withOpacity(0.3) : Colors.grey[200]!),
                                boxShadow: [
                                  if (ach.isUnlocked)
                                    BoxShadow(color: ach.color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: ach.isUnlocked ? ach.color.withOpacity(0.1) : Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(ach.icon, color: ach.isUnlocked ? ach.color : Colors.grey[400], size: 30),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(ach.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: ach.isUnlocked ? Colors.black87 : Colors.grey), textAlign: TextAlign.center),
                                  const SizedBox(height: 4),
                                  Text(ach.subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11), textAlign: TextAlign.center, maxLines: 2),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
