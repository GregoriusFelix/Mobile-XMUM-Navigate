import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../widgets.dart';
import '../l10n/app_localizations.dart';
import '../utils/xmum_page_route.dart';
import '../widgets/xmum_animations.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    this.firebaseReady = true,
    this.firebaseError,
  });

  final bool firebaseReady;
  final String? firebaseError;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  void _goToLogin() {
    xmumPush(context, const LoginScreen());
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final localizations = AppLocalizations.of(context);

    final pages = [
      _OnboardPage(
        icon: Icons.location_city_rounded,
        iconColor: kPrimary,
        bgGradient: isDark
            ? [kDarkSurface, kDarkCard]
            : [const Color(0xFFEEF2F8), const Color(0xFFD6E4F5)],
        title: localizations.discoverCampus,
        subtitle: localizations.discoverCampusSubtitle,
        isDark: isDark,
      ),
      _OnboardPage(
        icon: Icons.map_rounded,
        iconColor: kSecondary,
        bgGradient: isDark
            ? [kDarkCard, const Color(0xFF2A1A28)]
            : [const Color(0xFFF8EEF2), const Color(0xFFEDD6E0)],
        title: localizations.interactiveMap,
        subtitle: localizations.interactiveMapSubtitle,
        isDark: isDark,
      ),
      _OnboardPage(
        icon: Icons.directions_walk_rounded,
        iconColor: kAccent,
        bgGradient: isDark
            ? [const Color(0xFF2A2818), kDarkSurface]
            : [const Color(0xFFF8F4E8), const Color(0xFFEDE4C8)],
        title: localizations.smartDirections,
        subtitle: localizations.smartDirectionsSubtitle,
        isDark: isDark,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            XmumStaggeredItem(
              index: 0,
              child: XmumLogo(
                size: 44,
                showSubtitle: false,
                textColor: isDark ? kDarkText : kTextDark,
              ),
            ),
            if (!widget.firebaseReady && widget.firebaseError != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kWarning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(kRadiusMd),
                    border: Border.all(color: kWarning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: kWarning, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.firebaseError!,
                          style: xmumFont(
                            fontSize: 12,
                            color: isDark ? kDarkText : kTextDark,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => pages[i],
              ),
            ),
            const SizedBox(height: 20),
            PageDots(count: pages.length, active: _page),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
              child: ParkButton(
                label: _page == pages.length - 1
                    ? localizations.getStarted
                    : localizations.continue_,
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  if (_page < pages.length - 1) {
                    _pageCtrl.nextPage(
                      duration: kAnimSlow,
                      curve: kAnimCurve,
                    );
                  } else {
                    _goToLogin();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
              child: TextButton(
                onPressed: _goToLogin,
                child: Text(
                  localizations.skip,
                  style: xmumFont(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? kDarkTextMuted : kTextMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final List<Color> bgGradient;
  final String title;
  final String subtitle;
  final bool isDark;

  const _OnboardPage({
    required this.icon,
    required this.iconColor,
    required this.bgGradient,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1.0),
              duration: kAnimMedium,
              curve: kAnimSpring,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: bgGradient,
                  ),
                  borderRadius: BorderRadius.circular(kRadiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: isDark ? 0.2 : 0.1),
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 30,
                      right: 30,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconColor.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 30,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kAccent.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? kDarkCard : kWhite,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Icon(icon, size: 56, color: iconColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            textAlign: TextAlign.center,
            style: xmumFont(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? kDarkText : kTextDark,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: xmumFont(
              fontSize: 15,
              color: isDark ? kDarkTextMuted : kTextMuted,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
