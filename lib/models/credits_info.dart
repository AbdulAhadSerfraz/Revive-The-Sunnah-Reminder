import 'package:flutter/material.dart';

class CreditsInfo {
  final int totalCredits;
  final int usedCredits;
  final DateTime lastReset;
  final DateTime nextReset;
  final int resetIntervalHours;

  CreditsInfo({
    required this.totalCredits,
    required this.usedCredits,
    required this.lastReset,
    required this.nextReset,
    this.resetIntervalHours = 24,
  });

  int get remainingCredits => totalCredits - usedCredits;
  bool get hasCredits => remainingCredits > 0;

  double get usagePercentage =>
      totalCredits > 0 ? usedCredits / totalCredits : 0.0;

  factory CreditsInfo.fromJson(Map<String, dynamic> json) {
    return CreditsInfo(
      totalCredits: json['totalCredits'] ?? 5,
      usedCredits: json['usedCredits'] ?? 0,
      lastReset: DateTime.parse(json['lastReset']),
      nextReset: DateTime.parse(json['nextReset']),
      resetIntervalHours: json['resetIntervalHours'] ?? 24,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCredits': totalCredits,
      'usedCredits': usedCredits,
      'lastReset': lastReset.toIso8601String(),
      'nextReset': nextReset.toIso8601String(),
      'resetIntervalHours': resetIntervalHours,
    };
  }

  CreditsInfo copyWith({
    int? totalCredits,
    int? usedCredits,
    DateTime? lastReset,
    DateTime? nextReset,
    int? resetIntervalHours,
  }) {
    return CreditsInfo(
      totalCredits: totalCredits ?? this.totalCredits,
      usedCredits: usedCredits ?? this.usedCredits,
      lastReset: lastReset ?? this.lastReset,
      nextReset: nextReset ?? this.nextReset,
      resetIntervalHours: resetIntervalHours ?? this.resetIntervalHours,
    );
  }

  /// Get time until next reset in a human-readable format
  String getTimeUntilReset() {
    final now = DateTime.now();
    final diff = nextReset.difference(now);

    if (diff.isNegative) {
      return 'Reset available';
    }

    if (diff.inDays > 0) {
      return '${diff.inDays}d ${diff.inHours % 24}h';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    } else {
      return '${diff.inMinutes}m';
    }
  }

  /// Get credits display text
  String getCreditsDisplayText() {
    return '$remainingCredits/$totalCredits';
  }

  /// Get color based on usage
  Color getCreditsColor() {
    if (usagePercentage >= 0.8) return const Color(0xFFD32F2F); // Red
    if (usagePercentage >= 0.6) return const Color(0xFFFF8F00); // Amber
    return const Color(0xFF2E7D32); // Green
  }

  /// Get status text
  String getStatusText() {
    if (!hasCredits) {
      return 'Daily limit reached';
    } else if (usagePercentage >= 0.8) {
      return 'Almost out of credits';
    } else if (usagePercentage >= 0.6) {
      return 'Running low';
    } else {
      return 'Credits available';
    }
  }

  /// Check if reset is needed
  bool get needsReset {
    return DateTime.now().isAfter(nextReset);
  }

  /// Create initial credits info
  factory CreditsInfo.createInitial({int totalCredits = 5}) {
    final now = DateTime.now();
    final nextReset = DateTime(now.year, now.month, now.day + 1);

    return CreditsInfo(
      totalCredits: totalCredits,
      usedCredits: 0,
      lastReset: now,
      nextReset: nextReset,
    );
  }

  /// Reset credits to full
  CreditsInfo resetCredits() {
    final now = DateTime.now();
    final nextReset = DateTime(now.year, now.month, now.day + 1);

    return copyWith(
      usedCredits: 0,
      lastReset: now,
      nextReset: nextReset,
    );
  }

  /// Consume a credit
  CreditsInfo consumeCredit() {
    if (!hasCredits) {
      throw Exception('No credits available');
    }

    return copyWith(usedCredits: usedCredits + 1);
  }

  /// Get progress value for UI (0.0 to 1.0)
  double get progressValue => usagePercentage;

  /// Get inverse progress for circular indicators (remaining)
  double get remainingProgressValue => 1.0 - usagePercentage;
}
