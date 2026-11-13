import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final bool? isMasked;
  final VoidCallback? onToggleMask;

  const AppHeader({
    super.key,
    this.showBack = false,
    this.onBack,
    this.isMasked,
    this.onToggleMask,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = context.billuColors;

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
                    'billu',
                    style: AppTypography.headlineLg(colors.primary).copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
              // Privacy Toggle (Eye Icon) - only shown when applicable
              if (isMasked != null && onToggleMask != null)
                IconButton(
                  onPressed: onToggleMask,
                  icon: Icon(
                    isMasked!
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: colors.onSurface,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.surfaceContainer,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

