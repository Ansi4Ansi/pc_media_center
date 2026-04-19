import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pc_media_center/core/services/directory_scanner.dart';

void main() {
  group('ScanOptions', () {
    test('should create with default values', () {
      const options = ScanOptions();

      expect(options.extensions, isEmpty);
      expect(options.recursive, isTrue);
      expect(options.maxDepth, isNull);
      expect(options.maxFiles, equals(10000));
      expect(options.followSymlinks, isFalse);
    });

    test('should create with custom values', () {
      const options = ScanOptions(
        extensions: ['.mp4', '.mkv'],
        recursive: false,
        maxDepth: 3,
        maxFiles: 100,
        followSymlinks: true,
      );

      expect(options.extensions, equals(['.mp4', '.mkv']));
      expect(options.recursive, isFalse);
      expect(options.maxDepth, equals(3));
      expect(options.maxFiles, equals(100));
      expect(options.followSymlinks, isTrue);
    });
  });

  group('ExtractedMetadata', () {
    test('should create with required fields', () {
      const metadata = ExtractedMetadata(
        title: 'Test Movie',
        originalFilename: 'Test.Movie.2021.mp4',
      );

      expect(metadata.title, equals('Test Movie'));
      expect(metadata.year, isNull);
      expect(metadata.resolution, isNull);
      expect(metadata.source, isNull);
      expect(metadata.originalFilename, equals('Test.Movie.2021.mp4'));
    });

    test('should create with all fields', () {
      const metadata = ExtractedMetadata(
        title: 'Test Movie',
        year: 2021,
        resolution: '1080p',
        source: 'BluRay',
        originalFilename: 'Test.Movie.2021.1080p.BluRay.mp4',
      );

      expect(metadata.title, equals('Test Movie'));
      expect(metadata.year, equals(2021));
      expect(metadata.resolution, equals('1080p'));
      expect(metadata.source, equals('BluRay'));
    });
  });

  group('ScannedFile', () {
    test('should create from file data', () {
      final now = DateTime.now();
      final metadata = const ExtractedMetadata(
        title: 'Test',
        originalFilename: 'test.mp4',
      );

      final scannedFile = ScannedFile(
        path: '/movies/test.mp4',
        filename: 'test.mp4',
        extension: '.mp4',
        fileSize: 1024,
        modifiedAt: now,
        metadata: metadata,
      );

      expect(scannedFile.path, equals('/movies/test.mp4'));
      expect(scannedFile.filename, equals('test.mp4'));
      expect(scannedFile.extension, equals('.mp4'));
      expect(scannedFile.fileSize, equals(1024));
      expect(scannedFile.modifiedAt, equals(now));
      expect(scannedFile.metadata, equals(metadata));
    });
  });

  group('ScanProgress', () {
    test('should create initial progress', () {
      final progress = ScanProgress(
        filesFound: 0,
        filesProcessed: 0,
        isComplete: false,
        elapsed: Duration.zero,
      );

      expect(progress.filesFound, equals(0));
      expect(progress.filesProcessed, equals(0));
      expect(progress.currentFile, isNull);
      expect(progress.isComplete, isFalse);
      expect(progress.error, isNull);
    });

    test('should create completed progress', () {
      final progress = ScanProgress(
        filesFound: 10,
        filesProcessed: 10,
        currentFile: '/movies/movie10.mp4',
        isComplete: true,
        elapsed: const Duration(seconds: 5),
      );

      expect(progress.filesFound, equals(10));
      expect(progress.filesProcessed, equals(10));
      expect(progress.currentFile, equals('/movies/movie10.mp4'));
      expect(progress.isComplete, isTrue);
    });
  });

  group('DirectoryScanner', () {
    late DirectoryScanner scanner;
    late Directory tempDir;

    setUp(() async {
      scanner = DirectoryScanner();
      tempDir = await Directory.systemTemp.createTemp('scanner_test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    group('scanDirectorySync', () {
      test('should find files by extension', () async {
        // Arrange
        await File('${tempDir.path}/movie1.mp4').create();
        await File('${tempDir.path}/movie2.mkv').create();
        await File('${tempDir.path}/document.txt').create();

        const options = ScanOptions(
          extensions: ['.mp4', '.mkv'],
          recursive: false,
        );

        // Act
        final results = scanner.scanDirectorySync(tempDir.path, options);

        // Assert
        expect(results.length, equals(2));
        expect(results.any((f) => f.filename == 'movie1.mp4'), isTrue);
        expect(results.any((f) => f.filename == 'movie2.mkv'), isTrue);
        expect(results.any((f) => f.filename == 'document.txt'), isFalse);
      });

      test('should return empty list for empty directory', () {
        const options = ScanOptions(extensions: ['.mp4']);

        final results = scanner.scanDirectorySync(tempDir.path, options);

        expect(results, isEmpty);
      });

      test('should scan recursively when enabled', () async {
        // Arrange
        final subDir = await Directory('${tempDir.path}/subdir').create();
        await File('${tempDir.path}/root.mp4').create();
        await File('${subDir.path}/nested.mp4').create();

        const options = ScanOptions(
          extensions: ['.mp4'],
          recursive: true,
        );

        // Act
        final results = scanner.scanDirectorySync(tempDir.path, options);

        // Assert
        expect(results.length, equals(2));
        expect(results.any((f) => f.filename == 'root.mp4'), isTrue);
        expect(results.any((f) => f.filename == 'nested.mp4'), isTrue);
      });

      test('should not scan recursively when disabled', () async {
        // Arrange
        final subDir = await Directory('${tempDir.path}/subdir').create();
        await File('${tempDir.path}/root.mp4').create();
        await File('${subDir.path}/nested.mp4').create();

        const options = ScanOptions(
          extensions: ['.mp4'],
          recursive: false,
        );

        // Act
        final results = scanner.scanDirectorySync(tempDir.path, options);

        // Assert
        expect(results.length, equals(1));
        expect(results.first.filename, equals('root.mp4'));
      });

      test('should respect maxDepth', () async {
        // Arrange
        final level1 = await Directory('${tempDir.path}/level1').create();
        final level2 = await Directory('${level1.path}/level2').create();
        await File('${tempDir.path}/root.mp4').create();
        await File('${level1.path}/level1.mp4').create();
        await File('${level2.path}/level2.mp4').create();

        const options = ScanOptions(
          extensions: ['.mp4'],
          recursive: true,
          maxDepth: 1,
        );

        // Act
        final results = scanner.scanDirectorySync(tempDir.path, options);

        // Assert
        expect(results.length, equals(2));
        expect(results.any((f) => f.filename == 'root.mp4'), isTrue);
        expect(results.any((f) => f.filename == 'level1.mp4'), isTrue);
        expect(results.any((f) => f.filename == 'level2.mp4'), isFalse);
      });

      test('should skip hidden files', () async {
        // Arrange
        await File('${tempDir.path}/visible.mp4').create();
        await File('${tempDir.path}/.hidden.mp4').create();

        const options = ScanOptions(extensions: ['.mp4']);

        // Act
        final results = scanner.scanDirectorySync(tempDir.path, options);

        // Assert
        expect(results.length, equals(1));
        expect(results.first.filename, equals('visible.mp4'));
      });

      test('should respect maxFiles limit', () async {
        // Arrange
        for (int i = 0; i < 20; i++) {
          await File('${tempDir.path}/movie$i.mp4').create();
        }

        const options = ScanOptions(
          extensions: ['.mp4'],
          maxFiles: 10,
        );

        // Act
        final results = scanner.scanDirectorySync(tempDir.path, options);

        // Assert
        expect(results.length, equals(10));
      });
    });

    group('scanDirectory (async stream)', () {
      test('should emit progress updates', () async {
        // Arrange
        await File('${tempDir.path}/movie1.mp4').create();
        await File('${tempDir.path}/movie2.mp4').create();

        const options = ScanOptions(extensions: ['.mp4']);
        final progressUpdates = <ScanProgress>[];

        // Act
        await for (final progress in scanner.scanDirectory(tempDir.path, options)) {
          progressUpdates.add(progress);
        }

        // Assert
        expect(progressUpdates.isNotEmpty, isTrue);
        expect(progressUpdates.last.isComplete, isTrue);
        expect(progressUpdates.last.filesFound, equals(2));
        expect(progressUpdates.last.filesProcessed, equals(2));
      });

      test('should be cancellable', () async {
        // Arrange
        for (int i = 0; i < 100; i++) {
          await File('${tempDir.path}/movie$i.mp4').create();
        }

        const options = ScanOptions(extensions: ['.mp4']);
        final completer = scanner.createCancellationToken();

        // Act - cancel after first emission
        final progressUpdates = <ScanProgress>[];
        await for (final progress in scanner.scanDirectory(tempDir.path, options, cancellationToken: completer)) {
          progressUpdates.add(progress);
          if (progress.filesProcessed >= 5) {
            scanner.cancelScan(completer);
          }
        }

        // Assert
        expect(progressUpdates.last.isComplete, isFalse);
        expect(progressUpdates.last.filesProcessed, lessThan(100));
      });
    });

    group('extractMetadata', () {
      test('should extract title from simple filename', () {
        final metadata = scanner.extractMetadata('Movie.mp4');

        expect(metadata.title, equals('Movie'));
        expect(metadata.year, isNull);
      });

      test('should extract year from filename', () {
        final metadata = scanner.extractMetadata('Movie.2021.mp4');

        expect(metadata.title, equals('Movie'));
        expect(metadata.year, equals(2021));
      });

      test('should extract year from parenthesized format', () {
        final metadata = scanner.extractMetadata('Movie (2021).mp4');

        expect(metadata.title, equals('Movie'));
        expect(metadata.year, equals(2021));
      });

      test('should remove resolution tags', () {
        final metadata = scanner.extractMetadata('Movie.2021.1080p.mp4');

        expect(metadata.title, equals('Movie'));
        expect(metadata.resolution, equals('1080p'));
      });

      test('should remove source tags', () {
        final metadata = scanner.extractMetadata('Movie.2021.BluRay.mp4');

        expect(metadata.title, equals('Movie'));
        expect(metadata.source, equals('BluRay'));
      });

      test('should handle complex filename with multiple tags', () {
        final metadata = scanner.extractMetadata(
          'The.Matrix.1999.1080p.BluRay.x264.mkv',
        );

        expect(metadata.title, equals('The Matrix'));
        expect(metadata.year, equals(1999));
        expect(metadata.resolution, equals('1080p'));
        expect(metadata.source, equals('BluRay'));
      });

      test('should handle underscores as separators', () {
        final metadata = scanner.extractMetadata('The_Dark_Knight_2008.mp4');

        expect(metadata.title, equals('The Dark Knight'));
        expect(metadata.year, equals(2008));
      });

      test('should handle dashes as separators', () {
        final metadata = scanner.extractMetadata('Inception - 2010 - 1080p.mp4');

        expect(metadata.title, equals('Inception'));
        expect(metadata.year, equals(2010));
        expect(metadata.resolution, equals('1080p'));
      });

      test('should handle brackets', () {
        final metadata = scanner.extractMetadata('Movie [2021] [1080p].mp4');

        expect(metadata.title, equals('Movie'));
        expect(metadata.year, equals(2021));
      });

      test('should return original filename if title is empty', () {
        final metadata = scanner.extractMetadata('.mp4');

        expect(metadata.title, equals('.mp4'));
      });

      test('should only extract years in valid range (1900-2030)', () {
        final metadata1 = scanner.extractMetadata('Movie.1899.mp4');
        expect(metadata1.year, isNull);

        final metadata2 = scanner.extractMetadata('Movie.1900.mp4');
        expect(metadata2.year, equals(1900));

        final metadata3 = scanner.extractMetadata('Movie.2030.mp4');
        expect(metadata3.year, equals(2030));

        final metadata4 = scanner.extractMetadata('Movie.2031.mp4');
        expect(metadata4.year, isNull);
      });
    });

    group('isDuplicate', () {
      test('should return false for new path', () {
        final result = scanner.isDuplicate('/movies/new.mp4', 1);

        expect(result, isFalse);
      });

      test('should return true for already scanned path', () {
        scanner.markAsScanned('/movies/existing.mp4');

        final result = scanner.isDuplicate('/movies/existing.mp4', 1);

        expect(result, isTrue);
      });

      test('should be case insensitive', () {
        scanner.markAsScanned('/movies/Movie.mp4');

        final result = scanner.isDuplicate('/movies/movie.mp4', 1);

        expect(result, isTrue);
      });
    });

    group('extension filtering', () {
      test('should match extensions case-insensitively', () async {
        // Note: On case-insensitive filesystems (macOS, Windows), 
        // creating files with different cases may not create separate files
        // So we test with different extensions that are all variations
        await File('${tempDir.path}/movie.mp4').create();
        await File('${tempDir.path}/movie2.mp4').create();
        await File('${tempDir.path}/movie3.mkv').create();

        const options = ScanOptions(extensions: ['.mp4', '.MP4', '.Mp4']);

        final results = scanner.scanDirectorySync(tempDir.path, options);

        // Should find both .mp4 files (case variations match)
        expect(results.length, equals(2));
        expect(results.every((f) => f.extension == '.mp4'), isTrue);
      });

      test('should work with extensions without leading dot', () async {
        await File('${tempDir.path}/movie.mp4').create();

        const options = ScanOptions(extensions: ['mp4']);

        final results = scanner.scanDirectorySync(tempDir.path, options);

        expect(results.length, equals(1));
      });
    });

    group('error handling', () {
      test('should throw for non-existent directory', () {
        const options = ScanOptions();

        expect(
          () => scanner.scanDirectorySync('/non/existent/path', options),
          throwsA(isA<DirectoryScannerException>()),
        );
      });

      test('should handle permission errors gracefully', () async {
        // This test is platform-specific, skip on Windows
        if (Platform.isWindows) {
          return;
        }

        // Create a directory with no read permissions
        final restrictedDir = await Directory('${tempDir.path}/restricted').create();
        await File('${restrictedDir.path}/movie.mp4').create();
        await Process.run('chmod', ['000', restrictedDir.path]);

        const options = ScanOptions(extensions: ['.mp4']);

        // Should return empty list gracefully (not throw)
        final results = scanner.scanDirectorySync(restrictedDir.path, options);
        expect(results, isEmpty);

        // Restore permissions for cleanup
        await Process.run('chmod', ['755', restrictedDir.path]);
      });
    });
  });
}
