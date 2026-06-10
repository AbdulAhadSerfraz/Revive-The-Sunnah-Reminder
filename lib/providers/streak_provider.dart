import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreakProvider extends ChangeNotifier {
  int _currentStreak = 0;
  int _longestStreak = 0;
  int _totalCompleted = 0;
  int _totalHadithsRead = 0; // Track total hadiths completed (not just viewed)
  Map<String, bool> _completedDates = {};
  bool _todayCompleted = false;

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get totalCompleted => _totalCompleted;
  int get totalHadithsRead => _totalHadithsRead; // Getter for completed hadiths
  bool get todayCompleted => _todayCompleted;

  Future<void> loadStreakData() async {
    final prefs = await SharedPreferences.getInstance();

    _currentStreak = prefs.getInt('current_streak') ?? 0;
    _longestStreak = prefs.getInt('longest_streak') ?? 0;
    _totalCompleted = prefs.getInt('total_completed') ?? 0;
    _totalHadithsRead =
        prefs.getInt('total_hadiths_read') ?? 0; // Load total hadiths completed

    final completedDatesList = prefs.getStringList('completed_dates') ?? [];
    _completedDates = {};
    for (final date in completedDatesList) {
      _completedDates[date] = true;
    }

    _checkTodayCompletion();
    notifyListeners();
  }

  void _checkTodayCompletion() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    _todayCompleted = _completedDates[today] ?? false;
  }

  Future<void> markTodayCompleted() async {
    if (_todayCompleted) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    _todayCompleted = true;
    _completedDates[today] = true;
    _totalCompleted++;

    // Check if yesterday was completed to maintain streak
    if (_completedDates[yesterday] == true) {
      _currentStreak++;
    } else {
      _currentStreak = 1;
    }

    // Update longest streak
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }

    await _saveStreakData();
    notifyListeners();
  }

  // Method to track hadiths completed (called when user marks hadith as complete)
  Future<void> markHadithAsCompleted() async {
    _totalHadithsRead++;
    await _saveStreakData();
    notifyListeners();
  }

  Future<void> markTodayIncomplete() async {
    if (!_todayCompleted) return;

    final today = DateTime.now().toIso8601String().split('T')[0];

    _todayCompleted = false;
    _completedDates.remove(today);
    _totalCompleted--;

    // Recalculate streak
    await _recalculateStreak();
    await _saveStreakData();
    notifyListeners();
  }

  Future<void> _recalculateStreak() async {
    _currentStreak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final date =
          today.subtract(Duration(days: i)).toIso8601String().split('T')[0];
      if (_completedDates[date] == true) {
        _currentStreak++;
      } else {
        break;
      }
    }
  }

  Future<void> _saveStreakData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('current_streak', _currentStreak);
    await prefs.setInt('longest_streak', _longestStreak);
    await prefs.setInt('total_completed', _totalCompleted);
    await prefs.setInt('total_hadiths_read',
        _totalHadithsRead); // Save total hadiths completed

    final completedDatesList = _completedDates.keys.toList();
    await prefs.setStringList('completed_dates', completedDatesList);
  }

  bool isDateCompleted(String date) {
    return _completedDates[date] ?? false;
  }

  List<String> getCompletedDates() {
    return _completedDates.keys.toList();
  }

  int getCompletionRate() {
    if (_totalCompleted == 0) return 0;

    final daysSinceFirstCompletion = _getDaysSinceFirstCompletion();
    if (daysSinceFirstCompletion == 0) return 0;

    return ((_totalCompleted / daysSinceFirstCompletion) * 100).round();
  }

  int _getDaysSinceFirstCompletion() {
    if (_completedDates.isEmpty) return 0;

    final dates = _completedDates.keys.toList();
    dates.sort();
    final firstDate = DateTime.parse(dates.first);
    final today = DateTime.now();

    return today.difference(firstDate).inDays + 1;
  }

  void resetStreak() async {
    _currentStreak = 0;
    _longestStreak = 0;
    _totalCompleted = 0;
    _totalHadithsRead = 0; // Reset total hadiths completed
    _completedDates.clear();
    _todayCompleted = false;

    await _saveStreakData();
    notifyListeners();
  }
}
