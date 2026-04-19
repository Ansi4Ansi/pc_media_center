import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pc_media_center/core/services/directory_scanner.dart';
import 'package:pc_media_center/presentation/widgets/scan_progress_dialog.dart';

void main() {
  group('ScanProgressDialog', () {
    late StreamController<ScanProgress> progressController;

    setUp(() {
      progressController = StreamController<ScanProgress>.broadcast();
    });

    tearDown(() {
      progressController.close();
    });

    testWidgets('should show progress indicator', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Emit a scanning progress
      progressController.add(ScanProgress(
        filesFound: 10,
        filesProcessed: 5,
        currentFile: '/movies/movie1.mp4',
        isComplete: false,
        elapsed: const Duration(seconds: 2),
      ));
      await tester.pump();

      // Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should show cancel button during scan', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Emit a scanning progress
      progressController.add(ScanProgress(
        filesFound: 10,
        filesProcessed: 5,
        isComplete: false,
        elapsed: const Duration(seconds: 2),
      ));
      await tester.pump();

      // Assert - should find cancel button with Russian text
      expect(find.text('Отмена'), findsOneWidget);
    });

    testWidgets('should show completion message when done', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Emit completion
      progressController.add(ScanProgress(
        filesFound: 10,
        filesProcessed: 10,
        isComplete: true,
        elapsed: const Duration(seconds: 5),
      ));
      await tester.pump();

      // Assert - should show completion message in Russian
      expect(find.text('Готово'), findsOneWidget);
    });

    testWidgets('should show scanned file count', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Emit a scanning progress
      progressController.add(ScanProgress(
        filesFound: 25,
        filesProcessed: 10,
        isComplete: false,
        elapsed: const Duration(seconds: 3),
      ));
      await tester.pump();

      // Assert - should show file count in Russian
      expect(find.textContaining('Найдено'), findsOneWidget);
      expect(find.textContaining('25'), findsOneWidget);
    });

    testWidgets('should show current file path', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Emit a scanning progress with current file
      progressController.add(ScanProgress(
        filesFound: 10,
        filesProcessed: 5,
        currentFile: '/movies/movie1.mp4',
        isComplete: false,
        elapsed: const Duration(seconds: 2),
      ));
      await tester.pump();

      // Assert - should show current file
      expect(find.textContaining('movie1.mp4'), findsOneWidget);
    });

    testWidgets('should call onCancel when cancel button pressed', (WidgetTester tester) async {
      // Arrange
      var cancelCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (_) {},
              onCancel: () => cancelCalled = true,
            ),
          ),
        ),
      );

      // Emit a scanning progress
      progressController.add(ScanProgress(
        filesFound: 10,
        filesProcessed: 5,
        isComplete: false,
        elapsed: const Duration(seconds: 2),
      ));
      await tester.pump();

      // Act
      await tester.tap(find.text('Отмена'));
      await tester.pump();

      // Assert
      expect(cancelCalled, isTrue);
    });

    testWidgets('should call onComplete with results when scan finishes', (WidgetTester tester) async {
      // Arrange
      ScanProgress? completedProgress;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (progress) => completedProgress = progress,
              onCancel: () {},
            ),
          ),
        ),
      );

      // Emit completion
      progressController.add(ScanProgress(
        filesFound: 10,
        filesProcessed: 10,
        isComplete: true,
        elapsed: const Duration(seconds: 5),
      ));
      await tester.pump();

      // Assert
      expect(completedProgress, isNotNull);
      expect(completedProgress!.isComplete, isTrue);
      expect(completedProgress!.filesFound, equals(10));
    });

    testWidgets('should show error message when scan fails', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Emit error state
      progressController.add(ScanProgress(
        filesFound: 5,
        filesProcessed: 5,
        isComplete: false,
        error: 'Permission denied',
        elapsed: const Duration(seconds: 2),
      ));
      await tester.pump();

      // Assert - should show error
      expect(find.textContaining('Ошибка'), findsOneWidget);
    });

    testWidgets('should show elapsed time', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Emit a scanning progress
      progressController.add(ScanProgress(
        filesFound: 10,
        filesProcessed: 5,
        isComplete: false,
        elapsed: const Duration(seconds: 30),
      ));
      await tester.pump();

      // Assert - should show elapsed time
      expect(find.textContaining('Время'), findsOneWidget);
    });

    testWidgets('should have correct dialog title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScanProgressDialog(
              scanStream: progressController.stream,
              onComplete: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );

      // Assert - should have Russian title (shown immediately)
      expect(find.text('Сканирование директории'), findsOneWidget);
    });
  });
}
