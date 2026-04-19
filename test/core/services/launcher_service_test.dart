import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
}
