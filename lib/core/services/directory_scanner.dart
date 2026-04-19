import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

/// Exception thrown by DirectoryScanner
class DirectoryScannerException implements Exception {
  final String message;
  final String? path;

  const DirectoryScannerException(this.message, {this.path});

  @override
  String toString() => 'DirectoryScannerException: $message${path != null ? ' (path: $path)' : ''}';
}

/// Configuration options for directory scanning
class ScanOptions extends Equatable {
  final List<String> extensions;
  final bool recursive;
  final int? maxDepth;
  final int maxFiles;
  final bool followSymlinks;

  const ScanOptions({
    this.extensions = const [],
    this.recursive = true,
    this.maxDepth,
    this.maxFiles = 10000,
    this.followSymlinks = false,
  });

  @override
  List<Object?> get props => [extensions, recursive, maxDepth, maxFiles, followSymlinks];
}

/// Metadata extracted from a filename
class ExtractedMetadata extends Equatable {
  final String title;
  final int? year;
  final String? resolution;
  final String? source;
  final String originalFilename;

  const ExtractedMetadata({
    required this.title,
    this.year,
    this.resolution,
    this.source,
    required this.originalFilename,
  });

  @override
  List<Object?> get props => [title, year, resolution, source, originalFilename];
}

/// Represents a scanned file with its metadata
class ScannedFile extends Equatable {
  final String path;
  final String filename;
  final String extension;
  final int fileSize;
  final DateTime modifiedAt;
  final ExtractedMetadata metadata;

  const ScannedFile({
    required this.path,
    required this.filename,
    required this.extension,
    required this.fileSize,
    required this.modifiedAt,
    required this.metadata,
  });

  @override
  List<Object?> get props => [path, filename, extension, fileSize, modifiedAt, metadata];
}

/// Progress update during directory scanning
class ScanProgress extends Equatable {
  final int filesFound;
  final int filesProcessed;
  final String? currentFile;
  final bool isComplete;
  final String? error;
  final Duration elapsed;

  const ScanProgress({
    required this.filesFound,
    required this.filesProcessed,
    this.currentFile,
    required this.isComplete,
    this.error,
    required this.elapsed,
  });

  @override
  List<Object?> get props =>
      [filesFound, filesProcessed, currentFile, isComplete, error, elapsed];
}

/// Service for scanning directories and extracting file metadata
class DirectoryScanner {
  final Set<String> _scannedPaths = {};

  /// Create a cancellation token for scan operations
  Completer<void> createCancellationToken() => Completer<void>();

  /// Cancel an ongoing scan
  void cancelScan(Completer<void> token) {
    if (!token.isCompleted) {
      token.complete();
    }
  }

  /// Synchronous directory scan - returns all results at once
  List<ScannedFile> scanDirectorySync(String path, ScanOptions options) {
    final results = <ScannedFile>[];
    final stopwatch = Stopwatch()..start();

    // Validate directory exists
    final dir = Directory(path);
    if (!dir.existsSync()) {
      throw DirectoryScannerException('Directory not found', path: path);
    }

    // Use BFS for breadth-first scanning
    final queue = Queue<_ScanEntry>();
    queue.add(_ScanEntry(dir, 0));

    while (queue.isNotEmpty) {
      final entry = queue.removeFirst();
      final currentDir = entry.directory;
      final currentDepth = entry.depth;

      // Check max depth
      if (options.maxDepth != null && currentDepth > options.maxDepth!) {
        continue;
      }

      try {
        final entities = currentDir.listSync(followLinks: options.followSymlinks);

        for (final entity in entities) {
          // Check cancellation

          final filename = p.basename(entity.path);

          // Skip hidden files
          if (filename.startsWith('.')) {
            continue;
          }

          // Skip system directories
          if (_isSystemDirectory(filename)) {
            continue;
          }

          if (entity is File) {
            // Check extension match
            if (_matchesExtension(entity.path, options.extensions)) {
              final stat = entity.statSync();
              final metadata = extractMetadata(filename);

              results.add(ScannedFile(
                path: entity.path,
                filename: filename,
                extension: p.extension(filename).toLowerCase(),
                fileSize: stat.size,
                modifiedAt: stat.modified,
                metadata: metadata,
              ));

              // Check max files limit
              if (results.length >= options.maxFiles) {
                stopwatch.stop();
                return results;
              }
            }
          } else if (entity is Directory && options.recursive) {
            // Check if it's a symlink
            if (!options.followSymlinks && FileSystemEntity.isLinkSync(entity.path)) {
              continue;
            }
            queue.add(_ScanEntry(entity, currentDepth + 1));
          }
        }
      } on FileSystemException catch (_) {
        // Continue scanning other directories on permission errors
        continue;
      }
    }

    stopwatch.stop();
    return results;
  }

  /// Asynchronous directory scan with progress updates
  Stream<ScanProgress> scanDirectory(
    String path,
    ScanOptions options, {
    Completer<void>? cancellationToken,
  }) async* {
    final stopwatch = Stopwatch()..start();
    final results = <ScannedFile>[];

    // Validate directory exists
    final dir = Directory(path);
    if (!await dir.exists()) {
      throw DirectoryScannerException('Directory not found', path: path);
    }

    // Use BFS for breadth-first scanning
    final queue = Queue<_ScanEntry>();
    queue.add(_ScanEntry(dir, 0));

    while (queue.isNotEmpty) {
      // Check cancellation
      if (cancellationToken?.isCompleted ?? false) {
        stopwatch.stop();
        yield ScanProgress(
          filesFound: results.length,
          filesProcessed: results.length,
          isComplete: false,
          elapsed: stopwatch.elapsed,
          error: 'Scan cancelled by user',
        );
        return;
      }

      final entry = queue.removeFirst();
      final currentDir = entry.directory;
      final currentDepth = entry.depth;

      // Check max depth
      if (options.maxDepth != null && currentDepth > options.maxDepth!) {
        continue;
      }

      try {
        await for (final entity in currentDir.list(followLinks: options.followSymlinks)) {
          // Check cancellation
          if (cancellationToken?.isCompleted ?? false) {
            stopwatch.stop();
            yield ScanProgress(
              filesFound: results.length,
              filesProcessed: results.length,
              isComplete: false,
              elapsed: stopwatch.elapsed,
              error: 'Scan cancelled by user',
            );
            return;
          }

          final filename = p.basename(entity.path);

          // Skip hidden files
          if (filename.startsWith('.')) {
            continue;
          }

          // Skip system directories
          if (_isSystemDirectory(filename)) {
            continue;
          }

          if (entity is File) {
            // Check extension match
            if (_matchesExtension(entity.path, options.extensions)) {
              final stat = await entity.stat();
              final metadata = extractMetadata(filename);

              final scannedFile = ScannedFile(
                path: entity.path,
                filename: filename,
                extension: p.extension(filename).toLowerCase(),
                fileSize: stat.size,
                modifiedAt: stat.modified,
                metadata: metadata,
              );

              results.add(scannedFile);

              // Yield progress update
              yield ScanProgress(
                filesFound: results.length,
                filesProcessed: results.length,
                currentFile: entity.path,
                isComplete: false,
                elapsed: stopwatch.elapsed,
              );

              // Check max files limit
              if (results.length >= options.maxFiles) {
                stopwatch.stop();
                yield ScanProgress(
                  filesFound: results.length,
                  filesProcessed: results.length,
                  isComplete: true,
                  elapsed: stopwatch.elapsed,
                );
                return;
              }
            }
          } else if (entity is Directory && options.recursive) {
            // Check if it's a symlink
            if (!options.followSymlinks) {
              try {
                final link = Link(entity.path);
                if (await link.exists()) {
                  continue;
                }
              } catch (_) {
                // Not a link, continue
              }
            }
            queue.add(_ScanEntry(entity, currentDepth + 1));
          }
        }
      } on FileSystemException catch (_) {
        // Continue scanning other directories on permission errors
        continue;
      }
    }

    stopwatch.stop();
    yield ScanProgress(
      filesFound: results.length,
      filesProcessed: results.length,
      isComplete: true,
      elapsed: stopwatch.elapsed,
    );
  }

  /// Extract metadata from a filename
  ExtractedMetadata extractMetadata(String filename) {
    // Remove extension
    final nameWithoutExt = p.basenameWithoutExtension(filename);
    final extension = p.extension(filename);

    // Special case: if filename starts with dot and has no real extension
    // (e.g., ".mp4" is a hidden file, not a file with .mp4 extension)
    // In this case, nameWithoutExt will be the same as filename
    if (filename.startsWith('.') && (nameWithoutExt == filename || extension.isEmpty)) {
      return ExtractedMetadata(
        title: filename,
        year: null,
        resolution: null,
        source: null,
        originalFilename: filename,
      );
    }

    // Extract year (4 digits between 1900-2030)
    // Use lookbehind/lookahead to match years surrounded by separators, parentheses, brackets, or string boundaries
    final yearMatch = RegExp(r'(?:^|[^\d])(19|20)\d{2}(?:[^\d]|$)').firstMatch(nameWithoutExt);
    int? year;
    if (yearMatch != null) {
      // Extract just the 4-digit year from the match
      final fullMatch = yearMatch.group(0)!;
      final yearStr = RegExp(r'(19|20)\d{2}').firstMatch(fullMatch)?.group(0);
      if (yearStr != null) {
        final yearValue = int.parse(yearStr);
        // Validate year range
        if (yearValue >= 1900 && yearValue <= 2030) {
          year = yearValue;
        }
      }
    }

    // Extract resolution (preserve original case)
    final resolutionMatch = RegExp(
      r'\b(480p|720p|1080p|2160p|4K|360p)\b',
      caseSensitive: false,
    ).firstMatch(nameWithoutExt);
    final resolution = resolutionMatch?.group(0);

    // Extract source (preserve original case)
    final sourceMatch = RegExp(
      r'\b(BluRay|WEB-?DL|WEBRip|HDRip|BRRip|DVDRip|HDTV|CAM|TS|DVD)\b',
      caseSensitive: false,
    ).firstMatch(nameWithoutExt);
    final source = sourceMatch?.group(0);

    // Clean title - start with name without extension
    var cleanTitle = nameWithoutExt;

    // Remove year FIRST (before any other processing)
    if (year != null) {
      cleanTitle = cleanTitle.replaceAll(year.toString(), '');
    }

    // Remove bracketed content [tag]
    cleanTitle = cleanTitle.replaceAll(RegExp(r'\[.*?\]'), '');

    // Remove parenthesized content (tag)
    cleanTitle = cleanTitle.replaceAll(RegExp(r'\(.*?\)'), '');

    // Remove resolution tags
    cleanTitle = cleanTitle.replaceAll(
      RegExp(r'\b(480p|720p|1080p|2160p|4K|360p)\b', caseSensitive: false),
      '',
    );

    // Remove source tags
    cleanTitle = cleanTitle.replaceAll(
      RegExp(
        r'\b(BluRay|WEB-?DL|WEBRip|HDRip|BRRip|DVDRip|HDTV|CAM|TS|DVD|REMUX|PROPER|REPACK|EXTENDED|UNRATED|DC)\b',
        caseSensitive: false,
      ),
      '',
    );

    // Remove encoder tags
    cleanTitle = cleanTitle.replaceAll(
      RegExp(
        r'\b(x264|x265|H264|H265|AVC|HEVC|MPEG|DivX|XviD|AAC|DTS|AC3|Dolby)\b',
        caseSensitive: false,
      ),
      '',
    );

    // Remove release group tags (typically at the end)
    cleanTitle = cleanTitle.replaceAll(
      RegExp(r'\b(YIFY|RARBG|SPARKS|EVO|GECKOS|DRONES|ROVERS)\b', caseSensitive: false),
      '',
    );

    // Replace separators with spaces
    cleanTitle = cleanTitle.replaceAll(RegExp(r'[._-]+'), ' ');

    // Remove extra spaces
    cleanTitle = cleanTitle.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Convert to title case
    cleanTitle = _toTitleCase(cleanTitle);

    // If title is empty or just whitespace, use original filename (without extension)
    if (cleanTitle.isEmpty || cleanTitle.trim().isEmpty) {
      cleanTitle = nameWithoutExt;
    }

    return ExtractedMetadata(
      title: cleanTitle,
      year: year,
      resolution: resolution,
      source: source,
      originalFilename: filename,
    );
  }

  /// Check if a path is a duplicate (already scanned)
  bool isDuplicate(String path, int categoryId) {
    final normalizedPath = path.toLowerCase();
    return _scannedPaths.contains(normalizedPath);
  }

  /// Mark a path as scanned
  void markAsScanned(String path) {
    _scannedPaths.add(path.toLowerCase());
  }

  /// Clear the scanned paths cache
  void clearScannedPaths() {
    _scannedPaths.clear();
  }

  /// Check if filename matches any of the specified extensions
  bool _matchesExtension(String path, List<String> extensions) {
    if (extensions.isEmpty) {
      return true; // No filtering if no extensions specified
    }

    final ext = p.extension(path).toLowerCase();
    final filename = p.basename(path).toLowerCase();

    for (final pattern in extensions) {
      final normalizedPattern = pattern.toLowerCase().trim();
      final patternWithDot = normalizedPattern.startsWith('.')
          ? normalizedPattern
          : '.$normalizedPattern';

      // Match the extension (p.extension returns with leading dot)
      if (ext == patternWithDot) {
        return true;
      }
      // Also check if filename ends with the pattern (for case variations)
      if (filename.endsWith(patternWithDot)) {
        return true;
      }
      // Check without the dot for patterns like "mp4" matching ".mp4"
      final patternWithoutDot = patternWithDot.substring(1);
      if (ext == '.$patternWithoutDot') {
        return true;
      }
    }

    return false;
  }

  /// Check if a directory is a system directory that should be skipped
  bool _isSystemDirectory(String name) {
    final systemDirs = {
      'system volume information',
      '\$recycle.bin',
      'recycler',
      'config.msi',
      'msocache',
      'windows',
      'program files',
      'program files (x86)',
      'programdata',
    };

    return systemDirs.contains(name.toLowerCase());
  }

  /// Convert string to title case
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;

    final words = text.split(' ');
    final result = <String>[];

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      if (word.isEmpty) continue;

      // Keep small words lowercase unless they're the first word
      final smallWords = {'a', 'an', 'the', 'and', 'but', 'or', 'for', 'nor', 'on', 'at', 'to', 'from', 'in', 'of'};

      if (i > 0 && smallWords.contains(word.toLowerCase())) {
        result.add(word.toLowerCase());
      } else {
        result.add(word[0].toUpperCase() + word.substring(1).toLowerCase());
      }
    }

    return result.join(' ');
  }
}

/// Internal class for BFS queue entries
class _ScanEntry {
  final Directory directory;
  final int depth;

  _ScanEntry(this.directory, this.depth);
}
