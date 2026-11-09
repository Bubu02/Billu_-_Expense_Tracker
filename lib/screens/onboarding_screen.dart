import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/constellation_painter.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  int? _activePillIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.billuColors;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Spatial Micro-indicator
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'V1.0 • OFFLINE READY',
                          style: AppTypography.labelCaps(colors.onSurfaceVariant).copyWith(
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'monochrome',
                        style: AppTypography.labelCaps(colors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),

              // Center Stage: Constellation + Avatar + Orbiting Pill Tags
              Center(
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Vector Constellation Dotted Arcs
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ConstellationPainter(lineColor: colors.outline),
                        ),
                      ),

                      // Center Avatar Circle Container
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipOval(
                              child: Container(
                                color: colors.surfaceContainerLow,
                                child: Image.network(
                                  'https://lh3.googleusercontent.com/aida/ALJJyrDpMNnjojhc77tbkUFWJkiBK459sYew1814QocxFzOywLt1UXLQcTvCBdZpkgvxhl_xjCDOhNVAsCI--tOn-zLi41F0UTIZM800MpKNg8cQsqNIpYxgxvx9US_5QYLSogPaerqxRZ88x7YRI9m8VRODjXDv4rjAc9LKTsw67ckbdiI843ynR-OtJQX4QXCI591CpGh8zUqGftdjPb_UwUW_SvDNvJBKt7aOLIYVJDchnQ',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.auto_awesome,
                                    size: 40,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            // Anchor tick mark
                            Positioned(
                              bottom: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 1. "balance" (top-left)
                      Positioned(
                        top: 24,
                        left: 8,
                        child: _buildFloatingPill(
                          index: 0,
                          text: 'balance',
                          isInverted: false,
                        ),
                      ),

                      // 2. "+ income" (top-right)
                      Positioned(
                        top: 16,
                        right: 14,
                        child: _buildFloatingPill(
                          index: 1,
                          text: '+ income',
                          isInverted: false,
                        ),
                      ),

                      // 3. "expenses ●" (mid-left - inverted primary anchor)
                      Positioned(
                        top: 140,
                        left: 0,
                        child: _buildFloatingPill(
                          index: 2,
                          text: 'expenses ●',
                          isInverted: true,
                        ),
                      ),

                      // 4. "food" (mid-right)
                      Positioned(
                        top: 140,
                        right: 0,
                        child: _buildFloatingPill(
                          index: 3,
                          text: 'food',
                          isInverted: false,
                        ),
                      ),

                      // 5. "travel" (bottom-left)
                      Positioned(
                        bottom: 24,
                        left: 16,
                        child: _buildFloatingPill(
                          index: 4,
                          text: 'travel',
                          isInverted: false,
                        ),
                      ),

                      // 6. "fun ✦" (bottom-right)
                      Positioned(
                        bottom: 28,
                        right: 14,
                        child: _buildFloatingPill(
                          index: 5,
                          text: 'fun ✦',
                          isInverted: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Branding & Action Block
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    // Brand Title & Tagline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'billu',
                          style: AppTypography.headlineLg(colors.primary).copyWith(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'your minimal budgeting app',
                      style: AppTypography.bodyMd(colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),

                    // Primary Action CTA: get started
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: widget.onGetStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'get started',
                              style: AppTypography.bodyLg(colors.onPrimary).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: colors.onPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Secondary Restore Trigger
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Searching for offline backups...',
                              style: AppTypography.bodyMd(colors.onPrimary),
                            ),
                            backgroundColor: colors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'already tracked? ',
                              style: AppTypography.labelSubtle(colors.onSurfaceVariant),
                            ),
                            Text(
                              'restore backup',
                              style: AppTypography.labelSubtle(colors.primary).copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Zen Statement
                    Text(
                      'ZERO CLUTTER • LOCAL FIRST',
                      style: AppTypography.labelCaps(colors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingPill({
    required int index,
    required String text,
    required bool isInverted,
  }) {
    final colors = context.billuColors;
    final isTapped = _activePillIndex == index;

    final bg = isInverted
        ? colors.primary
        : (isTapped ? colors.primary : colors.surfaceContainerLowest);
    final fg = isInverted
        ? colors.onPrimary
        : (isTapped ? colors.onPrimary : colors.onSurface);

    return GestureDetector(
      onTap: () {
        setState(() => _activePillIndex = index);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) setState(() => _activePillIndex = null);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(
          isTapped ? 1.1 : 1.0,
          isTapped ? 1.1 : 1.0,
          1.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: AppTypography.numericSm(fg).copyWith(
            fontWeight: isInverted ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

