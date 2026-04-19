/// Base class for all application-specific exceptions
abstract class AppException implements Exception {
  final String message;
  final bool isRetryable;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.isRetryable = false,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception for API-related errors
class ApiException extends AppException {
  final int? statusCode;

  ApiException(
    super.message, {
    this.statusCode,
    super.isRetryable,
    super.stackTrace,
  });
}

/// Exception for network connectivity issues (usually retryable)
class NetworkException extends ApiException {
  NetworkException(super.message, {super.stackTrace})
    : super(
        isRetryable: true,
      );
}

/// Exception for timeout errors (retryable)
class TimeoutException extends ApiException {
  TimeoutException(super.message, {super.stackTrace})
    : super(
        isRetryable: true,
      );
}

/// Exception for data parsing errors (usually not retryable)
class DataParsingException extends AppException {
  DataParsingException(super.message, {super.stackTrace})
    : super(
        isRetryable: false,
      );
}

/// Exception for database errors
class DatabaseException extends AppException {
  DatabaseException(super.message, {super.stackTrace})
    : super(
        isRetryable: false,
      );
}
