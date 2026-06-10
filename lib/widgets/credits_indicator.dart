import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revive_sunnah_reminder/providers/credits_provider.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';

class CreditsIndicator extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const CreditsIndicator({
    super.key,
    this.showDetails = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditsProvider>(
      builder: (context, creditsProvider, child) {
        if (creditsProvider.isLoading) {
          return _buildLoadingIndicator(context);
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.dominantSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: creditsProvider.getCreditsColor().withAlpha(51),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: creditsProvider.getCreditsColor().withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildProgressIndicator(creditsProvider),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCreditsInfo(context, creditsProvider),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dominantSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary15),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading credits...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(CreditsProvider creditsProvider) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            value: creditsProvider.progressValue,
            backgroundColor: creditsProvider.getCreditsColor().withAlpha(25),
            valueColor: AlwaysStoppedAnimation<Color>(
              creditsProvider.getCreditsColor(),
            ),
            strokeWidth: 3,
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: creditsProvider.getCreditsColor().withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            creditsProvider.getStatusIcon(),
            size: 12,
            color: creditsProvider.getCreditsColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsInfo(
      BuildContext context, CreditsProvider creditsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'Daily Questions: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              creditsProvider.getCreditsDisplayText(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: creditsProvider.getCreditsColor(),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        if (showDetails) ...[
          const SizedBox(height: 2),
          Text(
            creditsProvider.getStatusText(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          if (!creditsProvider.hasCredits) ...[
            const SizedBox(height: 2),
            Text(
              'Resets in ${creditsProvider.getTimeUntilReset()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ],
    );
  }
}

class CompactCreditsIndicator extends StatelessWidget {
  final VoidCallback? onTap;

  const CompactCreditsIndicator({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditsProvider>(
      builder: (context, creditsProvider, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: creditsProvider.getCreditsColor().withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: creditsProvider.getCreditsColor().withAlpha(51),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.token_rounded,
                  size: 16,
                  color: creditsProvider.getCreditsColor(),
                ),
                const SizedBox(width: 6),
                Text(
                  creditsProvider.getCreditsDisplayText(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: creditsProvider.getCreditsColor(),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CreditsStatusCard extends StatelessWidget {
  final VoidCallback? onUpgrade;

  const CreditsStatusCard({
    super.key,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditsProvider>(
      builder: (context, creditsProvider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                creditsProvider.getCreditsColor().withAlpha(25),
                AppColors.dominantSurface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: creditsProvider.getCreditsColor().withAlpha(51),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: creditsProvider.getCreditsColor().withAlpha(25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: creditsProvider.getCreditsColor(),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.token_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Questions',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        Text(
                          creditsProvider.getCreditsDisplayText(),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: creditsProvider.getCreditsColor(),
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: creditsProvider.progressValue,
                      backgroundColor:
                          creditsProvider.getCreditsColor().withAlpha(25),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        creditsProvider.getCreditsColor(),
                      ),
                      strokeWidth: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.dominantSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary10),
                ),
                child: Column(
                  children: [
                    Text(
                      creditsProvider.getMotivationalMessage(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (!creditsProvider.hasCredits) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Credits reset in ${creditsProvider.getTimeUntilReset()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onUpgrade != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onUpgrade,
                    icon: const Icon(Icons.upgrade_rounded, size: 18),
                    label: const Text('Get More Questions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
