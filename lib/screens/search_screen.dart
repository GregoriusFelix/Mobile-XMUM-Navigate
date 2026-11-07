import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../models/campus_location.dart';
import '../utils/xmum_page_route.dart';
import 'location_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = ['All', 'Office', 'Dorm', 'Food', 'Class', 'Facilities', 'Entrance'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CampusLocation> get _filteredLocations {
    var locations = CampusLocations.allLocations;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      locations = CampusLocations.searchLocations(_searchQuery);
    }

    // Filter by category
    if (_selectedCategory != null && _selectedCategory != 'All') {
      locations = locations.where((loc) => loc.category == _selectedCategory).toList();
    }

    return locations;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text(localizations.search, style: xmumFont(fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? kDarkCard : kWhite,
        foregroundColor: isDark ? kDarkText : kTextDark,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? kDarkCard : kWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kCardShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: localizations.searchBuildings,
                hintStyle: TextStyle(color: isDark ? kDarkTextMuted : kTextMuted),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: isDark ? kDarkTextMuted : kTextMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category filters
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = selected ? category : null);
                    },
                    selectedColor: kPrimary.withValues(alpha: 0.2),
                    checkmarkColor: kPrimary,
                    labelStyle: TextStyle(
                      color: isSelected ? kPrimary : (isDark ? kDarkText : kTextDark),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    backgroundColor: isDark ? kDarkCard : kWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? kPrimary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Results
          Expanded(
            child: _filteredLocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: isDark ? kDarkTextMuted : kTextMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? kDarkText : kTextDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? kDarkTextMuted : kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    itemCount: _filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      return _LocationResultCard(
                        location: location,
                        isDark: isDark,
                        onTap: () {
                          xmumPush(
                            context,
                            LocationDetailScreen(location: location),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LocationResultCard extends StatelessWidget {
  final CampusLocation location;
  final bool isDark;
  final VoidCallback onTap;

  const _LocationResultCard({
    required this.location,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? kDarkCard : kWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kCardShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(location.category),
                color: kPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? kDarkText : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? kDarkTextMuted : kTextMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          location.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? kDarkTextMuted : kTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Academic':
        return Icons.school;
      case 'Facility':
        return Icons.business;
      case 'Food':
        return Icons.restaurant;
      case 'Parking':
        return Icons.local_parking;
      case 'Entrance':
        return Icons.door_sliding;
      default:
        return Icons.location_on;
    }
  }
}
