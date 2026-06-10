import 'package:flutter/material.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';
import 'package:revive_sunnah_reminder/theme/app_typography.dart';

/// Production-ready Sunnah card with proper visual hierarchy
/// Follows accessibility guidelines and design tokens
class ProductionSunnahCard extends StatefulWidget {
  const ProductionSunnahCard({
    super.key,
    required this.sunnah,
    this.onMarkCompleted,
    this.onToggleFavorite,
    this.onShare,
    this.isCompleted = false,
    this.showActions = true,
    this.compact = false,
  });

  final Sunnah sunnah;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onShare;
  final bool isCompleted;
  final bool showActions;
  final bool compact;

  @override
  State<ProductionSunnahCard> createState() => _ProductionSunnahCardState();
}

class _ProductionSunnahCardState extends State<ProductionSunnahCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveStandard,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sunnah: ${widget.sunnah.title}',
      hint: widget.showActions
          ? 'Double tap to mark as completed, long press for options'
          : 'Sunnah practice card',
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceLg,
                  vertical: DesignTokens.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: widget.isCompleted
                      ? AppColors.getAccentColor(alpha: 0.05)
                      : AppColors.dominantSurface,
                  borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
                  border: Border.all(
                    color: widget.isCompleted
                        ? AppColors.success
                        : AppColors.getSecondaryColor(alpha: 0.15),
                    width: widget.isCompleted ? 2.0 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isCompleted
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.getSecondaryColor(alpha: 0.08),
                      blurRadius: widget.isCompleted
                          ? DesignTokens.elevation2xl
                          : DesignTokens.elevationLg,
                      offset: const Offset(0, 4),
                    ),
                    if (_isPressed)
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        blurRadius: DesignTokens.elevation3xl,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardHeader(),
                    _buildCardContent(),
                    if (widget.showActions) _buildCardActions(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.space2xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.isCompleted
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.getSecondaryColor(alpha: 0.05),
            AppColors.dominantSurface,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radius2xl),
          topRight: Radius.circular(DesignTokens.radius2xl),
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: DesignTokens.spaceLg,
            height: DesignTokens.spaceLg,
            decoration: BoxDecoration(
              color:
                  widget.isCompleted ? AppColors.success : AppColors.secondary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isCompleted
                          ? AppColors.success
                          : AppColors.secondary)
                      .withValues(alpha: 0.3),
                  blurRadius: DesignTokens.spaceSm,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.isCompleted
                ? Icon(
                    Icons.check,
                    size: DesignTokens.spaceMd,
                    color: AppColors.textOnColor,
                  )
                : null,
          ),
          SizedBox(width: DesignTokens.spaceLg),

          // Title and category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sunnah.title,
                  style: widget.compact
                      ? AppTypography.titleMedium
                      : AppTypography.titleLarge,
                  maxLines: widget.compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!widget.compact) ...[
                  SizedBox(height: DesignTokens.spaceXs),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceMd,
                      vertical: DesignTokens.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getSecondaryColor(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusLg),
                    ),
                    child: Text(
                      widget.sunnah.category,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: AppTypography.weightMedium,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Favorite indicator
          if (widget.sunnah.isFavorite)
            Container(
              padding: EdgeInsets.all(DesignTokens.spaceXs),
              decoration: BoxDecoration(
                color: AppColors.supporting.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Icon(
                Icons.favorite,
                size: DesignTokens.spaceLg,
                color: AppColors.supporting,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: EdgeInsets.all(DesignTokens.space2xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arabic text if available
          if (widget.sunnah.arabicText?.isNotEmpty == true) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(DesignTokens.space2xl),
              decoration: BoxDecoration(
                color: AppColors.getDominantColor(dark: true),
                borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                border: Border.all(
                  color: AppColors.getSecondaryColor(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Text(
                widget.sunnah.arabicText!,
                style: AppTypography.arabicText,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
            SizedBox(height: DesignTokens.spaceLg),
          ],

          // Description
          Text(
            widget.sunnah.hadith,
            style: widget.compact
                ? AppTypography.bodyMedium
                : AppTypography.bodyLarge,
            maxLines: widget.compact ? 2 : null,
            overflow: widget.compact ? TextOverflow.ellipsis : null,
          ),

          // Source if available
          if (widget.sunnah.source.isNotEmpty) ...[
            SizedBox(height: DesignTokens.spaceLg),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceLg,
                vertical: DesignTokens.spaceSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: DesignTokens.spaceLg,
                    color: AppColors.info,
                  ),
                  SizedBox(width: DesignTokens.spaceSm),
                  Expanded(
                    child: Text(
                      widget.sunnah.source,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.info,
                        fontWeight: AppTypography.weightMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Benefits if available and not compact
          if (!widget.compact && widget.sunnah.benefit.isNotEmpty) ...[
            SizedBox(height: DesignTokens.spaceLg),
            Text(
              'Benefits:',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.accent,
                fontWeight: AppTypography.weightSemiBold,
              ),
            ),
            SizedBox(height: DesignTokens.spaceSm),
            Padding(
              padding: EdgeInsets.only(bottom: DesignTokens.spaceXs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: DesignTokens.spaceXs,
                    ),
                    width: DesignTokens.spaceXs,
                    height: DesignTokens.spaceXs,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: DesignTokens.spaceSm),
                  Expanded(
                    child: Text(
                      widget.sunnah.benefit,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardActions() {
    return Container(
      padding: EdgeInsets.all(DesignTokens.space2xl),
      decoration: BoxDecoration(
        color: AppColors.getDominantColor(dark: true),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(DesignTokens.radius2xl),
          bottomRight: Radius.circular(DesignTokens.radius2xl),
        ),
      ),
      child: Row(
        children: [
          // Complete action
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.isCompleted ? null : widget.onMarkCompleted,
              icon: Icon(
                widget.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                size: DesignTokens.spaceLg,
              ),
              label: Text(
                widget.isCompleted ? 'Completed' : 'Mark Complete',
                style: AppTypography.labelLarge,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.isCompleted ? AppColors.success : AppColors.accent,
                foregroundColor: AppColors.textOnColor,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceLg,
                  vertical: DesignTokens.spaceLg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                ),
              ),
            ),
          ),

          SizedBox(width: DesignTokens.spaceLg),

          // Secondary actions
          _buildActionButton(
            icon: widget.sunnah.isFavorite
                ? Icons.favorite
                : Icons.favorite_outline,
            onPressed: widget.onToggleFavorite,
            color: widget.sunnah.isFavorite
                ? AppColors.supporting
                : AppColors.textTertiary,
            tooltip: widget.sunnah.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
          ),

          SizedBox(width: DesignTokens.spaceSm),

          _buildActionButton(
            icon: Icons.share_outlined,
            onPressed: widget.onShare,
            color: AppColors.textTertiary,
            tooltip: 'Share this Sunnah',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 48, // Minimum touch target
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: DesignTokens.spaceLg,
            color: color,
          ),
          splashRadius: 20,
        ),
      ),
    );
  }
}

/// Compact version for list views
class CompactSunnahCard extends StatelessWidget {
  const CompactSunnahCard({
    super.key,
    required this.sunnah,
    this.onTap,
    this.isCompleted = false,
  });

  final Sunnah sunnah;
  final VoidCallback? onTap;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return ProductionSunnahCard(
      sunnah: sunnah,
      isCompleted: isCompleted,
      compact: true,
      showActions: false,
    );
  }
}
