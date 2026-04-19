import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/services/directory_scanner.dart';

/// Dialog that displays scan progress with Russian UI text
class ScanProgressDialog extends StatefulWidget {
  final Stream<ScanProgress> scanStream;
  final ValueChanged<ScanProgress> onComplete;
  final VoidCallback onCancel;

  const ScanProgressDialog({
    super.key,
    required this.scanStream,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<ScanProgressDialog> createState() => _ScanProgressDialogState();
}

class _ScanProgressDialogState extends State<ScanProgressDialog> {
  ScanProgress? _currentProgress;
  StreamSubscription<ScanProgress>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToStream();
  }

  void _subscribeToStream() {
    _subscription = widget.scanStream.listen(
      (progress) {
        setState(() {
          _currentProgress = progress;
        });

        if (progress.isComplete) {
          widget.onComplete(progress);
        }
      },
      onError: (error) {
        setState(() {
          _currentProgress = ScanProgress(
            filesFound: _currentProgress?.filesFound ?? 0,
            filesProcessed: _currentProgress?.filesProcessed ?? 0,
            isComplete: false,
            error: error.toString(),
            elapsed: _currentProgress?.elapsed ?? Duration.zero,
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  String _getCurrentFileName() {
    final currentFile = _currentProgress?.currentFile;
    if (currentFile == null || currentFile.isEmpty) {
      return '';
    }
    // Extract just the filename from the path
    final parts = currentFile.split('/');
    return parts.isNotEmpty ? parts.last : currentFile;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentProgress;
    final isComplete = progress?.isComplete ?? false;
    final hasError = progress?.error != null && progress!.error!.isNotEmpty;
    final isScanning = progress != null && !isComplete && !hasError;

    return AlertDialog(
      title: const Text('Сканирование директории'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isScanning) ...[
              // Progress indicator
              LinearProgressIndicator(
                value: progress!.filesFound > 0
                    ? progress.filesProcessed / progress.filesFound
                    : null,
              ),
              const SizedBox(height: 16),

              // Statistics
              Text(
                'Найдено: ${progress.filesFound} файлов, Обработано: ${progress.filesProcessed}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),

              // Current file
              if (progress.currentFile != null) ...[
                Text(
                  'Текущий файл:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                Text(
                  _getCurrentFileName(),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],

              // Elapsed time
              Text(
                'Время: ${_formatDuration(progress.elapsed)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ] else if (isComplete) ...[
              // Completion message
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Сканирование завершено',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Найдено файлов: ${progress!.filesFound}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Затраченное время: ${_formatDuration(progress.elapsed)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else if (hasError) ...[
              // Error message
              Icon(
                Icons.error,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Ошибка при сканировании',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                progress!.error!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              // Initial state
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Подготовка к сканированию...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (isScanning)
          TextButton(
            onPressed: () {
              widget.onCancel();
              Navigator.of(context).pop();
            },
            child: const Text('Отмена'),
          )
        else if (isComplete)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Готово'),
          )
        else if (hasError)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Закрыть'),
          ),
      ],
    );
  }
}
