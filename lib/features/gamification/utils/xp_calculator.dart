class XpCalculator {
  // Menghitung total XP yang dibutuhkan untuk mencapai level tertentu
  static int getXpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    if (level == 2) return 100;
    if (level == 3) return 250;
    if (level == 4) return 500;
    if (level == 5) return 1000;
    
    // Formula untuk level > 5
    return 100 * (level * level);
  }

  // Menghitung level saat ini berdasarkan total XP
  static int calculateLevel(int totalXp) {
    int level = 1;
    while (totalXp >= getXpRequiredForLevel(level + 1)) {
      level++;
    }
    return level;
  }

  // Menghitung persentase progress menuju level berikutnya
  static double calculateProgressPercent(int totalXp) {
    int currentLevel = calculateLevel(totalXp);
    int currentLevelXp = getXpRequiredForLevel(currentLevel);
    int nextLevelXp = getXpRequiredForLevel(currentLevel + 1);
    
    int xpEarnedInThisLevel = totalXp - currentLevelXp;
    int xpNeededForNextLevel = nextLevelXp - currentLevelXp;
    
    if (xpNeededForNextLevel == 0) return 1.0;
    return xpEarnedInThisLevel / xpNeededForNextLevel;
  }

  // Menentukan Rank berdasarkan level
  static String getRank(int level) {
    if (level >= 1 && level <= 4) return 'Financial Starter';
    if (level >= 5 && level <= 9) return 'Budget Keeper';
    if (level >= 10 && level <= 14) return 'Smart Planner';
    if (level >= 15 && level <= 19) return 'Goal Hunter';
    if (level >= 20 && level <= 29) return 'Wealth Builder';
    if (level >= 30 && level <= 39) return 'Financial Strategist';
    return 'Money Master'; // 40+
  }
}
