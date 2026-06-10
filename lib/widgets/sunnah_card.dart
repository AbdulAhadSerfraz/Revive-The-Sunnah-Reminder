import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';
import 'package:share_plus/share_plus.dart';

class SunnahCard extends StatelessWidget {
  final Sunnah sunnah;
  final bool isToday;
  final bool isCompleted;
  final VoidCallback? onCompleted;
  final VoidCallback? onIncomplete;
  final VoidCallback? onToggleFavorite; // New callback for favorite toggle

  const SunnahCard({
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
    // Share as text
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
          color: isToday
              ? const Color(0xFF2E7D32)
              : Colors.grey.withValues(alpha: 0.12),
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isToday
                ? const Color(0xFF2E7D32).withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isToday ? 16 : 12,
            offset: Offset(0, isToday ? 6 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header with category and completion status
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.25)
                        : const Color(0xFF2E7D32).withValues(alpha: 0.1),
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
                // Share button
                GestureDetector(
                  onTap: () => _shareSunnah(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Colors.white.withValues(alpha: 0.2)
                          : const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isToday
                            ? Colors.white.withValues(alpha: 0.3)
                            : const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      size: 16,
                      color: isToday ? Colors.white : const Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Favorite button
                if (!isToday) // Only show favorite button for library cards, not today's card
                  GestureDetector(
                    onTap: onToggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: sunnah.isFavorite
                            ? const Color(0xFF2E7D32)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: sunnah.isFavorite
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        sunnah.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: sunnah.isFavorite
                            ? Colors.white
                            : const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                // Show completion status for all Sunnahs, not just today's
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isToday
                            ? Colors.white.withValues(alpha: 0.2)
                            : const Color(0xFF2E7D32).withValues(alpha: 0.2))
                        : (isToday
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (isCompleted) {
                        onIncomplete?.call();
                      } else {
                        onCompleted?.call();
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 14,
                          color: isCompleted
                              ? (isToday
                                  ? Colors.white
                                  : const Color(0xFF2E7D32))
                              : (isToday
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isCompleted ? 'Completed' : 'Incomplete',
                          style: TextStyle(
                            color: isCompleted
                                ? (isToday
                                    ? Colors.white
                                    : const Color(0xFF2E7D32))
                                : (isToday
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.grey),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16), // Consistent spacing

            // Enhanced Title
            Text(
              sunnah.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isToday
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),

            const SizedBox(height: 16), // Consistent spacing

            // Enhanced Hadith Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16), // Consistent padding
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFF2E7D32).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6), // Consistent padding
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.white.withValues(alpha: 0.2)
                              : const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(6), // Consistent radius
                        ),
                        child: Icon(
                          Icons.format_quote_rounded,
                          size: 16,
                          color: isToday
                              ? Colors.white.withValues(alpha: 0.9)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 8), // Consistent spacing
                      Text(
                        'Hadith',
                        style: TextStyle(
                          color: isToday
                              ? Colors.white.withValues(alpha: 0.9)
                              : const Color(0xFF2E7D32),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // Consistent spacing
                  Text(
                    sunnah.hadith,
                    style: TextStyle(
                      color: isToday
                          ? Colors.white.withValues(alpha: 0.9)
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16), // Consistent spacing

            // Enhanced Benefit Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16), // Consistent padding
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.amber.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6), // Consistent padding
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.white.withValues(alpha: 0.2)
                              : Colors.amber.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(6), // Consistent radius
                        ),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          size: 16,
                          color: isToday
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.amber[700],
                        ),
                      ),
                      const SizedBox(width: 8), // Consistent spacing
                      Text(
                        'Benefit',
                        style: TextStyle(
                          color: isToday
                              ? Colors.white.withValues(alpha: 0.9)
                              : Colors.amber[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // Consistent spacing
                  Text(
                    sunnah.benefit,
                    style: TextStyle(
                      color: isToday
                          ? Colors.white.withValues(alpha: 0.9)
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16), // Consistent spacing

            // Source Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isToday
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.source_rounded,
                    size: 16,
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Source: ${sunnah.source}',
                      style: TextStyle(
                        color: isToday
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Enhanced Action Buttons (only for today's Sunnah)
            if (isToday) ...[
              Column(
                children: [
                  const SizedBox(height: 24), // Consistent spacing
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (!isCompleted) ...[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.white, Color(0xFFF8F9FA)],
                                ),
                                borderRadius: BorderRadius.circular(
                                    16), // Consistent radius
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onCompleted,
                                  borderRadius: BorderRadius.circular(
                                      16), // Consistent radius
                                  splashColor: const Color(0xFF2E7D32)
                                      .withValues(alpha: 0.1),
                                  highlightColor: const Color(0xFF2E7D32)
                                      .withValues(alpha: 0.05),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16, // Consistent padding
                                      horizontal: 24, // Consistent padding
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2E7D32)
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                                8), // Consistent radius
                                          ),
                                          child: const Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFF2E7D32),
                                            size: 18,
                                          ),
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
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16, // Consistent padding
                                      horizontal: 24, // Consistent padding
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(
                                          16), // Consistent radius
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(
                                                8), // Consistent radius
                                          ),
                                          child: const Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
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
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                          16), // Consistent radius
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: onIncomplete,
                                        borderRadius: BorderRadius.circular(
                                            16), // Consistent radius
                                        splashColor:
                                            Colors.white.withValues(alpha: 0.2),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16, // Consistent padding
                                            horizontal:
                                                16, // Consistent padding
                                          ),
                                          child: const Icon(
                                            Icons.undo_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
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
