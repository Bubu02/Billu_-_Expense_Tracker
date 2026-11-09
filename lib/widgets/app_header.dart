import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = context.piluColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        border: Border(
          bottom: BorderSide(
            color: colors.surfaceContainer,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBack) ...[
                    GestureDetector(
                      onTap: onBack ?? () => Navigator.maybePop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 8),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    'pilu',
                    style: AppTypography.headlineLg(colors.primary).copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '/',
                    style: AppTypography.labelCaps(colors.outline),
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      title,
                      style: AppTypography.headlineMd(colors.onSurface).copyWith(
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.surfaceContainerHighest,
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida/ALJJyrDpMNnjojhc77tbkUFWJkiBK459sYew1814QocxFzOywLt1UXLQcTvCBdZpkgvxhl_xjCDOhNVAsCI--tOn-zLi41F0UTIZM800MpKNg8cQsqNIpYxgxvx9US_5QYLSogPaerqxRZ88x7YRI9m8VRODjXDv4rjAc9LKTsw67ckbdiI843ynR-OtJQX4QXCI591CpGh8zUqGftdjPb_UwUW_SvDNvJBKt7aOLIYVJDchnQ',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

