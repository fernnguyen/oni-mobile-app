import 'package:flutter_pos/core/services/logger/error_logger_service.dart';
import 'package:flutter_pos/core/utilities/debug_mode_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([DebugModeWrapper])
void main() {
  late ErrorLoggerService errorLogger;

  group('ErrorLoggerService', () {
    setUp(() {
      errorLogger = ErrorLoggerService();
    });

    test('should log without crashing', () {
      final error = Exception('Test error');
      
      // Act & Assert
      expect(() => errorLogger.log(error: error), returnsNormally);
    });
  });
}
