import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final double fontSize;

  const BrandLogo({
    super.key,
    this.size = 80.0,
    this.showText = true,
    this.fontSize = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.05),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback in case asset load fails
            return Container(
              color: AppColors.primary,
              child: Center(
                child: Text(
                  'O',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.55,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    if (!showText) return logoIcon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoIcon,
        SizedBox(height: size * 0.16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
            children: [
              TextSpan(
                text: 'ONI',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const TextSpan(
                text: ' ERP',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'MOBILE POS',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }
}
