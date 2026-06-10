import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revive_sunnah_reminder/providers/sunnah_provider.dart';
import 'package:revive_sunnah_reminder/providers/streak_provider.dart';
import 'package:revive_sunnah_reminder/screens/progress_screen.dart';
import 'package:revive_sunnah_reminder/screens/all_sunnahs_screen.dart';
import 'package:revive_sunnah_reminder/screens/settings_screen.dart';
import 'package:revive_sunnah_reminder/screens/chat_screen.dart';
import 'package:revive_sunnah_reminder/widgets/minimal_greeting_card.dart';
import 'package:revive_sunnah_reminder/widgets/swipeable_sunnah_card.dart';
import 'package:revive_sunnah_reminder/widgets/floating_chat_widget.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';
import 'package:revive_sunnah_reminder/theme/design_tokens.dart';
import 'package:revive_sunnah_reminder/theme/app_colors.dart';
import 'package:revive_sunnah_reminder/theme/app_typography.dart';
import '../widgets/production_microinteractions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 44, // Minimum touch target for accessibility
          maxWidth: 80, // Prevent overflow on small screens
        ),
        child: ProductionInteractiveButton(
          onPressed: () => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            vertical: DesignTokens.spaceXs, // 4px vertical
            horizontal: DesignTokens.spaceSm, // 8px horizontal
          ),
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          enableScaleAnimation: true,
          enableRipple:
              false, // We'll handle visual feedback with our custom design
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.getSecondaryColor(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
              border: isSelected
                  ? Border.all(
                      color: AppColors.getSecondaryColor(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: DesignTokens.durationFast,
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textTertiary,
                    size: isSelected ? 24 : 22, // Slightly smaller icons
                  ),
                ),
                SizedBox(height: DesignTokens.spaceXs), // 4px spacing
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: isSelected
                          ? AppTypography.weightSemiBold
                          : AppTypography.weightRegular,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const _HomeTab(),
          const ChatScreen(),
          const ProgressScreen(),
          const AllSunnahsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.dominantSurface,
              AppColors.getDominantColor(dark: true),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DesignTokens.radius2xl),
            topRight: Radius.circular(DesignTokens.radius2xl),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.getSecondaryColor(alpha: 0.1),
              blurRadius: DesignTokens.space2xl,
              offset: const Offset(0, -8),
            ),
            BoxShadow(
              color: AppColors.getSecondaryColor(alpha: 0.05),
              blurRadius: DesignTokens.spaceLg,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive height based on screen width
              final isSmallScreen = constraints.maxWidth < 360;
              final bottomNavHeight = isSmallScreen ? 75.0 : 85.0;
              final horizontalPadding = isSmallScreen ? 12.0 : 20.0;

              return Container(
                height: bottomNavHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: DesignTokens.spaceSm, // 8px vertical
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // Changed from spaceAround
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      activeIcon: Icons.home,
                      label: 'Home',
                      index: 0,
                      isSelected: _currentIndex == 0,
                    ),
                    _buildNavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      label: 'Chat',
                      index: 1,
                      isSelected: _currentIndex == 1,
                    ),
                    _buildNavItem(
                      icon: Icons.trending_up_rounded,
                      activeIcon: Icons.trending_up,
                      label: 'Progress',
                      index: 2,
                      isSelected: _currentIndex == 2,
                    ),
                    _buildNavItem(
                      icon: Icons.menu_book_rounded,
                      activeIcon: Icons.menu_book,
                      label: 'Library',
                      index: 3,
                      isSelected: _currentIndex == 3,
                    ),
                    _buildNavItem(
                      icon: Icons.settings_rounded,
                      activeIcon: Icons.settings,
                      label: 'Settings',
                      index: 4,
                      isSelected: _currentIndex == 4,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _cardController;
  late AnimationController _quoteController;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _quoteFadeAnimation;
  late Animation<Offset> _quoteSlideAnimation;
  bool _isQuoteExpanded = false;
  final GlobalKey _cardKey = GlobalKey(); // Key to measure card height
  double _measuredCardHeight = 400.0; // Default height

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize animation controllers with design token durations
    _cardController = AnimationController(
      duration: DesignTokens.durationSlower, // 700ms
      vsync: this,
    );
    _quoteController = AnimationController(
      duration: Duration(milliseconds: 900), // Slightly longer for quote
      vsync: this,
    );

    // Initialize animations
    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    ));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: DesignTokens.curveEmphasized, // Use design token curve
    ));

    _quoteFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _quoteController,
      curve: Curves.easeInOut,
    ));

    _quoteSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _quoteController,
      curve: DesignTokens.curveStandard, // Use design token curve
    ));

    _startAnimations();

    // Measure card height after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureCardHeight();
    });
  }

  // Method to measure the actual height of the card
  void _measureCardHeight() {
    final RenderBox? renderBox =
        _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _measuredCardHeight = renderBox.size.height;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Measure card height when dependencies change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureCardHeight();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cardController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _refreshData();
    }
  }

  void _refreshData() {
    // Refresh the Sunnah provider to check for new daily Sunnah
    final sunnahProvider = Provider.of<SunnahProvider>(context, listen: false);
    sunnahProvider.loadSunnahs();
  }

  void _startAnimations() async {
    // Start card animation
    await Future.delayed(const Duration(milliseconds: 200));
    _cardController.forward();

    // Start quote animation
    await Future.delayed(const Duration(milliseconds: 200));
    _quoteController.forward();
  }

  /// Toggle favorite status for today's Sunnah
  void _toggleFavorite(SunnahProvider sunnahProvider, Sunnah sunnah) async {
    await sunnahProvider.toggleFavorite(sunnah);

    // Show a snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${sunnah.isFavorite ? 'Removed from' : 'Added to'} favorites'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer2<SunnahProvider, StreakProvider>(
          builder: (context, sunnahProvider, streakProvider, child) {
            if (sunnahProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (sunnahProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading Sunnahs',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sunnahProvider.error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => sunnahProvider.loadSunnahs(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final todaySunnah = sunnahProvider.todaySunnah;
            if (todaySunnah == null) {
              return const Center(
                child: Text('No Sunnah available for today'),
              );
            }

            return Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Modern App Bar with Enhanced Design
                    SliverAppBar(
                      expandedHeight:
                          83, // Further reduced to 80 for better mobile fit
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      surfaceTintColor: Colors.transparent,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8), // Further reduced padding
                          margin: const EdgeInsets.symmetric(
                              horizontal:
                                  16), // Added margin for better centering
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF2E7D32),
                                Color(0xFF388E3C),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                                16), // Further reduced to 16
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withAlpha(77),
                                blurRadius: 8, // Reduced blur radius
                                offset: const Offset(0, 2), // Reduced offset
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                    5), // Further reduced padding
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(51),
                                  borderRadius: BorderRadius.circular(
                                      7), // Reduced border radius
                                ),
                                child: const Icon(
                                  Icons.mosque_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 16, // Further reduced icon size
                                ),
                              ),
                              const SizedBox(width: 8), // Reduced spacing
                              Expanded(
                                child: Text(
                                  'Revive Sunnah',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        // Changed from headlineSmall
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.25,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        centerTitle: true, // Ensure title is centered
                      ),
                    ),

                    // Main Content with Production Spacing
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(
                            DesignTokens.spaceLg), // 16px consistent padding
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                height:
                                    DesignTokens.spaceSm), // 8px top spacing
                            // Enhanced Welcome Section with Proper Visual Hierarchy
                            const MinimalGreetingCard(), // Replaced the entire container with our new widget

                            SizedBox(
                                height: DesignTokens.spaceLg), // 16px spacing

                            // Today's Sunnah Section Header with Production Spacing
                            Container(
                              padding: EdgeInsets.all(
                                  DesignTokens.spaceLg), // 16px padding
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusXl), // 16px radius
                                border: Border.all(
                                  color:
                                      AppColors.getSecondaryColor(alpha: 0.15),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center, // Center the row
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                        DesignTokens.spaceXs), // 4px padding
                                    decoration: BoxDecoration(
                                      color: AppColors.getSecondaryColor(
                                          alpha: 0.15),
                                      borderRadius: BorderRadius.circular(
                                          DesignTokens.spaceXs), // 4px radius
                                    ),
                                    child: Icon(
                                      Icons.today_rounded,
                                      color: AppColors.secondary,
                                      size: DesignTokens.textSm, // 14px icon
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          DesignTokens.spaceSm), // 8px spacing
                                  Text(
                                    'Today\'s Practice',
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: AppTypography.weightExtraBold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: DesignTokens
                                          .spaceXs, // 4px horizontal
                                      vertical: DesignTokens.spaceXs /
                                          2, // 2px vertical
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.getSecondaryColor(
                                          alpha: 0.15),
                                      borderRadius: BorderRadius.circular(
                                          DesignTokens.spaceSm), // 8px radius
                                    ),
                                    child: Text(
                                      'Daily',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight:
                                            AppTypography.weightSemiBold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                                height: DesignTokens
                                    .spaceLg), // 16px spacing between header and card

                            // Today's Sunnah Card with Animation
                            FadeTransition(
                              opacity: _cardFadeAnimation,
                              child: SlideTransition(
                                position: _cardSlideAnimation,
                                child: Center(
                                  child: Column(
                                    key:
                                        _cardKey, // Add key for measuring height
                                    children: [
                                      // Swipeable Sunnah Card Stack
                                      _SwipeableSunnahCardStack(
                                        onMarkAsCompleted: (sunnah) =>
                                            _markAsCompleted(
                                                sunnahProvider, streakProvider),
                                        onToggleFavorite: (sunnah) =>
                                            _toggleFavorite(
                                                sunnahProvider, sunnah),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Dynamic spacing with design tokens
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmallScreen =
                                    DesignTokens.isSmallScreen(context);

                                // Calculate dynamic spacing based on card height
                                double baseSpacing = isSmallScreen
                                    ? DesignTokens.spaceLg
                                    : DesignTokens.space2xl;
                                double heightAdjustment =
                                    (400.0 - _measuredCardHeight) * 0.05;
                                double dynamicSpacing =
                                    (baseSpacing + heightAdjustment).clamp(
                                        DesignTokens.spaceSm,
                                        DesignTokens.space4xl);

                                return SizedBox(height: dynamicSpacing);
                              },
                            ),

                            // Enhanced Inspirational Quote with Proper Visual Hierarchy
                            FadeTransition(
                              opacity: _quoteFadeAnimation,
                              child: SlideTransition(
                                position: _quoteSlideAnimation,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    // Use design tokens for responsive design
                                    final isSmallScreen =
                                        DesignTokens.isSmallScreen(context);

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isQuoteExpanded = !_isQuoteExpanded;
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(
                                          isSmallScreen
                                              ? DesignTokens.space2xl
                                              : DesignTokens.space3xl,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.dominantSurface,
                                              AppColors.supporting
                                                  .withValues(alpha: 0.05),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            isSmallScreen
                                                ? DesignTokens.radiusLg
                                                : DesignTokens.radiusXl,
                                          ),
                                          border: Border.all(
                                            color: AppColors.supporting
                                                .withValues(alpha: 0.2),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.supporting
                                                  .withValues(alpha: 0.1),
                                              blurRadius: isSmallScreen
                                                  ? DesignTokens.spaceLg
                                                  : DesignTokens.space2xl,
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
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Quote icon with proper spacing
                                            Container(
                                              padding: EdgeInsets.all(
                                                isSmallScreen
                                                    ? DesignTokens.spaceMd
                                                    : DesignTokens.spaceLg,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.supporting,
                                                    AppColors.supporting
                                                        .withValues(alpha: 0.8),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        DesignTokens.radiusLg),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.supporting
                                                        .withValues(alpha: 0.3),
                                                    blurRadius:
                                                        DesignTokens.spaceSm,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                _isQuoteExpanded
                                                    ? Icons.expand_less_rounded
                                                    : Icons
                                                        .format_quote_rounded,
                                                size: isSmallScreen
                                                    ? DesignTokens.space2xl
                                                    : DesignTokens.space3xl,
                                                color: AppColors.textOnColor,
                                              ),
                                            ),
                                            SizedBox(
                                                height: isSmallScreen
                                                    ? DesignTokens.spaceLg
                                                    : DesignTokens.space2xl),
                                            Text(
                                              '"Whoever revives my Sunnah when my Ummah becomes corrupt will have the reward of a hundred martyrs."',
                                              style:
                                                  AppTypography.quote.copyWith(
                                                color: AppColors.accent,
                                                fontSize: isSmallScreen
                                                    ? DesignTokens.textBase
                                                    : DesignTokens.textLg,
                                                fontWeight: AppTypography
                                                    .weightSemiBold,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines:
                                                  _isQuoteExpanded ? null : 3,
                                              overflow: _isQuoteExpanded
                                                  ? TextOverflow.visible
                                                  : TextOverflow.ellipsis,
                                            ),
                                            SizedBox(
                                                height: DesignTokens.spaceLg),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      DesignTokens.spaceLg,
                                                  vertical:
                                                      DesignTokens.spaceXs),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors.getSecondaryColor(
                                                        alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        DesignTokens.radius2xl),
                                              ),
                                              child: Text(
                                                'Hadith - At-Tirmidhi',
                                                style: AppTypography.labelMedium
                                                    .copyWith(
                                                  color: AppColors.secondary,
                                                  fontWeight: AppTypography
                                                      .weightSemiBold,
                                                ),
                                              ),
                                            ),
                                            if (_isQuoteExpanded) ...[
                                              SizedBox(
                                                  height: DesignTokens.spaceLg),
                                              Text(
                                                'This hadith emphasizes the great reward for those who revive and practice the Sunnah of the Prophet Muhammad (ﷺ) in times when it may be neglected or forgotten.',
                                                style: AppTypography.bodyMedium
                                                    .copyWith(
                                                  color: AppColors.accent,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(
                                                  height: DesignTokens.spaceSm),
                                              Icon(
                                                Icons.keyboard_arrow_up_rounded,
                                                color: AppColors.supporting,
                                              ),
                                            ] else ...[
                                              SizedBox(
                                                  height: DesignTokens.spaceXs),
                                              Text(
                                                'Tap to expand',
                                                style: AppTypography.labelSmall
                                                    .copyWith(
                                                  color: AppColors.supporting,
                                                  fontWeight: AppTypography
                                                      .weightMedium,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Final spacing with design tokens
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmallScreen =
                                    DesignTokens.isSmallScreen(context);
                                return SizedBox(
                                  height: _isQuoteExpanded
                                      ? (isSmallScreen
                                          ? DesignTokens.spaceSm
                                          : DesignTokens.spaceLg)
                                      : (isSmallScreen
                                          ? DesignTokens.spaceLg
                                          : DesignTokens.space2xl),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Floating Chat Widget
                const FloatingChatWidget(),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper methods for card actions
  void _markAsCompleted(
      SunnahProvider sunnahProvider, StreakProvider streakProvider) async {
    // Mark today as completed in streak provider
    await streakProvider.markTodayCompleted();
    // Also mark the Sunnah as completed in Sunnah provider
    await sunnahProvider.markTodayCompleted();
    // Track hadith as completed (not just viewed) - ONLY for today's Sunnah
    await streakProvider.markHadithAsCompleted();
    // Refresh the Sunnah provider to update UI
    await sunnahProvider.refreshCompletionStatus();

    // Show a snackbar confirmation with undo option
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sunnah marked as completed!'),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () => _undoCompletion(sunnahProvider, streakProvider),
          ),
        ),
      );
    }
  }

  void _undoCompletion(
      SunnahProvider sunnahProvider, StreakProvider streakProvider) async {
    // Mark today as incomplete in streak provider
    await streakProvider.markTodayIncomplete();
    // Remove completion from the Sunnah provider
    if (sunnahProvider.todaySunnah != null) {
      await sunnahProvider
          .removeSunnahCompletion(sunnahProvider.todaySunnah!.id);
    }
    // Refresh the Sunnah provider to update UI
    await sunnahProvider.refreshCompletionStatus();

    // Show a snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completion undone!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// New widget for swipeable Sunnah card stack
class _SwipeableSunnahCardStack extends StatefulWidget {
  final Function(Sunnah) onMarkAsCompleted;
  final Function(Sunnah) onToggleFavorite;

  const _SwipeableSunnahCardStack({
    required this.onMarkAsCompleted,
    required this.onToggleFavorite,
  });

  @override
  State<_SwipeableSunnahCardStack> createState() =>
      _SwipeableSunnahCardStackState();
}

class _SwipeableSunnahCardStackState extends State<_SwipeableSunnahCardStack> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Set<int> _completedSunnahIds = <int>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Handle page changes (removed automatic hadith reading tracking)
  void _onPageChanged(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Handle completion of a sunnah
  void _handleSunnahCompletion(Sunnah sunnah, SunnahProvider sunnahProvider,
      StreakProvider streakProvider) async {
    // Mark as completed
    await widget.onMarkAsCompleted(sunnah);

    // NOTE: We don't call streakProvider.markHadithAsCompleted() here
    // because we only want to count hadiths once per day, not per swipe
    // The hadith count is tracked separately for today's main Sunnah only

    // Add to completed set
    setState(() {
      _completedSunnahIds.add(sunnah.id);
    });

    // Move to next card if available
    final sunnahs = sunnahProvider.swipeableSunnahs;
    if (_currentIndex < sunnahs.length - 1) {
      // Only move to next if it's the current card
      if (sunnahs[_currentIndex].id == sunnah.id) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SunnahProvider, StreakProvider>(
      builder: (context, sunnahProvider, streakProvider, child) {
        if (sunnahProvider.swipeableSunnahs.isEmpty) {
          return const SizedBox(
            height: 400,
            child: Center(
              child: Text('No hadiths available'),
            ),
          );
        }

        final sunnahs = sunnahProvider.swipeableSunnahs;

        return SizedBox(
          height: 600,
          child: PageView.builder(
            controller: _pageController,
            itemCount: sunnahs.length,
            onPageChanged: (index) => _onPageChanged(index),
            itemBuilder: (context, index) {
              final sunnah = sunnahs[index];
              final isCompleted = _completedSunnahIds.contains(sunnah.id);

              // Only show the card if it's the first one or the previous one is completed
              final shouldShow = index == 0 ||
                  _completedSunnahIds.contains(sunnahs[index - 1].id);

              if (!shouldShow) {
                // Show a locked card or empty space with consistent design
                return Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).cardTheme.color,
                    border: Border.all(
                      color: Colors.grey.withAlpha(31),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32).withAlpha(25),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              size: 48,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Complete previous hadith to unlock',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF1B5E20),
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Each hadith builds upon the previous one to help you develop a consistent practice',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SwipeableSunnahCard(
                sunnah: sunnah,
                isCompleted: isCompleted,
                onCompleted: () => _handleSunnahCompletion(
                    sunnah, sunnahProvider, streakProvider),
                onToggleFavorite: () => widget.onToggleFavorite(sunnah),
              );
            },
          ),
        );
      },
    );
  }
}
