import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';
import 'package:revive_sunnah_reminder/core/services/database_service.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';

/// Service for lazy loading and caching data efficiently
class LazyLoadingService {
  final DatabaseService _databaseService;
  final LoggingService _logger;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;
  
  // Cache for loaded data
  final Map<String, List<Sunnah>> _categoryCache = {};
  final Map<String, List<Sunnah>> _searchCache = {};
  final Set<String> _loadingCategories = {};
  final Set<String> _loadingSearches = {};
  
  // Pagination settings
  static const int _defaultPageSize = 20;
  static const int _maxCacheSize = 1000;
  
  // Cache expiration
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(hours: 1);
  
  LazyLoadingService({
    required DatabaseService databaseService,
    required LoggingService loggingService,
  }) : _databaseService = databaseService,
       _logger = loggingService;
  
  /// Load Sunnahs by category with pagination
  Future<List<Sunnah>> loadSunnahsByCategory(
    String category, {
    int page = 0,
    int pageSize = _defaultPageSize,
    bool forceRefresh = false,
  }) async {
    return await _errorHandler.handleAsyncError(
      'Load Sunnahs by category: $category',
      () async {
        final cacheKey = '${category}_$page';
        
        // Check cache first
        if (!forceRefresh && _isCacheValid(cacheKey) && _categoryCache.containsKey(cacheKey)) {
          _logger.debug('Returning cached data for category: $category, page: $page');
          return _categoryCache[cacheKey]!;
        }
        
        // Prevent duplicate loading
        if (_loadingCategories.contains(cacheKey)) {
          _logger.debug('Already loading category: $category, page: $page');
          // Wait for existing load to complete
          while (_loadingCategories.contains(cacheKey)) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          return _categoryCache[cacheKey] ?? [];
        }
        
        _loadingCategories.add(cacheKey);
        
        try {
          final stopwatch = Stopwatch()..start();
          
          // Load from database with pagination
          final allCategorySunnahs = await _databaseService.getSunnahsByCategory(category);
          
          // Apply pagination
          final startIndex = page * pageSize;
          final endIndex = (startIndex + pageSize).clamp(0, allCategorySunnahs.length);
          
          final paginatedSunnahs = startIndex < allCategorySunnahs.length
              ? allCategorySunnahs.sublist(startIndex, endIndex)
              : <Sunnah>[];
          
          stopwatch.stop();
          
          // Cache the result
          _categoryCache[cacheKey] = paginatedSunnahs;
          _cacheTimestamps[cacheKey] = DateTime.now();
          
          // Manage cache size
          _manageCacheSize();
          
          _logger.performance(
            'Load category Sunnahs',
            stopwatch.elapsed,
            data: {
              'category': category,
              'page': page,
              'pageSize': pageSize,
              'resultCount': paginatedSunnahs.length,
            },
          );
          
          return paginatedSunnahs;
        } finally {
          _loadingCategories.remove(cacheKey);
        }
      },
      fallback: <Sunnah>[],
    );
  }
  
  /// Search Sunnahs with lazy loading and caching
  Future<List<Sunnah>> searchSunnahs(
    String query, {
    int page = 0,
    int pageSize = _defaultPageSize,
    bool forceRefresh = false,
  }) async {
    if (query.trim().isEmpty) return [];
    
    return await _errorHandler.handleAsyncError(
      'Search Sunnahs: $query',
      () async {
        final cacheKey = '${query.trim().toLowerCase()}_$page';
        
        // Check cache first
        if (!forceRefresh && _isCacheValid(cacheKey) && _searchCache.containsKey(cacheKey)) {
          _logger.debug('Returning cached search results for: $query, page: $page');
          return _searchCache[cacheKey]!;
        }
        
        // Prevent duplicate searches
        if (_loadingSearches.contains(cacheKey)) {
          _logger.debug('Already searching for: $query, page: $page');
          while (_loadingSearches.contains(cacheKey)) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          return _searchCache[cacheKey] ?? [];
        }
        
        _loadingSearches.add(cacheKey);
        
        try {
          final stopwatch = Stopwatch()..start();
          
          // Search in database
          final allResults = await _databaseService.searchSunnahs(query.trim());
          
          // Apply pagination
          final startIndex = page * pageSize;
          final endIndex = (startIndex + pageSize).clamp(0, allResults.length);
          
          final paginatedResults = startIndex < allResults.length
              ? allResults.sublist(startIndex, endIndex)
              : <Sunnah>[];
          
          stopwatch.stop();
          
          // Cache the result
          _searchCache[cacheKey] = paginatedResults;
          _cacheTimestamps[cacheKey] = DateTime.now();
          
          // Manage cache size
          _manageCacheSize();
          
          _logger.performance(
            'Search Sunnahs',
            stopwatch.elapsed,
            data: {
              'query': query,
              'page': page,
              'pageSize': pageSize,
              'totalResults': allResults.length,
              'resultCount': paginatedResults.length,
            },
          );
          
          return paginatedResults;
        } finally {
          _loadingSearches.remove(cacheKey);
        }
      },
      fallback: <Sunnah>[],
    );
  }
  
  /// Preload next page in background
  Future<void> preloadNextPage(
    String category, {
    int currentPage = 0,
    int pageSize = _defaultPageSize,
  }) async {
    if (!kDebugMode) {
      // Only preload in release mode for better performance
      final nextPage = currentPage + 1;
      unawaited(loadSunnahsByCategory(
        category,
        page: nextPage,
        pageSize: pageSize,
      ));
    }
  }
  
  /// Preload search results
  Future<void> preloadSearchResults(
    String query, {
    int currentPage = 0,
    int pageSize = _defaultPageSize,
  }) async {
    if (!kDebugMode && query.trim().isNotEmpty) {
      final nextPage = currentPage + 1;
      unawaited(searchSunnahs(
        query,
        page: nextPage,
        pageSize: pageSize,
      ));
    }
  }
  
  /// Check if cache is valid
  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }
  
  /// Manage cache size to prevent memory issues
  void _manageCacheSize() {
    final totalCacheSize = _categoryCache.length + _searchCache.length;
    
    if (totalCacheSize > _maxCacheSize) {
      _logger.debug('Cache size exceeded limit, cleaning up old entries');
      
      // Remove oldest entries
      final sortedTimestamps = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      final toRemove = sortedTimestamps.take(totalCacheSize - _maxCacheSize ~/ 2);
      
      for (final entry in toRemove) {
        _categoryCache.remove(entry.key);
        _searchCache.remove(entry.key);
        _cacheTimestamps.remove(entry.key);
      }
      
      _logger.debug('Cleaned up ${toRemove.length} cache entries');
    }
  }
  
  /// Clear all caches
  void clearCache() {
    _categoryCache.clear();
    _searchCache.clear();
    _cacheTimestamps.clear();
    _logger.info('All caches cleared');
  }
  
  /// Clear cache for specific category
  void clearCategoryCache(String category) {
    final keysToRemove = _categoryCache.keys
        .where((key) => key.startsWith('${category}_'))
        .toList();
    
    for (final key in keysToRemove) {
      _categoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    _logger.debug('Cleared cache for category: $category');
  }
  
  /// Clear search cache
  void clearSearchCache() {
    final keysToRemove = _searchCache.keys.toList();
    
    for (final key in keysToRemove) {
      _searchCache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    _logger.debug('Cleared search cache');
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'categoryCache': _categoryCache.length,
      'searchCache': _searchCache.length,
      'totalCacheSize': _categoryCache.length + _searchCache.length,
      'maxCacheSize': _maxCacheSize,
      'loadingCategories': _loadingCategories.length,
      'loadingSearches': _loadingSearches.length,
      'oldestCacheEntry': _cacheTimestamps.values.isNotEmpty
          ? _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
      'newestCacheEntry': _cacheTimestamps.values.isNotEmpty
          ? _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
    };
  }
  
  /// Warm up cache with frequently accessed data
  Future<void> warmUpCache() async {
    await _errorHandler.handleAsyncError('Warm up cache', () async {
      _logger.info('Warming up cache with frequently accessed data');
      
      // Preload first page of each category
      final categories = await _databaseService.getCategories();
      
      for (final category in categories.take(5)) {
        unawaited(loadSunnahsByCategory(category, page: 0));
      }
      
      _logger.info('Cache warm-up initiated for ${categories.length} categories');
    });
  }
  
  /// Dispose and clean up resources
  void dispose() {
    clearCache();
    _loadingCategories.clear();
    _loadingSearches.clear();
    _logger.info('LazyLoadingService disposed');
  }
}