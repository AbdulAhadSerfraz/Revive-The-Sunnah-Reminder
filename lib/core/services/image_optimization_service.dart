import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:revive_sunnah_reminder/core/services/logging_service.dart';
import 'package:revive_sunnah_reminder/core/services/error_handling_service.dart';
import 'package:revive_sunnah_reminder/core/constants/app_constants.dart';

/// Service for image optimization, caching, and management
class ImageOptimizationService {
  final LoggingService _logger;
  final ErrorHandlingService _errorHandler = ErrorHandlingService.instance;

  static ImageOptimizationService? _instance;
  static ImageOptimizationService get instance =>
      _instance ??= ImageOptimizationService._();

  ImageOptimizationService._() : _logger = LoggingService.instance;

  // Cache directories
  Directory? _cacheDir;
  Directory? _thumbnailDir;

  // Cache settings
  static const Duration _cacheExpiration = Duration(days: 30);
  static const int _thumbnailSize = 200;

  /// Initialize the image service
  Future<void> initialize() async {
    await _errorHandler.handleAsyncError('Initialize image service', () async {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/image_cache');
      _thumbnailDir = Directory('${appDir.path}/thumbnails');

      // Create directories if they don't exist
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }

      if (!await _thumbnailDir!.exists()) {
        await _thumbnailDir!.create(recursive: true);
      }

      _logger.info('Image optimization service initialized');

      // Clean up old cache files
      scheduleMicrotask(() => _cleanupOldCache());
    });
  }

  /// Get optimized image widget for network images
  Widget getNetworkImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    bool enableMemoryCache = true,
  }) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        _logger.error('Failed to load network image: $url', error, stackTrace);
        return errorWidget ?? _buildErrorWidget();
      },
    );
  }

  /// Get optimized image widget for asset images
  Widget getAssetImage(
    String assetPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    bool enableCaching = true,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      errorBuilder: (context, error, stackTrace) {
        _logger.error(
            'Failed to load asset image: $assetPath', error, stackTrace);
        return _buildErrorWidget();
      },
    );
  }

  /// Create and cache thumbnail for image
  Future<String?> createThumbnail(
    String imagePath, {
    int size = _thumbnailSize,
    int quality = AppConstants.imageQuality,
  }) async {
    return await _errorHandler.handleAsyncError(
      'Create thumbnail for: $imagePath',
      () async {
        final hash = _generateHash(imagePath);
        final thumbnailFile = File('${_thumbnailDir!.path}/$hash.jpg');

        // Return cached thumbnail if exists
        if (await thumbnailFile.exists()) {
          _logger.debug('Returning cached thumbnail: $hash');
          return thumbnailFile.path;
        }

        final stopwatch = Stopwatch()..start();

        // Load and decode image
        Uint8List? imageData;
        if (imagePath.startsWith('http')) {
          // Network image
          final httpClient = HttpClient();
          final request = await httpClient.getUrl(Uri.parse(imagePath));
          final response = await request.close();
          final bytes = <int>[];
          await for (final chunk in response) {
            bytes.addAll(chunk);
          }
          imageData = Uint8List.fromList(bytes);
          httpClient.close();
        } else if (imagePath.startsWith('assets/')) {
          // Asset image
          final byteData = await rootBundle.load(imagePath);
          imageData = byteData.buffer.asUint8List();
        } else {
          // File image
          final file = File(imagePath);
          if (await file.exists()) {
            imageData = await file.readAsBytes();
          }
        }

        if (imageData == null) {
          _logger.warning('Could not load image data for: $imagePath');
          return null;
        }

        // Decode and resize image
        final codec = await ui.instantiateImageCodec(
          imageData,
          targetWidth: size,
          targetHeight: size,
        );

        final frame = await codec.getNextFrame();
        final resizedImageData = await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (resizedImageData != null) {
          await thumbnailFile.writeAsBytes(
            resizedImageData.buffer.asUint8List(),
          );

          stopwatch.stop();

          _logger.performance(
            'Create thumbnail',
            stopwatch.elapsed,
            data: {
              'originalPath': imagePath,
              'thumbnailPath': thumbnailFile.path,
              'size': size,
              'originalSize': imageData.length,
              'thumbnailSize': resizedImageData.lengthInBytes,
            },
          );

          return thumbnailFile.path;
        }

        return null;
      },
    );
  }

  /// Optimize image file
  Future<File?> optimizeImage(
    File imageFile, {
    int maxWidth = AppConstants.maxImageWidth,
    int maxHeight = AppConstants.maxImageHeight,
    int quality = AppConstants.imageQuality,
  }) async {
    return await _errorHandler.handleAsyncError(
      'Optimize image: ${imageFile.path}',
      () async {
        final hash = _generateHash(imageFile.path);
        final optimizedFile = File('${_cacheDir!.path}/${hash}_optimized.jpg');

        // Return cached optimized image if exists
        if (await optimizedFile.exists()) {
          _logger.debug('Returning cached optimized image: $hash');
          return optimizedFile;
        }

        final stopwatch = Stopwatch()..start();

        // Read original image
        final imageData = await imageFile.readAsBytes();

        // Decode image
        final codec = await ui.instantiateImageCodec(
          imageData,
          targetWidth: maxWidth,
          targetHeight: maxHeight,
        );

        final frame = await codec.getNextFrame();
        final optimizedImageData = await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (optimizedImageData != null) {
          await optimizedFile.writeAsBytes(
            optimizedImageData.buffer.asUint8List(),
          );

          stopwatch.stop();

          _logger.performance(
            'Optimize image',
            stopwatch.elapsed,
            data: {
              'originalPath': imageFile.path,
              'optimizedPath': optimizedFile.path,
              'originalSize': imageData.length,
              'optimizedSize': optimizedImageData.lengthInBytes,
              'compressionRatio':
                  (1 - optimizedImageData.lengthInBytes / imageData.length) *
                      100,
            },
          );

          return optimizedFile;
        }

        return null;
      },
    );
  }

  /// Preload images for better performance
  Future<void> preloadImages(List<String> imagePaths) async {
    await _errorHandler.handleAsyncError('Preload images', () async {
      _logger.info('Preloading ${imagePaths.length} images');

      final futures = imagePaths.map((path) async {
        if (path.startsWith('http')) {
          await precacheImage(NetworkImage(path),
              NavigationService.navigatorKey.currentContext!);
        } else {
          await precacheImage(
              AssetImage(path), NavigationService.navigatorKey.currentContext!);
        }
      });

      await Future.wait(futures);

      _logger.info('Preloaded ${imagePaths.length} images successfully');
    });
  }

  /// Get basic placeholder widget
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  /// Generate hash for cache key
  String _generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// Clean up old cache files
  Future<void> _cleanupOldCache() async {
    await _errorHandler.handleAsyncError('Cleanup old cache', () async {
      final now = DateTime.now();
      int deletedFiles = 0;
      int totalSize = 0;

      // Clean main cache
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await for (final entity in _cacheDir!.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            totalSize += stat.size;

            if (now.difference(stat.modified) > _cacheExpiration) {
              await entity.delete();
              deletedFiles++;
            }
          }
        }
      }

      // Clean thumbnail cache
      if (_thumbnailDir != null && await _thumbnailDir!.exists()) {
        await for (final entity in _thumbnailDir!.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            totalSize += stat.size;

            if (now.difference(stat.modified) > _cacheExpiration) {
              await entity.delete();
              deletedFiles++;
            }
          }
        }
      }

      if (deletedFiles > 0) {
        _logger.info('Cleaned up $deletedFiles old cache files');
      }

      _logger.debug(
          'Total cache size: ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB');
    });
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    await _errorHandler.handleAsyncError('Clear image cache', () async {
      // Clear local cache
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        await _cacheDir!.create(recursive: true);
      }

      // Clear thumbnail cache
      if (_thumbnailDir != null && await _thumbnailDir!.exists()) {
        await _thumbnailDir!.delete(recursive: true);
        await _thumbnailDir!.create(recursive: true);
      }

      _logger.info('All image caches cleared');
    });
  }

  /// Get cache size information
  Future<Map<String, dynamic>> getCacheInfo() async {
    return await _errorHandler.handleAsyncError(
      'Get cache info',
      () async {
        int totalFiles = 0;
        int totalSize = 0;

        // Count main cache
        if (_cacheDir != null && await _cacheDir!.exists()) {
          await for (final entity in _cacheDir!.list()) {
            if (entity is File) {
              final stat = await entity.stat();
              totalFiles++;
              totalSize += stat.size;
            }
          }
        }

        // Count thumbnail cache
        if (_thumbnailDir != null && await _thumbnailDir!.exists()) {
          await for (final entity in _thumbnailDir!.list()) {
            if (entity is File) {
              final stat = await entity.stat();
              totalFiles++;
              totalSize += stat.size;
            }
          }
        }

        return {
          'totalFiles': totalFiles,
          'totalSizeMB': (totalSize / 1024 / 1024).toStringAsFixed(2),
          'totalSizeBytes': totalSize,
          'cacheDir': _cacheDir?.path,
          'thumbnailDir': _thumbnailDir?.path,
        };
      },
      fallback: <String, dynamic>{},
    );
  }
}

/// Navigation service for accessing current context
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
