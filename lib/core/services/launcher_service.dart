import 'dart:io';

/// Result of a launch operation
class LaunchResult {
  final bool success;
  final String? errorMessage;

  const LaunchResult._({required this.success, this.errorMessage});

  const LaunchResult.success() : this._(success: true);
  
  const LaunchResult.failure(String message) 
      : this._(success: false, errorMessage: message);
}

/// Interface for launching files across platforms
abstract class LauncherService {
  /// Launch a file or program at the given path
  Future<LaunchResult> launch(String path, {String? arguments});

  /// Factory to create platform-specific implementation
  factory LauncherService.create() {
    if (Platform.isWindows) {
      return WindowsLauncherService();
    } else if (Platform.isLinux) {
      return LinuxLauncherService();
    } else if (Platform.isMacOS) {
      return MacOSLauncherService();
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}

/// Windows implementation using cmd start command
class WindowsLauncherService implements LauncherService {
  @override
  Future<LaunchResult> launch(String path, {String? arguments}) async {
    // Validate path
    if (path.isEmpty) {
      throw ArgumentError('Path cannot be empty');
    }

    // Check if file exists
    final file = File(path);
    if (!await file.exists()) {
      return LaunchResult.failure('Файл не найден: $path');
    }

    try {
      // Use cmd /c start to launch file with default associated program
      final result = await Process.run(
        'cmd',
        ['/c', 'start', '', path],
        runInShell: false,
      );

      if (result.exitCode != 0) {
        // Parse common Windows error codes
        final errorOutput = result.stderr.toString().toLowerCase();
        if (errorOutput.contains('not found') ||
            errorOutput.contains('не найден')) {
          return LaunchResult.failure('Файл не найден: $path');
        }
        return LaunchResult.failure(
            'Не удалось запустить файл: ${result.stderr}');
      }

      return const LaunchResult.success();
    } on ProcessException catch (e) {
      return LaunchResult.failure('Не удалось запустить файл: ${e.message}');
    } catch (e) {
      return LaunchResult.failure('Не удалось запустить файл: $e');
    }
  }
}

/// Linux implementation using xdg-open command
class LinuxLauncherService implements LauncherService {
  @override
  Future<LaunchResult> launch(String path, {String? arguments}) async {
    // Validate path
    if (path.isEmpty) {
      throw ArgumentError('Path cannot be empty');
    }

    // Check if file exists
    final file = File(path);
    if (!await file.exists()) {
      return LaunchResult.failure('Файл не найден: $path');
    }

    try {
      // Use xdg-open to launch file with default associated program
      final result = await Process.run(
        'xdg-open',
        [path],
        runInShell: false,
      );

      if (result.exitCode != 0) {
        // xdg-open exit codes: 3 = file not found, 4 = no application
        if (result.exitCode == 3) {
          return LaunchResult.failure('Файл не найден: $path');
        } else if (result.exitCode == 4) {
          return LaunchResult.failure(
              'Нет приложения для открытия этого файла');
        }
        return LaunchResult.failure(
            'Не удалось запустить файл: ${result.stderr}');
      }

      return const LaunchResult.success();
    } on ProcessException catch (e) {
      if (e.message.contains('xdg-open')) {
        return LaunchResult.failure('Утилита xdg-open не установлена');
      }
      return LaunchResult.failure('Не удалось запустить файл: ${e.message}');
    } catch (e) {
      return LaunchResult.failure('Не удалось запустить файл: $e');
    }
  }
}

/// macOS implementation using open command
class MacOSLauncherService implements LauncherService {
  @override
  Future<LaunchResult> launch(String path, {String? arguments}) async {
    // Validate path
    if (path.isEmpty) {
      throw ArgumentError('Path cannot be empty');
    }

    // Check if file exists
    final file = File(path);
    if (!await file.exists()) {
      return LaunchResult.failure('Файл не найден: $path');
    }

    try {
      // Build arguments list
      final args = ['open'];
      if (arguments != null && arguments.isNotEmpty) {
        args.addAll(arguments.split(' '));
      }
      args.add(path);

      // Use open command to launch file with default associated program
      final result = await Process.run(
        '/usr/bin/open',
        args.sublist(1), // Skip 'open' since it's the command itself
        runInShell: false,
      );

      if (result.exitCode != 0) {
        // open command exit code 1 typically means file not found
        if (result.exitCode == 1) {
          return LaunchResult.failure('Файл не найден: $path');
        }
        return LaunchResult.failure(
            'Не удалось запустить файл: ${result.stderr}');
      }

      return const LaunchResult.success();
    } on ProcessException catch (e) {
      return LaunchResult.failure('Не удалось запустить файл: ${e.message}');
    } catch (e) {
      return LaunchResult.failure('Не удалось запустить файл: $e');
    }
  }
}
