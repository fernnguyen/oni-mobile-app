import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../providers/auth/auth_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/brand_logo.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subdomainController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedSubdomain = ref.read(sharedPreferencesProvider).getString(Constants.selectedSubdomainKey) ?? '';
      if (savedSubdomain.isNotEmpty) {
        _subdomainController.text = savedSubdomain;
      }
    });
  }

  @override
  void dispose() {
    _subdomainController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final subdomain = _subdomainController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final res = await AppDialog.showProgress(() async {
      return ref
          .read(authNotifierProvider.notifier)
          .signIn(
            subdomain,
            email,
            password,
          );
    });

    if (res.isSuccess) {
      if (mounted) {
        ref.read(appRoutesProvider).router.refresh();
      }
    } else {
      if (mounted) {
        AppDialog.showError(error: res.error?.toString() ?? 'Đăng nhập thất bại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding * 1.5),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSizes.padding),
                  // Premium Brand Logo Widget
                  const BrandLogo(size: 84, fontSize: 30),
                  const SizedBox(height: AppSizes.padding * 2),

                  // Subdomain Input Field
                  TextFormField(
                    controller: _subdomainController,
                    decoration: InputDecoration(
                      labelText: 'Doanh nghiệp (Subdomain)',
                      hintText: 'ten-doanh-nghiep',
                      prefixIcon: const Icon(
                        Icons.domain_rounded,
                        color: AppColors.primary,
                      ),
                      suffixText: '.oni.vn',
                      suffixStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.white
                          : theme.colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên subdomain doanh nghiệp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.padding),

                  // Email/Username Input Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Tài khoản (Email)',
                      hintText: 'email@example.com',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.white
                          : theme.colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email tài khoản';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.padding),

                  // Password Input Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.white
                          : theme.colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignIn(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.padding * 2),

                  // Submit Button
                  AppButton(
                    text: 'ĐĂNG NHẬP HỆ THỐNG',
                    onTap: _handleSignIn,
                  ),
                  const SizedBox(height: AppSizes.padding),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
