import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuickAdd;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.piluColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.94),
        border: Border(
          top: BorderSide(
            color: colors.surfaceContainer,
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.grid_view_rounded,
                label: 'desk',
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.donut_large_rounded,
                label: 'stats',
              ),
              // Floating Center Action Button
              Transform.translate(
                offset: const Offset(0, -8),
                child: GestureDetector(
                  onTap: onQuickAdd,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.add_rounded,
                      size: 26,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.account_balance_wallet_outlined,
                label: 'vault',
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.tune_rounded,
                label: 'setup',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final colors = context.piluColors;
    final isSelected = currentIndex == index;
    final color = isSelected ? colors.primary : colors.onSurfaceVariant;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minWidth: 50, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelCaps(color).copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

