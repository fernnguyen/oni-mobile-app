import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/locale/app_localizations.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/auth/auth_notifier.dart';
import '../../providers/locale/locale_notifier.dart';
import '../../providers/main/main_notifier.dart';
import '../../providers/theme/theme_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_snack_bar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.loc.navAccount)),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [
            _UserInfo(),
            _ProfileButton(),
            _ThemeButton(),
            _LanguageButton(),
            _PrinterSettingsButton(),
            _AboutButton(),
            _SignOutButton(),
            _DeleteAccountButton(),
          ],
        ),
      ),
    );
  }
}

class _UserInfo extends ConsumerWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(mainNotifierProvider.select((p) => p.user));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
      child: Column(
        children: [
          AppImage(
            image: user?.imageUrl ?? '',
            width: 120,
            height: 120,
            borderRadius: BorderRadius.circular(100),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          const SizedBox(height: AppSizes.padding),
          Text(
            user?.name ?? '(No Name)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.padding / 4),
          Text(
            user?.email ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  context.loc.profile,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ],
        ),
        onTap: () {
          context.go('/account/profile');
        },
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.format_paint_outlined,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  context.loc.theme,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ],
        ),
        onTap: () {
          AppDialog.show(
            title: context.loc.theme,
            leftButtonText: context.loc.close,
            child: const _ThemeDialogBody(),
          );
        },
      ),
    );
  }
}

class _LanguageButton extends ConsumerWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);
    final isVietnamese = locale.languageCode == 'vi';

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  context.loc.languageLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  isVietnamese ? 'Tiếng Việt' : 'English',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          AppDialog.show(
            title: context.loc.selectLanguage,
            leftButtonText: context.loc.close,
            child: const _LanguageDialogBody(),
          );
        },
      ),
    );
  }
}

class _LanguageDialogBody extends ConsumerWidget {
  const _LanguageDialogBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text(
            'Tiếng Việt',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: currentLocale.languageCode == 'vi'
              ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () {
            ref.read(localeNotifierProvider.notifier).changeLocale('vi');
            Navigator.of(context).pop();
          },
        ),
        const Divider(height: 1),
        ListTile(
          title: const Text(
            'English',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: currentLocale.languageCode == 'en'
              ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () {
            ref.read(localeNotifierProvider.notifier).changeLocale('en');
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class _PrinterSettingsButton extends StatelessWidget {
  const _PrinterSettingsButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.print_outlined,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  context.loc.printerSettings,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ],
        ),
        onTap: () {
          context.go('/account/printer-settings');
        },
      ),
    );
  }
}

class _AboutButton extends StatelessWidget {
  const _AboutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  context.loc.aboutLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ],
        ),
        onTap: () {
          context.go('/account/about');
        },
      ),
    );
  }
}

class _ThemeDialogBody extends ConsumerWidget {
  const _ThemeDialogBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);

    return Row(
      children: [
        Switch(
          value: !themeState.isLight,
          onChanged: (val) {
            ref.read(themeNotifierProvider.notifier).changeBrightness(!val);
          },
        ),
        const SizedBox(width: AppSizes.padding),
        Text(
          context.loc.darkMode,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVietnamese = ref.watch(localeNotifierProvider).languageCode == 'vi';
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: Theme.of(context).colorScheme.surface,
        borderColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.exit_to_app_rounded,
                  size: 18,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  context.loc.signOut,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ],
        ),
        onTap: () {
          AppDialog.show(
            title: context.loc.confirm,
            text: context.loc.confirmSignOut,
            leftButtonText: context.loc.cancel,
            rightButtonText: context.loc.signOut,
            onTapRightButton: (context) async {
              context.pop();

              final isSyncronizing = ref
                  .read(mainNotifierProvider)
                  .isSyncronizing;

              if (isSyncronizing) {
                AppSnackBar.showError(
                  isVietnamese
                      ? 'Không thể đăng xuất khi đang đồng bộ dữ liệu. Vui lòng chờ trong giây lát.'
                      : 'Cannot sign out while synchronizing data is in progress. Please wait a moment.',
                );
                return;
              }

              final res = await AppDialog.showProgress(() async {
                return ref.read(authNotifierProvider.notifier).signOut();
              });

              if (res.isSuccess) {
                if (!context.mounted) return;
                context.go('/sign-in');
              } else {
                AppSnackBar.showError(res.error.toString());
              }
            },
          );
        },
      ),
    );
  }
}

class _DeleteAccountButton extends ConsumerWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isVietnamese = ref.watch(localeNotifierProvider).languageCode == 'vi';
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppButton(
        buttonColor: theme.colorScheme.surface,
        borderColor: theme.colorScheme.errorContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.delete_forever_rounded,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: AppSizes.padding / 1.5),
                Text(
                  context.loc.deleteAccount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: theme.colorScheme.error,
            ),
          ],
        ),
        onTap: () {
          AppDialog.show(
            title: context.loc.confirmDeleteAccount,
            text: context.loc.confirmDeleteAccountWarn,
            leftButtonText: context.loc.cancel,
            rightButtonText: context.loc.delete,
            onTapRightButton: (context) async {
              context.pop();

              final isSyncronizing = ref
                  .read(mainNotifierProvider)
                  .isSyncronizing;

              if (isSyncronizing) {
                AppSnackBar.showError(
                  isVietnamese
                      ? 'Không thể xóa tài khoản khi đang đồng bộ dữ liệu. Vui lòng chờ.'
                      : 'Cannot delete account while synchronization is in progress. Please wait.',
                );
                return;
              }

              final user = ref.read(mainNotifierProvider).user;
              if (user == null) return;

              final res = await AppDialog.showProgress(() async {
                return ref.read(userRepositoryProvider).deleteUser(user.id);
              });

              if (res.isSuccess) {
                if (!context.mounted) return;
                context.go('/sign-in');
                AppSnackBar.show(
                  isVietnamese ? 'Tài khoản của bạn đã được xóa.' : 'Your account has been deleted.',
                );
              } else {
                AppSnackBar.showError(res.error.toString());
              }
            },
          );
        },
      ),
    );
  }
}
