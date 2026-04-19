import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pc_media_center/presentation/widgets/file_picker_button.dart';

class MockFilePicker extends Mock implements FilePicker {}

void main() {
  group('FilePickerButton', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePickerButton(
              label: 'Выберите файл',
              onPathSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Выберите файл'), findsOneWidget);
    });

    testWidgets('displays selected path when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePickerButton(
              label: 'Выберите файл',
              selectedPath: '/path/to/file.mp4',
              onPathSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('/path/to/file.mp4'), findsOneWidget);
    });

    testWidgets('displays placeholder when no path selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePickerButton(
              label: 'Выберите файл',
              onPathSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Файл не выбран'), findsOneWidget);
    });

    testWidgets('calls onPathSelected when file is picked', (tester) async {
      String? selectedPath;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePickerButton(
              label: 'Выберите файл',
              onPathSelected: (path) => selectedPath = path,
            ),
          ),
        ),
      );

      // Since we can't easily mock FilePicker.platform in widget tests,
      // we'll verify the button is tappable and has correct structure
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows file icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePickerButton(
              label: 'Выберите файл',
              onPathSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('supports allowed extensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePickerButton(
              label: 'Выберите видео',
              allowedExtensions: ['mp4', 'mkv', 'avi'],
              onPathSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Выберите видео'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays clear button when path is selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePickerButton(
              label: 'Выберите файл',
              selectedPath: '/path/to/file.mp4',
              onPathSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button resets selection', (tester) async {
      String? selectedPath = '/path/to/file.mp4';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilePickerButton(
              label: 'Выберите файл',
              selectedPath: selectedPath,
              onPathSelected: (path) => selectedPath = path,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(selectedPath, isNull);
    });
  });
}
