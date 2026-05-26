import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/params/error_screen_param.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/locale/locale_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_error_widget.dart';

class ErrorScreen extends ConsumerWidget {
  final ErrorScreenParam param;

  const ErrorScreen({super.key, required this.param});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVietnamese = ref.watch(localeNotifierProvider).languageCode == 'vi';

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppErrorWidget(
              error: param.error ?? param.flutterError,
              message: param.message,
            ),
            const SizedBox(height: AppSizes.padding),
            AppButton(
              buttonColor: Theme.of(context).colorScheme.surface,
              borderColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              textColor: Theme.of(context).colorScheme.primary,
              alignment: null,
              text: isVietnamese ? 'Quay lại trang chủ' : 'Back to home',
              onTap: () {
                // Go back to default initial route
                context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
