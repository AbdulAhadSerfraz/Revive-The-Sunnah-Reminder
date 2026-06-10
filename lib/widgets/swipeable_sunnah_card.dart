import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';
import 'package:revive_sunnah_reminder/widgets/adaptive_sunnah_card.dart';

class SwipeableSunnahCard extends StatelessWidget {
  final Sunnah sunnah;
  final bool isCompleted;
  final VoidCallback? onCompleted;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onToggleFavorite;

  const SwipeableSunnahCard({
    super.key,
    required this.sunnah,
    this.isCompleted = false,
    this.onCompleted,
    this.onSwipeLeft,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveSunnahCard(
      sunnah: sunnah,
      isCompleted: isCompleted,
      onCompleted: onCompleted,
      onToggleFavorite: onToggleFavorite,
    );
  }
}
