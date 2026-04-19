import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerButton extends StatelessWidget {
  final String? selectedPath;
  final ValueChanged<String?> onPathSelected;
  final String label;
  final List<String>? allowedExtensions;
  final bool allowMultiple;

  const FilePickerButton({
    super.key,
    this.selectedPath,
    required this.onPathSelected,
    required this.label,
    this.allowedExtensions,
    this.allowMultiple = false,
  });

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          onPathSelected(path);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выборе файла: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSelection() {
    onPathSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickFile(context),
                icon: const Icon(Icons.folder_open),
                label: const Text('Выбрать файл'),
              ),
            ),
            if (selectedPath != null) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: _clearSelection,
                icon: const Icon(Icons.clear),
                tooltip: 'Очистить',
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          selectedPath ?? 'Файл не выбран',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selectedPath != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.outline,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
