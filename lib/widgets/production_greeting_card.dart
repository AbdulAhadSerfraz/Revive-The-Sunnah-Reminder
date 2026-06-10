import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';
import 'package:revive_sunnah_reminder/theme/app_typography.dart';

/// Production-ready greeting card with enhanced visual hierarchy
class ProductionGreetingCard extends StatefulWidget {
  const ProductionGreetingCard({
    super.key,
    this.userName,
    this.streakCount = 0,
    this.showMotivation = true,
  });

  final String? userName;
  final int streakCount;
  final bool showMotivation;

  @override
  State<ProductionGreetingCard> createState() => _ProductionGreetingCardState();
}

class _ProductionGreetingCardState extends State<ProductionGreetingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEmphasized,
    ));

    // Start animation
    Future.delayed(DesignTokens.durationFast, () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    final userName = widget.userName ?? 'Friend';

    if (hour < 12) {
      return 'Good Morning, $userName';
    } else if (hour < 17) {
      return 'Good Afternoon, $userName';
    } else {
      return 'Good Evening, $userName';
    }
  }

  String _getMotivationalMessage() {
    if (widget.streakCount == 0) {
      return 'Start your journey of reviving the Sunnah today!';
    } else if (widget.streakCount < 7) {
      return 'Great start! Keep building your spiritual habits.';
    } else if (widget.streakCount < 30) {
      return 'Excellent progress! You are developing strong habits.';
    } else {
      return 'MashaAllah! Your dedication is inspiring.';
    }
  }

  IconData _getTimeBasedIcon() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      return Icons.wb_sunny;
    } else {
      return Icons.nights_stay_rounded;
    }
  }

  Color _getTimeBasedColor() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return AppColors.supporting; // Morning - warm amber
    } else if (hour < 17) {
      return AppColors.info; // Afternoon - blue
    } else {
      return AppColors.secondary; // Evening - green
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceLg,
                vertical: DesignTokens.spaceSm,
              ),
              padding: EdgeInsets.all(DesignTokens.space2xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.dominantSurface,
                    _getTimeBasedColor().withValues(alpha: 0.03),
                    AppColors.dominantSurface,
                  ],
                ),
                borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                border: Border.all(
                  color: _getTimeBasedColor().withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getTimeBasedColor().withValues(alpha: 0.1),
                    blurRadius: DesignTokens.space2xl,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.dominantSurface,
                    blurRadius: DesignTokens.spaceSm,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: DesignTokens.spaceLg),
                  _buildGreeting(),
                  if (widget.showMotivation) ...[
                    SizedBox(height: DesignTokens.spaceLg),
                    _buildMotivation(),
                  ],
                  if (widget.streakCount > 0) ...[
                    SizedBox(height: DesignTokens.spaceLg),
                    _buildStreakInfo(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(DesignTokens.spaceLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getTimeBasedColor(),
                _getTimeBasedColor().withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            boxShadow: [
              BoxShadow(
                color: _getTimeBasedColor().withValues(alpha: 0.3),
                blurRadius: DesignTokens.spaceSm,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _getTimeBasedIcon(),
            size: DesignTokens.space2xl,
            color: AppColors.textOnColor,
          ),
        ),
        Spacer(),
        if (widget.streakCount > 0)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLg,
              vertical: DesignTokens.spaceXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: DesignTokens.spaceLg,
                  color: AppColors.success,
                ),
                SizedBox(width: DesignTokens.spaceXs),
                Text(
                  '${widget.streakCount}',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.success,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreetingMessage(),
          style: DesignTokens.isLargeScreen(context)
              ? AppTypography.displaySmall
              : AppTypography.headlineLarge,
        ),
        SizedBox(height: DesignTokens.spaceXs),
        Text(
          'May Allah bless your day with guidance and peace',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivation() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.space2xl),
      decoration: BoxDecoration(
        color: AppColors.getDominantColor(dark: true),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: AppColors.getSecondaryColor(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(
              Icons.psychology_rounded,
              size: DesignTokens.spaceLg,
              color: AppColors.accent,
            ),
          ),
          SizedBox(width: DesignTokens.spaceLg),
          Expanded(
            child: Text(
              _getMotivationalMessage(),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: AppTypography.weightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakInfo() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.space2xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withValues(alpha: 0.05),
            AppColors.success.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: DesignTokens.space3xl,
            color: AppColors.success,
          ),
          SizedBox(width: DesignTokens.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.success,
                    fontWeight: AppTypography.weightSemiBold,
                  ),
                ),
                Text(
                  '${widget.streakCount} ${widget.streakCount == 1 ? 'day' : 'days'} of consistent practice',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(DesignTokens.spaceLg),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: DesignTokens.spaceSm,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${widget.streakCount}',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textOnColor,
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version for smaller spaces
class CompactGreetingCard extends StatelessWidget {
  const CompactGreetingCard({
    super.key,
    this.userName,
    this.streakCount = 0,
  });

  final String? userName;
  final int streakCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceLg,
        vertical: DesignTokens.spaceSm,
      ),
      padding: EdgeInsets.all(DesignTokens.spaceLg),
      decoration: BoxDecoration(
        color: AppColors.dominantSurface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        border: Border.all(
          color: AppColors.getSecondaryColor(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getSecondaryColor(alpha: 0.05),
            blurRadius: DesignTokens.spaceLg,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.spaceSm),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            ),
            child: Icon(
              Icons.wb_sunny_rounded,
              size: DesignTokens.spaceLg,
              color: AppColors.secondary,
            ),
          ),
          SizedBox(width: DesignTokens.spaceLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalamu Alaikum',
                  style: AppTypography.titleMedium,
                ),
                Text(
                  userName ?? 'Welcome back',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (streakCount > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceSm,
                vertical: DesignTokens.spaceXs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Text(
                '$streakCount',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: AppTypography.weightBold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
