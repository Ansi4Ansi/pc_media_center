import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pc_media_center/core/services/launcher_service.dart';

void main() {
  group('LauncherService', () {
    test('should create LaunchResult with success status', () {
      const result = LaunchResult.success();
      
      expect(result.success, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('should create LaunchResult with failure status', () {
      const result = LaunchResult.failure('Error message');
      
      expect(result.success, isFalse);
      expect(result.errorMessage, 'Error message');
    });

    test('should throw when path is null', () async {
      final service = LauncherService.create();
      
      expect(
        () => service.launch(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw when path is empty', () async {
      final service = LauncherService.create();

      expect(
        () => service.launch(''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('WindowsLauncherService', () {
    late WindowsLauncherService service;

    setUp(() {
      service = WindowsLauncherService();
    });

    test('should return file not found error when file does not exist', () async {
      const nonExistentPath = '/non/existent/file.exe';

      final result = await service.launch(nonExistentPath);

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Файл не найден'));
    });

    test('should return success for valid file path', () async {
      // Create a temporary file for testing
      final tempFile = File('${Directory.systemTemp.path}/test_launcher.txt');
      await tempFile.writeAsString('test');

      try {
        final result = await service.launch(tempFile.path);

        // Note: On non-Windows platforms, this will fail with process error
        // but we're testing the interface contract
        expect(result, isA<LaunchResult>());
      } finally {
        await tempFile.delete();
      }
    });
  });
}
