import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revive_sunnah_reminder/providers/streak_provider.dart';
import 'package:lottie/lottie.dart'; // Add this import for Lottie

class MinimalGreetingCard extends StatelessWidget {
  const MinimalGreetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32), // Primary green color
        borderRadius: BorderRadius.circular(16), // Reduced border radius
      ),
      child: Column(
        children: [
          // Main greeting section with Assalamu Alaikum and fire side by side
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left column: Assalamu Alaikum and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assalamu Alaikum',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                fontSize: 22, // Reduced font size
                              ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    Text(
                      'Complete Sunnah to light up the fire',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withAlpha(240),
                            fontWeight: FontWeight.w500, // Reduced weight
                            height: 1.4,
                            fontSize: 14, // Reduced font size
                          ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16), // Reduced spacing
              // Fire animation on the right (reduced size)
              Consumer<StreakProvider>(
                builder: (context, streakProvider, child) {
                  // Show fire animation only if user has a streak of 1 or more
                  if (streakProvider.currentStreak > 0) {
                    return Lottie.asset(
                      'assets/fire.json',
                      width: 80, // Reduced size
                      height: 80, // Reduced size
                      repeat: true,
                      fit: BoxFit.contain,
                    );
                  } else {
                    // Show grey fire animation with low opacity when no streak
                    return Opacity(
                      opacity: 0.4,
                      child: Lottie.asset(
                        'assets/animation/greyfire.json',
                        width: 80, // Reduced size
                        height: 80, // Reduced size
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced spacing
          // Streak information centered at the bottom
          Consumer<StreakProvider>(
            builder: (context, streakProvider, child) {
              // Only show streak info if user has completed at least one hadith
              if (streakProvider.totalCompleted > 0) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius:
                        BorderRadius.circular(12), // Reduced border radius
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 18, // Reduced icon size
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${streakProvider.currentStreak} Day Streak',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16, // Reduced font size
                                ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox
                  .shrink(); // Don't show anything if no progress
            },
          ),
        ],
      ),
    );
  }
}
