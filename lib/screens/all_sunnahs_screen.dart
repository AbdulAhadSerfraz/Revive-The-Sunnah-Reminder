import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revive_sunnah_reminder/providers/sunnah_provider.dart';
import 'package:revive_sunnah_reminder/models/sunnah.dart';
import 'package:revive_sunnah_reminder/widgets/sunnah_card.dart';
import 'dart:async';

class AllSunnahsScreen extends StatefulWidget {
  const AllSunnahsScreen({super.key});

  @override
  State<AllSunnahsScreen> createState() => _AllSunnahsScreenState();
}

class _AllSunnahsScreenState extends State<AllSunnahsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';
  List<Sunnah> _filteredSunnahs = [];
  bool _isSearchExpanded = true;
  bool _showResultsSummary = true; // New state variable
  bool _isSearchVisible = true; // New state for search visibility
  double _previousOffset = 0.0; // Track previous scroll offset
  bool _scrollingUp = false; // Track if we're scrolling up
  Timer? _visibilityTimer; // Timer for delayed visibility changes
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  Set<int> _completedSunnahIds = <int>{}; // Track completed Sunnah IDs
  Set<int> _favoriteSunnahIds = <int>{}; // Track favorite Sunnah IDs

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSunnahs);

    // Initialize animation controller for search box with extremely slow animation
    _searchAnimationController = AnimationController(
      duration:
          const Duration(milliseconds: 1200), // Much slower animation (was 800)
      vsync: this,
    );

    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOutQuad, // Even smoother curve for gradual movement
    ));

    // Set initial expanded state
    _searchAnimationController.forward();

    // Add scroll listener for dynamic shrinking
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load completed and favorite Sunnah IDs when the widget is first built
    _loadSunnahData();
  }

  @override
  void didUpdateWidget(covariant AllSunnahsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh Sunnah data when the widget updates
    _loadSunnahData();
  }

  /// Add this method to listen for changes in the Sunnah provider
  void _handleSunnahProviderChange() {
    _loadSunnahData();
  }

  /// Load completed and favorite Sunnah IDs
  Future<void> _loadSunnahData() async {
    final sunnahProvider = context.read<SunnahProvider>();
    final completedIds = await sunnahProvider.getCompletedSunnahIds();
    setState(() {
      _completedSunnahIds = completedIds.toSet();
      _favoriteSunnahIds = sunnahProvider.favoriteSunnahIds;
    });
  }

  void _onScroll() {
    // More responsive hiding of search bar with adjusted thresholds
    const double hideThreshold = 5.0; // Hide when scrolling down just a little
    const double showThreshold =
        50.0; // Show only when scrolling up significantly

    // Track scroll direction based on offset changes
    bool scrollingDown = _scrollController.offset > _previousOffset &&
        _scrollController.offset > hideThreshold;
    bool scrollingUp = _scrollController.offset <
        _previousOffset - 15; // Require more upward movement

    // Cancel any existing timer
    _visibilityTimer?.cancel();

    // Update search bar visibility based on scroll direction and position
    if (scrollingDown && _isSearchVisible) {
      setState(() {
        _isSearchVisible = false;
        _isSearchExpanded = false;
        _scrollingUp = false;
      });
      // Use animateTo instead of fling for more control over the animation
      _searchAnimationController.animateTo(0.0,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutQuad);
    } else if (scrollingUp && !_isSearchVisible) {
      // Set state to indicate we're scrolling up
      setState(() {
        _scrollingUp = true;
      });

      // Only show the search bar after a delay and if we've scrolled up enough
      _visibilityTimer = Timer(const Duration(milliseconds: 300), () {
        if (_scrollingUp && _scrollController.offset < showThreshold) {
          setState(() {
            _isSearchVisible = true;
            _isSearchExpanded = true;
          });
          // Use animateTo instead of fling for more control over the animation
          _searchAnimationController.animateTo(1.0,
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOutQuad);
        }
      });
    } else if (_scrollController.offset <= hideThreshold && !_isSearchVisible) {
      // Always show when at the top immediately
      _visibilityTimer?.cancel();
      setState(() {
        _isSearchVisible = true;
        _isSearchExpanded = true;
        _scrollingUp = false;
      });
      // Use animateTo instead of fling for more control over the animation
      _searchAnimationController.animateTo(1.0,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutQuad);
    }

    // Update previous offset for next comparison
    _previousOffset = _scrollController.offset;

    // Hide results summary when scrolling down
    const double summaryThreshold = 10.0; // Lower threshold
    final bool shouldShowSummary = _scrollController.offset < summaryThreshold;

    if (shouldShowSummary != _showResultsSummary) {
      setState(() {
        _showResultsSummary = shouldShowSummary;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchAnimationController.dispose();
    _visibilityTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  void _filterSunnahs() async {
    final sunnahProvider = context.read<SunnahProvider>();
    final searchQuery = _searchController.text.trim();

    List<Sunnah> filtered = sunnahProvider.allSunnahs;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((sunnah) => sunnah.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final searchResults = await sunnahProvider.searchSunnahs(searchQuery);
      filtered = searchResults;
      if (_selectedCategory != 'All') {
        filtered = filtered
            .where((sunnah) => sunnah.category == _selectedCategory)
            .toList();
      }
    }

    setState(() {
      _filteredSunnahs = filtered;
    });
  }

  /// Mark a Sunnah as completed
  Future<void> _markSunnahAsCompleted(Sunnah sunnah) async {
    final sunnahProvider = context.read<SunnahProvider>();

    // Record progress in database
    await sunnahProvider.markSunnahAsCompleted(sunnah.id);

    // Update local state
    setState(() {
      _completedSunnahIds.add(sunnah.id);
    });

    // Show a snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked "${sunnah.title}" as completed'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    }
  }

  /// Mark a Sunnah as incomplete
  Future<void> _markSunnahAsIncomplete(Sunnah sunnah) async {
    final sunnahProvider = context.read<SunnahProvider>();

    // Remove progress from database
    await sunnahProvider.removeSunnahCompletion(sunnah.id);

    // Update local state
    setState(() {
      _completedSunnahIds.remove(sunnah.id);
    });

    // Show a snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked "${sunnah.title}" as incomplete'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Toggle favorite status for a Sunnah
  Future<void> _toggleFavorite(Sunnah sunnah) async {
    final sunnahProvider = context.read<SunnahProvider>();

    // Toggle favorite status in database and update local state
    await sunnahProvider.toggleFavorite(sunnah);

    // Update local state
    setState(() {
      if (sunnah.isFavorite) {
        _favoriteSunnahIds.remove(sunnah.id);
        sunnah.isFavorite = false;
      } else {
        _favoriteSunnahIds.add(sunnah.id);
        sunnah.isFavorite = true;
      }
    });

    // Show a snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${sunnah.isFavorite ? 'Added to' : 'Removed from'} favorites'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
    }
  }

  /// Show favorite Sunnahs only
  void _showFavorites() {
    final sunnahProvider = context.read<SunnahProvider>();
    setState(() {
      _filteredSunnahs = sunnahProvider.allSunnahs
          .where((sunnah) => sunnah.isFavorite)
          .toList();
      _selectedCategory = 'All'; // Reset category filter
      _searchController.clear(); // Clear search
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, // Add this to prevent overflow
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.library_books_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              // Wrap text in Flexible to prevent overflow
              child: Text(
                'Sunnah Library',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                overflow: TextOverflow.ellipsis, // Add overflow handling
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: false,
        actions: [
          // Favorite button to show only favorite Sunnahs
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _showFavorites,
              icon: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFF2E7D32),
              ),
              tooltip: 'Show Favorites',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => _showSortDialog(),
              icon: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF2E7D32),
              ),
              tooltip: 'Filter & Sort',
            ),
          ),
        ],
      ),
      body: Consumer<SunnahProvider>(
        builder: (context, sunnahProvider, child) {
          // Add this to listen for changes and reload Sunnah data
          _handleSunnahProviderChange();

          if (sunnahProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Sunnahs...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          if (sunnahProvider.error != null) {
            return _buildErrorState(sunnahProvider);
          }

          // Initialize filtered Sunnahs if empty
          if (_filteredSunnahs.isEmpty) {
            _filteredSunnahs = sunnahProvider.allSunnahs;
          }

          return Column(
            children: [
              // Enhanced Search and Filter Section with Animation
              if (_isSearchVisible) // Only show when visible
                AnimatedBuilder(
                  animation: _searchAnimation,
                  builder: (context, child) {
                    return _buildResponsiveSearchSection(sunnahProvider);
                  },
                ),

              // Results Summary - Positioned to the right and hides when scrolling
              if (_showResultsSummary) _buildResultsSummary(sunnahProvider),

              // Sunnahs List with Modern Design
              Expanded(
                child: _filteredSunnahs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController, // Add scroll controller
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 16, // Reduced padding for mobile
                          right: 16,
                          top: 12,
                          bottom: 16 + MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: _filteredSunnahs.length,
                        itemBuilder: (context, index) {
                          final sunnah = _filteredSunnahs[index];
                          final isCompleted =
                              _completedSunnahIds.contains(sunnah.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SunnahCard(
                              sunnah: sunnah,
                              isCompleted: isCompleted,
                              onCompleted: () => _markSunnahAsCompleted(sunnah),
                              onIncomplete: () =>
                                  _markSunnahAsIncomplete(sunnah),
                              onToggleFavorite: () => _toggleFavorite(sunnah),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(SunnahProvider sunnahProvider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Sunnahs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              sunnahProvider.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => sunnahProvider.loadSunnahs(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveSearchSection(SunnahProvider sunnahProvider) {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 1200), // Much slower animation (was 800)
      curve: Curves.easeInOutQuad, // Even smoother curve for gradual movement
      margin: EdgeInsets.fromLTRB(
        12, // Reduced margins for mobile
        8,
        12,
        0,
      ),
      padding: EdgeInsets.all(
        _isSearchExpanded ? 16 : 8, // Reduced padding
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(_isSearchExpanded ? 16 : 12),
        border: Border.all(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimal Search Bar
          Container(
            height: _isSearchExpanded ? 48 : 40, // Reduced height
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(_isSearchExpanded ? 12 : 10),
              border: Border.all(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _isSearchExpanded ? 'Search Sunnahs...' : 'Search...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: _isSearchExpanded ? 14 : 12,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Container(
                  padding: EdgeInsets.all(_isSearchExpanded ? 10 : 8),
                  child: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF2E7D32),
                    size: _isSearchExpanded ? 20 : 18,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterSunnahs();
                          },
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: _isSearchExpanded ? 14 : 10,
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: _isSearchExpanded ? 14 : 12,
                  ),
            ),
          ),

          // Category Filter - Only show when expanded
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: _isSearchExpanded ? 12 : 8),
                SizedBox(
                  height: 36, // Reduced height
                  child: FutureBuilder<List<String>>(
                    future: sunnahProvider.getCategories(),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildMinimalFilterCategoryChip('All'),
                          const SizedBox(width: 6),
                          ...categories.map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _buildMinimalFilterCategoryChip(category),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            crossFadeState: _isSearchExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(
                milliseconds: 2000), // Much slower animation (was 800)
            reverseDuration: const Duration(
                milliseconds: 1500), // Much slower reverse animation (was 600)
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSummary(SunnahProvider sunnahProvider) {
    // Calculate the correct count based on current filters
    int totalCount;
    if (_selectedCategory == 'All' &&
        (_searchController.text.isEmpty ||
            _searchController.text.trim().isEmpty)) {
      // No filters applied, show total count
      totalCount = sunnahProvider.allSunnahs.length;
    } else if (_selectedCategory != 'All' && _searchController.text.isEmpty) {
      // Only category filter applied
      totalCount =
          sunnahProvider.getSunnahsByCategory(_selectedCategory).length;
    } else {
      // Search filter or both filters applied, use filtered list
      totalCount = _filteredSunnahs.length;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 4), // Minimal padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Align to the right
        children: [
          Icon(
            Icons.library_books_rounded,
            color: const Color(0xFF2E7D32),
            size: 12, // Smaller icon
          ),
          const SizedBox(width: 6), // Minimal spacing
          Text(
            '$totalCount Sunnah${totalCount == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500, // Lighter weight
                ),
          ),
          const SizedBox(width: 12), // Space at the end
        ],
      ),
    );
  }

  Widget _buildMinimalFilterCategoryChip(String category) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        _filterSunnahs();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8), // Reduced padding
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D32)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16), // Reduced border radius
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2E7D32)
                : Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          category,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                // Smaller text
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
      ),
    );
  }

  void _showSortDialog() async {
    // Get the categories before showing the dialog to avoid using context across async gaps
    final sunnahProvider = context.read<SunnahProvider>();
    final categories = await sunnahProvider.getCategories();

    // Check if the widget is still mounted before using context
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allow the sheet to take more height if needed
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          // Make the content scrollable
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter & Sort',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  // Add a button to show only favorites
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showFavorites();
                    },
                    child: const Text(
                      'Show Favorites',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter by Category Section
              Text(
                'Filter by Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36, // Reduced height
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildMinimalFilterCategoryChip('All'),
                    const SizedBox(width: 6),
                    ...categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _buildMinimalFilterCategoryChip(category),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sort Options Section
              Text(
                'Sort Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              _buildSortOption('Title (A-Z)', Icons.sort_by_alpha_rounded),
              _buildSortOption('Category', Icons.category_rounded),
              _buildSortOption('Recently Added', Icons.schedule_rounded),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      onTap: () {
        Navigator.pop(context);
        // Implement sorting logic here
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Sunnahs Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your search terms or filter criteria to find what you\'re looking for.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedCategory = 'All';
                });
                _filterSunnahs();
              },
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
