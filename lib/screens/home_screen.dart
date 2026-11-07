import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/campus_location.dart';
import 'profile_screen.dart';
import 'content_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'search_screen.dart';
import 'saved_locations_screen.dart';
import 'routes_history_screen.dart';
import 'navigation_screen.dart';
import '../utils/xmum_page_route.dart';
import '../widgets/xmum_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _contentTabIndex = 0;
  final _service = FirebaseService();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadUserLocations();
  }

  Future<void> _loadUser() async {
    final uid = _service.currentUser?.uid;
    if (uid != null) {
      final user = await _service.getUserProfile(uid);
      if (mounted) setState(() => _user = user);
    }
  }

  Future<void> _loadUserLocations() async {
    final uid = _service.currentUser?.uid;
    if (uid != null) {
      await CampusLocations.loadUserLocations(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = themeProvider.isDark;

    final pages = [
      _buildDashboard(),
      ContentScreen(initialTabIndex: _contentTabIndex),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: XmumTabSwitcher(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: XmumNavBar(
        isDark: isDark,
        selectedIndex: _currentIndex == 2 ? 3 : _currentIndex,
        items: [
          XmumNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: localizations.home,
            onTap: () => setState(() => _currentIndex = 0),
          ),
          XmumNavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore_rounded,
            label: localizations.explore,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          XmumNavItem(
            icon: Icons.help_outline_rounded,
            selectedIcon: Icons.help_rounded,
            label: localizations.help,
            onTap: () => xmumPush(context, const HelpScreen()),
          ),
          XmumNavItem(
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: localizations.account,
            onTap: () => setState(() => _currentIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = themeProvider.isDark;
    final firstName = _user != null && _user!.name.isNotEmpty
        ? _user!.name.split(' ').first
        : 'Guest';

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: XmumHeaderPattern(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.welcome,
                              style: xmumFont(
                                color: kWhite.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${localizations.hi}, $firstName',
                              style: xmumFont(
                                color: kWhite,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _headerIconButton(Icons.notifications_outlined, () {
                            xmumPush(context, const SettingsScreen());
                          }),
                          const SizedBox(width: 8),
                          _headerIconButton(Icons.settings_outlined, () {
                            xmumPush(context, const SettingsScreen());
                          }),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _campusPassCard(isDark),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  XmumSectionTitle(title: localizations.services, isDark: isDark),
                  const SizedBox(height: 16),
                  ParkSearchBar(
                    hint: 'Search campus locations...',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                    },
                  ),
                  const SizedBox(height: 24),
                  _serviceGrid(isDark),
                  const SizedBox(height: 32),
                  XmumSectionTitle(
                    title: localizations.campusMap,
                    action: 'Open',
                    onActionTap: () => setState(() => _currentIndex = 1),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _mapCard(isDark),
                  const SizedBox(height: 32),
                  XmumSectionTitle(
                    title: localizations.food,
                    action: 'See all',
                    onActionTap: () {
                      setState(() {
                        _contentTabIndex = 1;
                        _currentIndex = 1;
                      });
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _foodCard('LY3 Block', '800m', '🍜', isDark),
                        _foodCard('D6 Canteen', '300m', '☕', isDark),
                        _foodCard('LakeFront Café', '600m', '☕', isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campusPassCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kRadiusLg),
        border: Border.all(color: kAccent.withValues(alpha: 0.3), width: 1),
        boxShadow: const [kMediumShadow, kGoldGlow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: xmumGoldAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.badge_rounded, color: kWhite, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Campus Pass',
                    style: xmumFont(
                      color: kTextMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              XmumBadge(
                label: _user?.role ?? 'Student',
                color: kPrimary,
                icon: Icons.verified_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Ready to explore XMUM',
            style: xmumFont(
              color: kTextDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _user?.email ?? 'Sign in to sync your profile',
            style: xmumFont(color: kTextMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _passAction(Icons.navigation_rounded, 'Go Now', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NavigationScreen())))),
              const SizedBox(width: 12),
              Expanded(child: _passAction(Icons.history_rounded, 'History', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoutesHistoryScreen())))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _passAction(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: kSetelLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kPrimary.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: kPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style: xmumFont(
                color: kPrimaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: xmumGlassDecoration(opacity: 0.18),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: kWhite, size: 22),
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _serviceGrid(bool isDark) {
    final services = [
      (Icons.directions_rounded, 'Navigate', kSetelLight, kPrimary),
      (Icons.restaurant_rounded, 'Food', const Color(0xFFF8EEF2), kSecondary),
      (Icons.search_rounded, 'Search', const Color(0xFFF8F4E8), kAccent),
      (Icons.event_rounded, 'Venues', const Color(0xFFECF5F0), kSuccess),
      (Icons.bookmark_rounded, 'Saved', const Color(0xFFEEF2F8), kPrimary),
      (Icons.help_center_rounded, 'Help', const Color(0xFFF5F3EF), kTextMuted),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, i) {
        final (icon, label, bg, color) = services[i];
        return GestureDetector(
          onTap: () {
            if (label == 'Help') {
              xmumPush(context, const HelpScreen());
            } else if (label == 'Navigate') {
              setState(() => _currentIndex = 1);
            } else if (label == 'Food') {
              setState(() {
                _contentTabIndex = 1;
                _currentIndex = 1;
              });
            } else if (label == 'Venues') {
              setState(() {
                _contentTabIndex = 2;
                _currentIndex = 1;
              });
            } else if (label == 'Search') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
            } else if (label == 'Saved') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedLocationsScreen()));
            }
          },
          child: Container(
            decoration: xmumPremiumCard(isDark: isDark),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: xmumFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? kDarkText : kTextDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mapCard(bool isDark) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryDark.withValues(alpha: 0.05),
            kPrimary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadiusLg),
        border: Border.all(color: kPrimary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(kRadiusLg),
          onTap: () => setState(() => _currentIndex = 1),
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: xmumGoldAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'LIVE',
                    style: xmumFont(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: kWhite,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.map_rounded, size: 40, color: kPrimary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'XMUM Campus Map',
                      style: xmumFont(
                        color: isDark ? kDarkText : kTextDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to start navigation',
                      style: xmumFont(color: kTextMuted, fontSize: 13),
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

  Widget _foodCard(String name, String dist, String emoji, bool isDark) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 14),
      decoration: xmumPremiumCard(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kSetelLight, kGreyLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadiusLg)),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 42))),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: xmumFont(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isDark ? kDarkText : kTextDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 11, color: kSecondary),
                      const SizedBox(width: 2),
                      Text(
                        dist,
                        style: xmumFont(
                          fontSize: 10,
                          color: isDark ? kDarkTextMuted : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
