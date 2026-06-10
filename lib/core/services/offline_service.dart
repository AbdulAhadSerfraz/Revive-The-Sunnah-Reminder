import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';
import 'package:revive_sunnah_reminder/core/services/storage_service.dart';
import 'package:revive_sunnah_reminder/core/services/network_service.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';

/// Simplified offline support service with basic caching
class OfflineService {
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();

  OfflineService._();

  final LoggingService _logger = LoggingService.instance;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  NetworkService? _networkService;
  StorageService? _storageService;

  // Connectivity monitoring
  bool _isOnline = false;
  DateTime? _lastOnlineTime;

  // Sync queue for pending operations
  final List<SyncOperation> _syncQueue = [];
  bool _isSyncing = false;

  // Cache directories
  Directory? _cacheDir;
  Directory? _offlineDataDir;

  // Cache settings
  static const Duration _cacheExpiration = Duration(days: 7);
  static const int _maxSyncRetries = 3;

  /// Initialize offline service
  Future<void> initialize({
    required NetworkService networkService,
    required StorageService storageService,
  }) async {
    await _errorHandler.handleAsyncError('Initialize offline service',
        () async {
      _networkService = networkService;
      _storageService = storageService;

      // Setup cache directories
      await _setupCacheDirectories();

      // Check initial connectivity
      await _checkConnectivity();

      // Load pending sync operations
      await _loadPendingSyncOperations();

      _logger.info('Offline service initialized successfully');
    });
  }

  /// Setup cache directories
  Future<void> _setupCacheDirectories() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/offline_cache');
    _offlineDataDir = Directory('${appDir.path}/offline_data');

    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }

    if (!await _offlineDataDir!.exists()) {
      await _offlineDataDir!.create(recursive: true);
    }

    _logger.debug('Cache directories setup completed');
  }

  /// Check current connectivity
  Future<void> _checkConnectivity() async {
    try {
      if (_networkService != null) {
        _isOnline = await _networkService!.isConnected();
      } else {
        _isOnline = false;
      }

      if (_isOnline) {
        _lastOnlineTime = DateTime.now();
      }

      final status = _isOnline ? 'online' : 'offline';
      _logger.debug('Initial connectivity check: $status');
    } catch (e) {
      _logger.error('Error checking connectivity', e);
      _isOnline = false;
    }
  }

  /// Check if device is currently online
  bool get isOnline => _isOnline;

  /// Get last online time
  DateTime? get lastOnlineTime => _lastOnlineTime;

  /// Get time since last online
  Duration? get timeSinceLastOnline {
    if (_lastOnlineTime == null) return null;
    return DateTime.now().difference(_lastOnlineTime!);
  }

  /// Cache data for offline use
  Future<void> cacheData(
    String key,
    Map<String, dynamic> data, {
    Duration? expiration,
  }) async {
    await _errorHandler.handleAsyncError('Cache data: $key', () async {
      final cacheFile = File('${_cacheDir!.path}/$key.json');

      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiration': (expiration ?? _cacheExpiration).inMilliseconds,
      };

      await cacheFile.writeAsString(json.encode(cacheEntry));

      _logger.debug('Data cached successfully: $key');
    });
  }

  /// Retrieve cached data
  Future<Map<String, dynamic>?> getCachedData(
    String key, {
    bool checkExpiration = true,
  }) async {
    return await _errorHandler.handleAsyncError(
      'Get cached data: $key',
      () async {
        final cacheFile = File('${_cacheDir!.path}/$key.json');

        if (!await cacheFile.exists()) {
          _logger.debug('Cache miss: $key');
          return null;
        }

        final content = await cacheFile.readAsString();
        final cacheEntry = json.decode(content) as Map<String, dynamic>;

        // Check expiration if requested
        if (checkExpiration) {
          final timestamp = cacheEntry['timestamp'] as int;
          final expiration = cacheEntry['expiration'] as int;
          final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final expirationTime =
              cacheTime.add(Duration(milliseconds: expiration));

          if (DateTime.now().isAfter(expirationTime)) {
            _logger.debug('Cache expired: $key');
            await cacheFile.delete();
            return null;
          }
        }

        _logger.debug('Cache hit: $key');
        return cacheEntry['data'] as Map<String, dynamic>;
      },
      fallback: null,
    );
  }

  /// Cache Sunnahs for offline access
  Future<void> cacheSunnahs(List<Sunnah> sunnahs, {String? category}) async {
    final key = category != null ? 'sunnahs_$category' : 'sunnahs_all';
    final data = {
      'sunnahs': sunnahs.map((s) => s.toJson()).toList(),
      'category': category,
      'count': sunnahs.length,
    };

    await cacheData(key, data);
  }

  /// Get cached Sunnahs
  Future<List<Sunnah>> getCachedSunnahs({String? category}) async {
    return await _errorHandler.handleAsyncError(
      'Get cached Sunnahs',
      () async {
        final key = category != null ? 'sunnahs_$category' : 'sunnahs_all';
        final cachedData = await getCachedData(key);

        if (cachedData != null) {
          final sunnahsList = cachedData['sunnahs'] as List<dynamic>;
          return sunnahsList
              .map((json) => Sunnah.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        return <Sunnah>[];
      },
      fallback: <Sunnah>[],
    );
  }

  /// Add operation to sync queue
  Future<void> addToSyncQueue(SyncOperation operation) async {
    _syncQueue.add(operation);
    await _savePendingSyncOperations();

    // Try to sync immediately if online
    if (_isOnline && !_isSyncing) {
      await _startSync();
    }
  }

  /// Start sync process
  Future<void> _startSync() async {
    if (_isSyncing || _syncQueue.isEmpty || !_isOnline) return;

    _isSyncing = true;
    _logger.info('Starting sync process with ${_syncQueue.length} operations');

    try {
      final operationsToSync = List<SyncOperation>.from(_syncQueue);

      for (final operation in operationsToSync) {
        try {
          await _syncOperation(operation);
          _syncQueue.remove(operation);
          _logger.debug('Synced operation: ${operation.id}');
        } catch (e) {
          operation.retryCount++;
          if (operation.retryCount >= _maxSyncRetries) {
            _syncQueue.remove(operation);
            _logger.error(
                'Max retries exceeded for operation: ${operation.id}', e);
          } else {
            _logger.warning(
                'Sync failed for operation: ${operation.id}, retry ${operation.retryCount}');
          }
        }
      }

      await _savePendingSyncOperations();
      _logger.info('Sync process completed');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync individual operation
  Future<void> _syncOperation(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.progressUpdate:
        // Sync progress update
        break;
      case SyncOperationType.settingsUpdate:
        // Sync settings update
        break;
      case SyncOperationType.userAction:
        // Sync user action
        break;
    }
  }

  /// Save pending sync operations
  Future<void> _savePendingSyncOperations() async {
    final data = {
      'operations': _syncQueue.map((op) => op.toJson()).toList(),
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };

    _storageService?.setObject('pending_sync_operations', data);
  }

  /// Load pending sync operations
  Future<void> _loadPendingSyncOperations() async {
    final data = _storageService?.getObject('pending_sync_operations');
    if (data != null) {
      final operations = data['operations'] as List<dynamic>;
      _syncQueue.clear();

      for (final opData in operations) {
        _syncQueue.add(SyncOperation.fromJson(opData as Map<String, dynamic>));
      }

      _logger.info('Loaded ${_syncQueue.length} pending sync operations');
    }
  }

  /// Clean expired cache
  Future<void> cleanExpiredCache() async {
    await _errorHandler.handleAsyncError('Clean expired cache', () async {
      int clearedCount = 0;

      if (_cacheDir != null && await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list()) {
          if (entity is File && entity.path.endsWith('.json')) {
            try {
              final content = await entity.readAsString();
              final cacheEntry = json.decode(content) as Map<String, dynamic>;

              final timestamp = cacheEntry['timestamp'] as int;
              final expiration = cacheEntry['expiration'] as int;
              final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
              final expirationTime =
                  cacheTime.add(Duration(milliseconds: expiration));

              if (DateTime.now().isAfter(expirationTime)) {
                await entity.delete();
                clearedCount++;
              }
            } catch (e) {
              // Delete corrupted cache files
              await entity.delete();
              clearedCount++;
            }
          }
        }
      }

      _logger.info('Cleared $clearedCount expired cache items');
    });
  }

  /// Get offline data summary
  Future<Map<String, dynamic>> getOfflineDataSummary() async {
    return await _errorHandler.handleAsyncError(
      'Get offline data summary',
      () async {
        final summary = <String, dynamic>{
          'isOnline': _isOnline,
          'lastOnlineTime': _lastOnlineTime?.toIso8601String(),
          'timeSinceLastOnline': timeSinceLastOnline?.inMinutes,
          'pendingSyncOperations': _syncQueue.length,
          'cacheSize': await _getCacheSize(),
          'cachedItems': await _getCachedItemsCount(),
        };

        return summary;
      },
      fallback: <String, dynamic>{},
    );
  }

  /// Get cache size in bytes
  Future<int> _getCacheSize() async {
    int totalSize = 0;

    if (_cacheDir != null && await _cacheDir!.exists()) {
      await for (final entity in _cacheDir!.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
    }

    return totalSize;
  }

  /// Get number of cached items
  Future<int> _getCachedItemsCount() async {
    int count = 0;

    if (_cacheDir != null && await _cacheDir!.exists()) {
      await for (final entity in _cacheDir!.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          count++;
        }
      }
    }

    return count;
  }

  /// Force sync all pending operations
  Future<void> forceSyncAll() async {
    if (!_isOnline) {
      _logger.warning('Cannot force sync while offline');
      return;
    }

    await _startSync();
  }

  /// Dispose resources
  Future<void> dispose() async {
    _syncQueue.clear();
    _logger.info('Offline service disposed');
  }
}

/// Sync operation model
class SyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  int retryCount;

  SyncOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'] as String,
      type: SyncOperationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'retryCount': retryCount,
    };
  }
}

/// Sync operation types
enum SyncOperationType {
  progressUpdate,
  settingsUpdate,
  userAction,
}

/// Extension for unawaited operations
void unawaited(Future<void> future) {
  // Ignore unused future
}
