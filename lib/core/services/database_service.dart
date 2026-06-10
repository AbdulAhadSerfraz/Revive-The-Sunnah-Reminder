import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';

/// Production-level database service using SQLite
class DatabaseService {
  static const String _databaseName = 'revive_app.db';
  static const int _databaseVersion = 2; // Updated version number

  // Table names
  static const String _sunnahsTable = 'sunnahs';
  static const String _progressTable = 'progress';
  static const String _streakTable = 'streak';
  static const String _favoritesTable = 'favorites'; // New table for favorites

  Database? _database;
  final LoggingService _logger = LoggingService.instance;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<void> initialize() async {
    await _errorHandler.handleAsyncError('Database initialization', () async {
      _database = await _initDatabase();
      await _populateInitialData();
      _logger.info('Database initialized successfully');
    });
  }

  /// Initialize database with tables
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await _errorHandler.handleAsyncError('Database table creation', () async {
      // Sunnahs table
      await db.execute('''
        CREATE TABLE $_sunnahsTable (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          category TEXT NOT NULL,
          hadith TEXT NOT NULL,
          benefit TEXT NOT NULL,
          source TEXT NOT NULL,
          arabic_text TEXT,
          translation TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // Progress table
      await db.execute('''
        CREATE TABLE $_progressTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sunnah_id INTEGER NOT NULL,
          completed_at INTEGER NOT NULL,
          note TEXT,
          FOREIGN KEY (sunnah_id) REFERENCES $_sunnahsTable (id)
        )
      ''');

      // Streak table
      await db.execute('''
        CREATE TABLE $_streakTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          completed INTEGER NOT NULL DEFAULT 0,
          sunnah_id INTEGER,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (sunnah_id) REFERENCES $_sunnahsTable (id)
        )
      ''');

      // Favorites table - New table for favorites
      await db.execute('''
        CREATE TABLE $_favoritesTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sunnah_id INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (sunnah_id) REFERENCES $_sunnahsTable (id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for better performance
      await db.execute(
          'CREATE INDEX idx_sunnahs_category ON $_sunnahsTable (category)');
      await db.execute(
          'CREATE INDEX idx_progress_sunnah_id ON $_progressTable (sunnah_id)');
      await db.execute(
          'CREATE INDEX idx_progress_completed_at ON $_progressTable (completed_at)');
      await db.execute('CREATE INDEX idx_streak_date ON $_streakTable (date)');
      await db.execute(
          'CREATE INDEX idx_favorites_sunnah_id ON $_favoritesTable (sunnah_id)'); // New index

      _logger.info('Database tables created successfully');
    });
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _errorHandler.handleAsyncError('Database upgrade', () async {
      _logger
          .info('Upgrading database from version $oldVersion to $newVersion');

      // Handle database migrations
      if (oldVersion < 2) {
        // Add favorites table for version 2
        await db.execute('''
          CREATE TABLE $_favoritesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sunnah_id INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (sunnah_id) REFERENCES $_sunnahsTable (id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
            'CREATE INDEX idx_favorites_sunnah_id ON $_favoritesTable (sunnah_id)');

        _logger.info('Favorites table added in database upgrade');
      }
    });
  }

  /// Populate initial data from JSON
  Future<void> _populateInitialData() async {
    await _errorHandler.handleAsyncError('Initial data population', () async {
      final count = await _getSunnahCount();
      if (count == 0) {
        await _loadSunnahsFromAssets();
        _logger.info('Initial Sunnah data loaded successfully');
      }
    });
  }

  /// Load Sunnahs from assets and insert into database
  Future<void> _loadSunnahsFromAssets() async {
    final String response =
        await rootBundle.loadString('assets/data/sunnahs.json');
    final List<dynamic> data = json.decode(response);
    final now = DateTime.now().millisecondsSinceEpoch;

    final db = await database;
    final batch = db.batch();

    for (final item in data) {
      final sunnah = Sunnah.fromJson(item);
      batch.insert(_sunnahsTable, {
        'id': sunnah.id,
        'title': sunnah.title,
        'category': sunnah.category,
        'hadith': sunnah.hadith,
        'benefit': sunnah.benefit,
        'source': sunnah.source,
        'arabic_text': sunnah.arabicText,
        'translation': sunnah.translation,
        'created_at': now,
        'updated_at': now,
      });
    }

    await batch.commit(noResult: true);
  }

  /// Get count of Sunnahs
  Future<int> _getSunnahCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $_sunnahsTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get all Sunnahs
  Future<List<Sunnah>> getAllSunnahs() async {
    return await _errorHandler.handleAsyncError('Get all Sunnahs', () async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _sunnahsTable,
        orderBy: 'category, id',
      );

      return maps.map((map) => Sunnah.fromJson(map)).toList();
    }, fallback: <Sunnah>[]);
  }

  /// Get Sunnahs by category
  Future<List<Sunnah>> getSunnahsByCategory(String category) async {
    return await _errorHandler.handleAsyncError('Get Sunnahs by category',
        () async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _sunnahsTable,
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'id',
      );

      return maps.map((map) => Sunnah.fromJson(map)).toList();
    }, fallback: <Sunnah>[]);
  }

  /// Search Sunnahs
  Future<List<Sunnah>> searchSunnahs(String query) async {
    return await _errorHandler.handleAsyncError('Search Sunnahs', () async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _sunnahsTable,
        where: '''
          title LIKE ? OR 
          hadith LIKE ? OR 
          category LIKE ? OR 
          benefit LIKE ?
        ''',
        whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
        orderBy: 'category, id',
      );

      return maps.map((map) => Sunnah.fromJson(map)).toList();
    }, fallback: <Sunnah>[]);
  }

  /// Get unique categories
  Future<List<String>> getCategories() async {
    return await _errorHandler.handleAsyncError('Get categories', () async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT category FROM $_sunnahsTable ORDER BY category',
      );

      return maps.map((map) => map['category'] as String).toList();
    }, fallback: <String>[]);
  }

  /// Record progress for a Sunnah
  Future<void> recordProgress(int sunnahId, {String? note}) async {
    await _errorHandler.handleAsyncError('Record progress', () async {
      final db = await database;
      await db.insert(_progressTable, {
        'sunnah_id': sunnahId,
        'completed_at': DateTime.now().millisecondsSinceEpoch,
        'note': note,
      });
    });
  }

  /// Get progress for a specific date range
  Future<List<Map<String, dynamic>>> getProgress({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _errorHandler.handleAsyncError('Get progress', () async {
      final db = await database;
      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (startDate != null && endDate != null) {
        whereClause = 'WHERE completed_at >= ? AND completed_at <= ?';
        whereArgs = [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ];
      }

      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.*, s.title, s.category 
        FROM $_progressTable p 
        JOIN $_sunnahsTable s ON p.sunnah_id = s.id 
        $whereClause
        ORDER BY p.completed_at DESC
      ''', whereArgs);

      return maps;
    }, fallback: <Map<String, dynamic>>[]);
  }

  /// Update or insert streak record
  Future<void> updateStreak(String date, bool completed,
      {int? sunnahId}) async {
    await _errorHandler.handleAsyncError('Update streak', () async {
      final db = await database;
      await db.insert(
        _streakTable,
        {
          'date': date,
          'completed': completed ? 1 : 0,
          'sunnah_id': sunnahId,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  /// Get streak data
  Future<List<Map<String, dynamic>>> getStreakData({int? limit}) async {
    return await _errorHandler.handleAsyncError('Get streak data', () async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _streakTable,
        orderBy: 'date DESC',
        limit: limit,
      );

      return maps;
    }, fallback: <Map<String, dynamic>>[]);
  }

  /// Check if a specific Sunnah has been completed
  Future<bool> isSunnahCompleted(int sunnahId) async {
    return await _errorHandler.handleAsyncError('Check Sunnah completion',
        () async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _progressTable,
        where: 'sunnah_id = ?',
        whereArgs: [sunnahId],
        limit: 1,
      );

      return maps.isNotEmpty;
    }, fallback: false);
  }

  /// Get all completed Sunnah IDs
  Future<List<int>> getCompletedSunnahIds() async {
    return await _errorHandler.handleAsyncError('Get completed Sunnah IDs',
        () async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _progressTable,
        columns: ['sunnah_id'],
        distinct: true,
      );

      return maps.map((map) => map['sunnah_id'] as int).toList();
    }, fallback: <int>[]);
  }

  /// Remove completion status for a Sunnah
  Future<void> removeSunnahCompletion(int sunnahId) async {
    return await _errorHandler.handleAsyncError('Remove Sunnah completion',
        () async {
      final db = await database;
      await db.delete(
        _progressTable,
        where: 'sunnah_id = ?',
        whereArgs: [sunnahId],
      );
    });
  }

  // New methods for favorites functionality

  /// Add a Sunnah to favorites
  Future<void> addFavorite(int sunnahId) async {
    return await _errorHandler.handleAsyncError('Add favorite', () async {
      final db = await database;
      await db.insert(
          _favoritesTable,
          {
            'sunnah_id': sunnahId,
            'created_at': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore); // Prevent duplicates
    });
  }

  /// Remove a Sunnah from favorites
  Future<void> removeFavorite(int sunnahId) async {
    return await _errorHandler.handleAsyncError('Remove favorite', () async {
      final db = await database;
      await db.delete(
        _favoritesTable,
        where: 'sunnah_id = ?',
        whereArgs: [sunnahId],
      );
    });
  }

  /// Check if a Sunnah is favorited
  Future<bool> isFavorite(int sunnahId) async {
    return await _errorHandler.handleAsyncError('Check favorite', () async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _favoritesTable,
        where: 'sunnah_id = ?',
        whereArgs: [sunnahId],
        limit: 1,
      );

      return maps.isNotEmpty;
    }, fallback: false);
  }

  /// Get all favorite Sunnah IDs
  Future<List<int>> getFavoriteSunnahIds() async {
    return await _errorHandler.handleAsyncError('Get favorite Sunnah IDs',
        () async {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query(_favoritesTable, columns: ['sunnah_id']);

      return maps.map((map) => map['sunnah_id'] as int).toList();
    }, fallback: <int>[]);
  }

  /// Get all favorite Sunnahs
  Future<List<Sunnah>> getFavoriteSunnahs() async {
    return await _errorHandler.handleAsyncError('Get favorite Sunnahs',
        () async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT s.* 
        FROM $_sunnahsTable s
        JOIN $_favoritesTable f ON s.id = f.sunnah_id
        ORDER BY f.created_at DESC
      ''');

      return maps.map((map) => Sunnah.fromJson(map)).toList();
    }, fallback: <Sunnah>[]);
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
