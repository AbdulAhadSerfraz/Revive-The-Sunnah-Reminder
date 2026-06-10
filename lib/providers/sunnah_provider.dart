import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';
import 'package:revive_sunnah_reminder/core/services/database_service.dart';
import 'package:revive_sunnah_reminder/core/services/storage_service.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';

class SunnahProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final StorageService _storageService;
  final LoggingService _logger;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  List<Sunnah> _allSunnahs = [];
  Sunnah? _todaySunnah;
  List<Sunnah> _swipeableSunnahs = []; // New: List for swipeable hadiths
  int _currentSwipeIndex = 0; // New: Track current index in swipeable list
  bool _isLoading = true;
  String? _error;
  Set<int> _favoriteSunnahIds = <int>{}; // Track favorite Sunnah IDs

  List<Sunnah> get allSunnahs => _allSunnahs;
  Sunnah? get todaySunnah => _todaySunnah;
  List<Sunnah> get swipeableSunnahs => _swipeableSunnahs; // New getter
  int get currentSwipeIndex => _currentSwipeIndex; // New getter
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<int> get favoriteSunnahIds => _favoriteSunnahIds;

  SunnahProvider({
    required DatabaseService databaseService,
    required StorageService storageService,
    required LoggingService loggingService,
  })  : _databaseService = databaseService,
        _storageService = storageService,
        _logger = loggingService {
    _initialize();
  }

  /// Initialize provider
  Future<void> _initialize() async {
    await loadSunnahs();
    await _loadFavoriteSunnahs(); // Load favorite Sunnahs
    await loadSwipeableSunnahs(); // Load swipeable Sunnahs - New
  }

  Future<void> loadSunnahs() async {
    await _errorHandler.handleAsyncError('Load Sunnahs', () async {
      _setLoading(true);
      _logger.info('Loading Sunnahs from database');

      final stopwatch = Stopwatch()..start();

      // Load Sunnahs from database
      _allSunnahs = await _databaseService.getAllSunnahs();

      // Load today's Sunnah
      await _loadTodaySunnah();

      // Update favorite status for all Sunnahs
      await _updateFavoriteStatus();

      stopwatch.stop();
      _logger.performance('Load Sunnahs', stopwatch.elapsed, data: {
        'sunnahCount': _allSunnahs.length,
        'todaySunnahId': _todaySunnah?.id,
      });

      _setLoading(false);
      _logger.info('Sunnahs loaded successfully: ${_allSunnahs.length} items');
    }, showUserError: true);
  }

  Future<void> _loadTodaySunnah() async {
    await _errorHandler.handleAsyncError('Load today Sunnah', () async {
      final now = DateTime.now();
      final today = now.toIso8601String().split('T')[0];
      final lastSunnahDate = _storageService.getLastSunnahDate();
      final lastSunnahId = _storageService.getTodaySunnahId();

      // If it's a new day or first time, select a new Sunnah
      if (lastSunnahDate != today || lastSunnahId == null) {
        _logger.info(
            'Selecting new Sunnah for today: $today (last: $lastSunnahDate)');
        await _selectNewSunnah();
      } else {
        // Load the same Sunnah for today
        if (_allSunnahs.isNotEmpty) {
          try {
            _todaySunnah = _allSunnahs.firstWhere(
              (sunnah) => sunnah.id == lastSunnahId,
            );
          } catch (e) {
            // If Sunnah with that ID doesn't exist, select a new one
            _logger.warning(
                'Stored Sunnah ID $lastSunnahId not found, selecting new one');
            await _selectNewSunnah();
            return;
          }
        }

        if (_todaySunnah != null) {
          _logger
              .info('Loaded existing Sunnah for today: ${_todaySunnah!.title}');
        }
      }
    });
  }

  Future<void> _selectNewSunnah() async {
    await _errorHandler.handleAsyncError('Select new Sunnah', () async {
      if (_allSunnahs.isEmpty) {
        _logger.warning('No Sunnahs available to select');
        return;
      }

      final usedSunnahIds = _storageService.getUsedSunnahIds();
      _logger.info('Currently used Sunnah IDs: ${usedSunnahIds.length}');

      // Find unused Sunnahs
      final unusedSunnahs = _allSunnahs
          .where(
            (sunnah) => !usedSunnahIds.contains(sunnah.id.toString()),
          )
          .toList();

      _logger.info('Found ${unusedSunnahs.length} unused Sunnahs');

      // If all Sunnahs have been used, reset the list
      if (unusedSunnahs.isEmpty) {
        usedSunnahIds.clear();
        unusedSunnahs.addAll(_allSunnahs);
        _logger
            .info('Reset used Sunnahs list - all Sunnahs have been completed');
      }

      // Select a random Sunnah
      unusedSunnahs.shuffle();
      _todaySunnah = unusedSunnahs.first;

      // Save the selection
      final today = DateTime.now().toIso8601String().split('T')[0];
      await _storageService.setLastSunnahDate(today);
      await _storageService.setTodaySunnahId(_todaySunnah!.id);

      // Add to used list
      usedSunnahIds.add(_todaySunnah!.id.toString());
      await _storageService.setUsedSunnahIds(usedSunnahIds);

      _logger.info(
          'Selected new Sunnah for today: ${_todaySunnah!.title} (ID: ${_todaySunnah!.id})');
      _logger.userAction('New Sunnah Selected', data: {
        'sunnahId': _todaySunnah!.id,
        'title': _todaySunnah!.title,
        'category': _todaySunnah!.category,
      });
    });
  }

  /// Load favorite Sunnahs
  Future<void> _loadFavoriteSunnahs() async {
    await _errorHandler.handleAsyncError('Load favorite Sunnahs', () async {
      final favoriteIds = await _databaseService.getFavoriteSunnahIds();
      _favoriteSunnahIds = favoriteIds.toSet();
      _logger.info('Loaded ${_favoriteSunnahIds.length} favorite Sunnahs');
    });
  }

  /// Load swipeable Sunnahs - New method
  Future<void> loadSwipeableSunnahs() async {
    await _errorHandler.handleAsyncError('Load swipeable Sunnahs', () async {
      // Get a random selection of Sunnahs for swiping
      final allSunnahs = await _databaseService.getAllSunnahs();

      // Shuffle and take first 10 for swipeable list
      allSunnahs.shuffle();
      _swipeableSunnahs = allSunnahs.take(10).toList();

      // Reset index
      _currentSwipeIndex = 0;

      _logger.info('Loaded ${_swipeableSunnahs.length} swipeable Sunnahs');
      notifyListeners();
    });
  }

  /// Move to next Sunnah in swipeable list - New method
  void nextSwipeableSunnah() {
    if (_swipeableSunnahs.isNotEmpty &&
        _currentSwipeIndex < _swipeableSunnahs.length - 1) {
      _currentSwipeIndex++;
      notifyListeners();
    }
  }

  /// Move to previous Sunnah in swipeable list - New method
  void previousSwipeableSunnah() {
    if (_currentSwipeIndex > 0) {
      _currentSwipeIndex--;
      notifyListeners();
    }
  }

  /// Get current swipeable Sunnah - New method
  Sunnah? get currentSwipeableSunnah {
    if (_swipeableSunnahs.isEmpty ||
        _currentSwipeIndex >= _swipeableSunnahs.length) {
      return null;
    }
    return _swipeableSunnahs[_currentSwipeIndex];
  }

  /// Update favorite status for all Sunnahs
  Future<void> _updateFavoriteStatus() async {
    for (var sunnah in _allSunnahs) {
      sunnah.isFavorite = _favoriteSunnahIds.contains(sunnah.id);
    }

    // Also update today's Sunnah if it exists
    if (_todaySunnah != null) {
      _todaySunnah!.isFavorite = _favoriteSunnahIds.contains(_todaySunnah!.id);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _error = loading ? null : _error;
      notifyListeners();
    }
  }

  /// Get Sunnahs by category
  List<Sunnah> getSunnahsByCategory(String category) {
    return _errorHandler.handleError('Get Sunnahs by category', () {
      _logger.info('Getting Sunnahs for category: $category');
      return _allSunnahs
          .where((sunnah) => sunnah.category == category)
          .toList();
    }, fallback: <Sunnah>[]);
  }

  /// Get unique categories
  Future<List<String>> getCategories() async {
    return await _errorHandler.handleAsyncError('Get categories', () async {
      if (_allSunnahs.isEmpty) {
        return await _databaseService.getCategories();
      }
      return _allSunnahs.map((sunnah) => sunnah.category).toSet().toList();
    }, fallback: <String>[]);
  }

  /// Search Sunnahs
  Future<List<Sunnah>> searchSunnahs(String query) async {
    return await _errorHandler.handleAsyncError('Search Sunnahs', () async {
      if (query.isEmpty) return <Sunnah>[];

      _logger.userAction('Search Sunnahs', data: {'query': query});

      // Use database search for better performance
      final results = await _databaseService.searchSunnahs(query);

      // Update favorite status for search results
      for (var sunnah in results) {
        sunnah.isFavorite = _favoriteSunnahIds.contains(sunnah.id);
      }

      _logger.info('Search completed: ${results.length} results for "$query"');
      return results;
    }, fallback: <Sunnah>[]);
  }

  /// Check if a specific Sunnah has been completed
  Future<bool> isSunnahCompleted(int sunnahId) async {
    return await _databaseService.isSunnahCompleted(sunnahId);
  }

  /// Get all completed Sunnah IDs
  Future<List<int>> getCompletedSunnahIds() async {
    return await _databaseService.getCompletedSunnahIds();
  }

  /// Mark any Sunnah as completed
  Future<void> markSunnahAsCompleted(int sunnahId, {String? note}) async {
    await _errorHandler.handleAsyncError('Mark Sunnah completed', () async {
      // Record progress in database
      await _databaseService.recordProgress(sunnahId, note: note);

      _logger.userAction('Sunnah Completed', data: {
        'sunnahId': sunnahId,
        'hasNote': note != null,
      });

      notifyListeners();
    });
  }

  /// Remove completion status for a Sunnah
  Future<void> removeSunnahCompletion(int sunnahId) async {
    await _errorHandler.handleAsyncError('Remove Sunnah completion', () async {
      // Remove progress from database
      await _databaseService.removeSunnahCompletion(sunnahId);

      _logger.userAction('Sunnah Completion Removed', data: {
        'sunnahId': sunnahId,
      });

      notifyListeners();
    });
  }

  /// Mark today's Sunnah as completed
  Future<void> markTodayCompleted({String? note}) async {
    await _errorHandler.handleAsyncError('Mark today completed', () async {
      if (_todaySunnah == null) {
        _logger.warning('No today Sunnah to mark as completed');
        return;
      }

      // Record progress in database
      await _databaseService.recordProgress(_todaySunnah!.id, note: note);

      _logger.userAction('Sunnah Completed', data: {
        'sunnahId': _todaySunnah!.id,
        'title': _todaySunnah!.title,
        'hasNote': note != null,
      });

      notifyListeners();
    });
  }

  /// Add this new method to check if a specific Sunnah is completed
  Future<bool> isSunnahCompletedById(int sunnahId) async {
    return await _databaseService.isSunnahCompleted(sunnahId);
  }

  /// Add this new method to refresh completion status
  Future<void> refreshCompletionStatus() async {
    notifyListeners();
  }

  /// Get Sunnah by ID
  Sunnah? getSunnahById(int id) {
    return _errorHandler.handleError('Get Sunnah by ID', () {
      try {
        return _allSunnahs.firstWhere((sunnah) => sunnah.id == id);
      } catch (e) {
        return null;
      }
    });
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadSunnahs();
    await loadSwipeableSunnahs(); // Also refresh swipeable Sunnahs
  }

  /// Get random Sunnah from category
  Sunnah? getRandomSunnahFromCategory(String category) {
    return _errorHandler.handleError('Get random Sunnah from category', () {
      final categoryPool = getSunnahsByCategory(category);
      if (categoryPool.isEmpty) return null;

      categoryPool.shuffle();
      return categoryPool.first;
    });
  }

  // New methods for favorites functionality

  /// Add a Sunnah to favorites
  Future<void> addFavorite(Sunnah sunnah) async {
    await _errorHandler.handleAsyncError('Add favorite', () async {
      // Add to database
      await _databaseService.addFavorite(sunnah.id);

      // Update local state
      _favoriteSunnahIds.add(sunnah.id);

      // Update the Sunnah object
      sunnah.isFavorite = true;

      _logger.userAction('Sunnah Favorited', data: {
        'sunnahId': sunnah.id,
        'title': sunnah.title,
      });

      notifyListeners();
    });
  }

  /// Remove a Sunnah from favorites
  Future<void> removeFavorite(Sunnah sunnah) async {
    await _errorHandler.handleAsyncError('Remove favorite', () async {
      // Remove from database
      await _databaseService.removeFavorite(sunnah.id);

      // Update local state
      _favoriteSunnahIds.remove(sunnah.id);

      // Update the Sunnah object
      sunnah.isFavorite = false;

      _logger.userAction('Sunnah Unfavorited', data: {
        'sunnahId': sunnah.id,
        'title': sunnah.title,
      });

      notifyListeners();
    });
  }

  /// Toggle favorite status for a Sunnah
  Future<void> toggleFavorite(Sunnah sunnah) async {
    if (sunnah.isFavorite) {
      await removeFavorite(sunnah);
    } else {
      await addFavorite(sunnah);
    }
  }

  /// Check if a Sunnah is favorited
  Future<bool> isFavorite(int sunnahId) async {
    return await _databaseService.isFavorite(sunnahId);
  }

  /// Get all favorite Sunnahs
  Future<List<Sunnah>> getFavoriteSunnahs() async {
    return await _errorHandler.handleAsyncError('Get favorite Sunnahs',
        () async {
      final favoriteSunnahs = await _databaseService.getFavoriteSunnahs();

      // Update favorite status
      for (var sunnah in favoriteSunnahs) {
        sunnah.isFavorite = true;
      }

      return favoriteSunnahs;
    }, fallback: <Sunnah>[]);
  }

  @override
  void dispose() {
    _logger.info('Disposing SunnahProvider');
    super.dispose();
  }
}
