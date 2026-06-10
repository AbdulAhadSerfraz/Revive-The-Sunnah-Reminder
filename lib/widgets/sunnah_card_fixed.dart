import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';

class SunnahCard extends StatelessWidget {
  final Sunnah sunnah;
  final bool isToday;
  final bool isCompleted;
  final VoidCallback? onCompleted;
  final VoidCallback? onIncomplete;

  const SunnahCard({
    super.key,
    required this.sunnah,
    this.isToday = false,
    this.isCompleted = false,
    this.onCompleted,
    this.onIncomplete,
  });

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
        padding: const EdgeInsets.all(20), // Consistent padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header with category and completion status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                gradient: isToday
                    ? LinearGradient(
                        colors: [
                          Colors.white.withAlpha(38),
                          Colors.white.withAlpha(13),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFF2E7D32).withAlpha(20),
                          const Color(0xFF2E7D32).withAlpha(8),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? Colors.white.withAlpha(51)
                      : const Color(0xFF2E7D32).withAlpha(25),
                  width: 1,
                ),
              ),
              child: Row(
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
                          color:
                              isToday ? Colors.white : const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sunnah.category,
                          style: TextStyle(
                            color: isToday
                                ? Colors.white
                                : const Color(0xFF2E7D32),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.white.withAlpha(51)
                            : Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                            size: 16,
                            color: isCompleted
                                ? Colors.white
                                : Colors.white.withAlpha(204),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompleted ? 'Completed' : 'Pending',
                            style: TextStyle(
                              color: isCompleted
                                  ? Colors.white
                                  : Colors.white.withAlpha(204),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
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
                    ? Colors.white.withAlpha(25)
                    : const Color(0xFF2E7D32).withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? Colors.white.withAlpha(51)
                      : const Color(0xFF2E7D32).withAlpha(25),
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
                              ? Colors.white.withAlpha(51)
                              : const Color(0xFF2E7D32).withAlpha(25),
                          borderRadius:
                              BorderRadius.circular(6), // Consistent radius
                        ),
                        child: Icon(
                          Icons.format_quote_rounded,
                          size: 16,
                          color: isToday
                              ? Colors.white.withAlpha(230)
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 8), // Consistent spacing
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
                    ],
                  ),
                  const SizedBox(height: 12), // Consistent spacing
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

            const SizedBox(height: 16), // Consistent spacing

            // Enhanced Benefit Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16), // Consistent padding
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withAlpha(25)
                    : Colors.amber.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? Colors.white.withAlpha(51)
                      : Colors.amber.withAlpha(51),
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
                              ? Colors.white.withAlpha(51)
                              : Colors.amber.withAlpha(51),
                          borderRadius:
                              BorderRadius.circular(6), // Consistent radius
                        ),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          size: 16,
                          color: isToday
                              ? Colors.white.withAlpha(230)
                              : Colors.amber[700],
                        ),
                      ),
                      const SizedBox(width: 8), // Consistent spacing
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
                    ],
                  ),
                  const SizedBox(height: 12), // Consistent spacing
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

            const SizedBox(height: 16), // Consistent spacing

            // Source Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withAlpha(20)
                    : Colors.grey.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isToday
                      ? Colors.white.withAlpha(38)
                      : Colors.grey.withAlpha(25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.source_rounded,
                    size: 16,
                    color: isToday
                        ? Colors.white.withAlpha(179)
                        : Colors.grey[600],
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
            ),

            // Enhanced Action Buttons (only for today's Sunnah)
            if (isToday) ...[
              Column(
                children: [
                  const SizedBox(height: 24), // Consistent spacing
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withAlpha(51),
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
                                    color: Colors.black.withAlpha(25),
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
                                  splashColor:
                                      const Color(0xFF2E7D32).withAlpha(25),
                                  highlightColor:
                                      const Color(0xFF2E7D32).withAlpha(13),
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
                                                .withAlpha(25),
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
                                      color: Colors.white.withAlpha(51),
                                      borderRadius: BorderRadius.circular(
                                          16), // Consistent radius
                                      border: Border.all(
                                        color: Colors.white.withAlpha(77),
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
                                            color: Colors.white.withAlpha(77),
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
                                      color: Colors.white.withAlpha(25),
                                      borderRadius: BorderRadius.circular(
                                          16), // Consistent radius
                                      border: Border.all(
                                        color: Colors.white.withAlpha(77),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: onIncomplete,
                                        borderRadius: BorderRadius.circular(
                                            16), // Consistent radius
                                        splashColor: Colors.white.withAlpha(51),
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
