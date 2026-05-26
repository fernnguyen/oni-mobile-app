import '../../utilities/console_logger.dart';

/// Global error logging service
class ErrorLoggerService {
  ErrorLoggerService();

  /// Log error
  void log({
    required Object error,
    StackTrace? stackTrace,
    String? title,
    String? message,
    String? state,
  }) {
    // Always log to console
    ce(error, title: title, message: message, state: state);
  }
}
