import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/campus_location.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../utils/location_display.dart';
import 'location_detail_screen.dart';
import 'navigation_screen.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  final _service = FirebaseService();
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = _service.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final user = await _service.getUserProfile(uid);
    if (mounted) {
      setState(() {
        _user = user;
        _loading = false;
      });
    }
  }

  Future<void> _unsaveLocation(String locationId) async {
    final uid = _service.currentUser?.uid;
    if (uid == null) return;

    await _service.unsaveLocation(uid, locationId);
    await _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? kDarkBackground : kGrey,
        appBar: AppBar(
          title: const Text('Saved Locations', style: TextStyle(color: kWhite)),
          backgroundColor: kPrimary,
          foregroundColor: kWhite,
          iconTheme: const IconThemeData(color: kWhite),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    final savedLocationIds = _user?.savedLocations ?? [];
    final savedLocations = savedLocationIds
        .map((id) => CampusLocations.getLocationById(id))
        .where((location) => location != null)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: const Text('Saved Locations', style: TextStyle(color: kWhite)),
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        iconTheme: const IconThemeData(color: kWhite),
        elevation: 0,
      ),
      body: savedLocations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: isDark ? kDarkTextMuted : kTextMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved locations yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? kDarkText : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save your favorite places to access them quickly',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? kDarkTextMuted : kTextMuted,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedLocations.length,
              itemBuilder: (context, index) {
                final location = savedLocations[index]!;
                final display = locationDisplayFor(location);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? kDarkCard : kWhite,
                    borderRadius: BorderRadius.circular(kRadiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: kMapGreen,
                                borderRadius: BorderRadius.circular(kRadiusMd),
                              ),
                              child: Center(
                                child: Text(display.emoji, style: const TextStyle(fontSize: 28)),
                              ),
                            ),
                            const SizedBox(width: 14),
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
                                    '${categoryLabel(location.category)} ${display.status}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: kGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _unsaveLocation(location.id),
                              icon: const Icon(Icons.bookmark_rounded, color: kPrimary),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LocationDetailScreen(location: location),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isDark ? kDarkSurface : kGreyLight,
                                    borderRadius: BorderRadius.circular(kRadiusMd),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 18,
                                        color: isDark ? kDarkText : kTextDark,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'View Details',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? kDarkText : kTextDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NavigationScreen(initialLocation: location),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: kPrimary,
                                    borderRadius: BorderRadius.circular(kRadiusMd),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.navigation_rounded, size: 18, color: kWhite),
                                      SizedBox(width: 8),
                                      Text(
                                        'Navigate',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: kWhite,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
