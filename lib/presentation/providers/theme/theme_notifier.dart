import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../providers/theme/theme_state.dart';

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    // Luôn luôn sử dụng giao diện sáng (Light Mode) theo yêu cầu
    const isLight = true;
    const brightness = Brightness.light;

    return ThemeState(
      isLight: isLight,
      themeData: AppTheme().init(brightness: brightness),
    );
  }

  void changeBrightness(bool isLight) async {
    // Khóa cứng ứng dụng ở giao diện sáng
    state = ThemeState(
      isLight: true,
      themeData: AppTheme().init(brightness: Brightness.light),
    );
  }
}
