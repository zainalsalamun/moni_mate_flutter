import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monimate/features/gamification/controllers/gamification_controller.dart';
import 'package:monimate/features/gamification/models/achievement_model.dart';
import 'package:monimate/features/gamification/utils/xp_calculator.dart';

class GamificationPage extends StatelessWidget {
  const GamificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GamificationController controller = Get.find<GamificationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text('Financial Journey', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () {
              // TODO: Export / Share PNG
            },
          )
        ],
      ),
      body: Obx(() {
        final progress = controller.progress.value;
        final nextLevelXp = XpCalculator.getXpRequiredForLevel(progress.currentLevel + 1);
        final percent = XpCalculator.calculateProgressPercent(progress.totalXpEarned);
        final xpToNext = nextLevelXp - progress.totalXpEarned;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION 1 & 2: Profile Summary & Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0083B0).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Level ${progress.currentLevel}',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                progress.currentRank,
                                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${progress.totalXpEarned} XP',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 12,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '🌟 $xpToNext XP lagi menuju Level ${progress.currentLevel + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION 3: Current Streak & Longest Streak
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orange,
                      title: 'Current Streak',
                      value: '${progress.currentStreak} Hari',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.emoji_events,
                      iconColor: Colors.amber,
                      title: 'Longest Streak',
                      value: '${progress.longestStreak} Hari',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // SECTION 4: Achievements
              const Text(
                'Achievement Center',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              
              _buildAchievementCategory('🔥 Streak', controller.achievements.where((a) => a.category == 'streak').toList()),
              _buildAchievementCategory('🎯 Goals', controller.achievements.where((a) => a.category == 'goals').toList()),
              _buildAchievementCategory('💸 Budget', controller.achievements.where((a) => a.category == 'budget').toList()),
              _buildAchievementCategory('🛡️ Emergency Fund', controller.achievements.where((a) => a.category == 'emergency_fund').toList()),
              _buildAchievementCategory('📈 Net Worth', controller.achievements.where((a) => a.category == 'net_worth').toList()),
              _buildAchievementCategory('📊 Reports', controller.achievements.where((a) => a.category == 'reports').toList()),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard({required IconData icon, required Color iconColor, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildAchievementCategory(String title, List<AchievementModel> achievements) {
    if (achievements.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final ach = achievements[index];
            return _buildAchievementBadge(ach);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAchievementBadge(AchievementModel ach) {
    final bool isUnlocked = ach.status == 'unlocked' || ach.status == 'completed';
    final Color achColor = Color(int.parse(ach.colorHex.replaceFirst('#', '0xFF')));

    // Simple map for icons
    IconData getIcon(String name) {
      switch (name) {
        case 'local_fire_department': return Icons.local_fire_department;
        case 'whatshot': return Icons.whatshot;
        case 'hotel_class': return Icons.hotel_class;
        case 'military_tech': return Icons.military_tech;
        case 'flag': return Icons.flag;
        case 'emoji_events': return Icons.emoji_events;
        case 'diamond': return Icons.diamond;
        case 'account_balance_wallet': return Icons.account_balance_wallet;
        case 'verified': return Icons.verified;
        case 'health_and_safety': return Icons.health_and_safety;
        case 'security': return Icons.security;
        case 'trending_up': return Icons.trending_up;
        case 'show_chart': return Icons.show_chart;
        case 'star': return Icons.star;
        case 'stars': return Icons.stars;
        case 'monetization_on': return Icons.monetization_on;
        case 'picture_as_pdf': return Icons.picture_as_pdf;
        case 'library_books': return Icons.library_books;
        default: return Icons.stars;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnlocked ? achColor.withOpacity(0.3) : Colors.grey[200]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: isUnlocked ? achColor.withOpacity(0.1) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              getIcon(ach.icon),
              color: isUnlocked ? achColor : Colors.grey[400],
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ach.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isUnlocked ? Colors.black87 : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
