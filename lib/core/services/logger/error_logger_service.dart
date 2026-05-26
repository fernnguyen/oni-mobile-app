import '../../utilities/console_logger.dart';
import '../../utilities/debug_mode_wrapper.dart';

/// Global error logging service
class ErrorLoggerService {
  final DebugModeWrapper _debugMode;

  ErrorLoggerService({
    DebugModeWrapper? debugMode,
  }) : _debugMode = debugMode ?? DebugModeWrapper();

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
