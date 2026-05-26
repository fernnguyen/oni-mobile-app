import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformWrapper {
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
}
