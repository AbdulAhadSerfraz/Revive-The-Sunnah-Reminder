import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';
import 'package:share_plus/share_plus.dart';

class SunnahCardMinimal extends StatelessWidget {
  final Sunnah sunnah;
  final bool isToday;
  final bool isCompleted;
  final VoidCallback? onCompleted;
  final VoidCallback? onIncomplete;
  final VoidCallback? onToggleFavorite; // New callback for favorite toggle

  const SunnahCardMinimal({
    super.key,
    required this.sunnah,
    this.isToday = false,
    this.isCompleted = false,
    this.onCompleted,
    this.onIncomplete,
    this.onToggleFavorite, // New parameter
  });

  // Method to share the Sunnah
  void _shareSunnah(BuildContext context) async {
    final String shareText = '''
🌿 ${sunnah.title}

📖 Hadith:
${sunnah.hadith}

💎 Benefit:
${sunnah.benefit}

📚 Source: ${sunnah.source}

#ReviveSunnah #IslamicKnowledge
    ''';

    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isToday
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF388E3C),
                ],
              )
            : null,
        color: isToday ? null : Theme.of(context).cardTheme.color,
        border: Border.all(
          color: isToday ? const Color(0xFF2E7D32) : Colors.grey.withAlpha(31),
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isToday
                ? const Color(0xFF2E7D32).withAlpha(51)
                : Colors.black.withAlpha(10),
            blurRadius: isToday ? 16 : 12,
            offset: Offset(0, isToday ? 6 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simplified Header with category and completion status
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.white.withAlpha(51)
                        : const Color(0xFF2E7D32).withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(sunnah.category),
                        size: 14,
                        color: isToday ? Colors.white : const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sunnah.category,
                        style: TextStyle(
                          color:
                              isToday ? Colors.white : const Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Share button for today's Sunnah
                if (isToday)
                  GestureDetector(
                    onTap: () => _shareSunnah(context),
                    child: Container(
                      padding: const EdgeInsets.all(6), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius:
                            BorderRadius.circular(16), // Reduced radius
                        border: Border.all(
                          color: Colors.white.withAlpha(153),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        size: 16, // Reduced icon size
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 6), // Reduced spacing
                // Favorite button for today's Sunnah
                if (isToday)
                  GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6), // Reduced padding
                      decoration: BoxDecoration(
                        color: sunnah.isFavorite
                            ? const Color(0xFF2E7D32)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(16), // Reduced radius
                        border: Border.all(
                          color: sunnah.isFavorite
                              ? const Color(0xFF2E7D32)
                              : Colors.white.withAlpha(153),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        sunnah.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16, // Reduced icon size
                        color: sunnah.isFavorite
                            ? Colors.white
                            : Colors.white.withAlpha(204),
                      ),
                    ),
                  ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6), // Reduced padding
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.white.withAlpha(51)
                          : Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(16), // Reduced radius
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.schedule_rounded,
                          size: 14, // Reduced icon size
                          color: isCompleted
                              ? Colors.white
                              : Colors.white.withAlpha(204),
                        ),
                        const SizedBox(width: 4), // Reduced spacing
                        Text(
                          isCompleted ? 'Completed' : 'Pending',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.white
                                : Colors.white.withAlpha(204),
                            fontSize: 11, // Reduced font size
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Enhanced Title
            Text(
              sunnah.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isToday
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),

            const SizedBox(height: 16),

            // Simplified Hadith Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withAlpha(25)
                    : const Color(0xFF2E7D32).withAlpha(13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hadith',
                    style: TextStyle(
                      color: isToday
                          ? Colors.white.withAlpha(230)
                          : const Color(0xFF2E7D32),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sunnah.hadith,
                    style: TextStyle(
                      color: isToday
                          ? Colors.white.withAlpha(230)
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Simplified Benefit Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withAlpha(25)
                    : Colors.amber.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Benefit',
                    style: TextStyle(
                      color: isToday
                          ? Colors.white.withAlpha(230)
                          : Colors.amber[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sunnah.benefit,
                    style: TextStyle(
                      color: isToday
                          ? Colors.white.withAlpha(230)
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Simplified Source Section
            Row(
              children: [
                Icon(
                  Icons.source_rounded,
                  size: 16,
                  color:
                      isToday ? Colors.white.withAlpha(179) : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Source: ${sunnah.source}',
                    style: TextStyle(
                      color: isToday
                          ? Colors.white.withAlpha(179)
                          : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            // Simplified Action Buttons (only for today's Sunnah)
            if (isToday) ...[
              Column(
                children: [
                  const SizedBox(height: 24),
                  if (!isCompleted)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFF8F9FA)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onCompleted,
                          borderRadius: BorderRadius.circular(16),
                          splashColor: const Color(0xFF2E7D32).withAlpha(25),
                          highlightColor: const Color(0xFF2E7D32).withAlpha(13),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 24,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: const Color(0xFF2E7D32),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Mark as Complete',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2E7D32),
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onIncomplete,
                          borderRadius: BorderRadius.circular(16),
                          splashColor: Colors.white.withAlpha(25),
                          highlightColor: Colors.white.withAlpha(13),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 24,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Completed',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'prayer':
        return Icons.mosque_rounded;
      case 'eating':
        return Icons.restaurant_rounded;
      case 'sleeping':
        return Icons.bedtime_rounded;
      case 'cleanliness':
        return Icons.clean_hands_rounded;
      case 'charity':
        return Icons.volunteer_activism_rounded;
      case 'social':
        return Icons.people_rounded;
      case 'manners':
        return Icons.emoji_people_rounded;
      case 'knowledge':
        return Icons.school_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}
