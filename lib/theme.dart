import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── XMUM Brand Palette ───────────────────────────────────────────────────────
// Inspired by Xiamen University Malaysia — navy, crimson, gold
const Color kPrimary      = Color(0xFF1A3A6B); // XMUM Navy
const Color kPrimaryDark  = Color(0xFF0C2340); // Deep Navy
const Color kPrimaryLight = Color(0xFF2D5A9E); // Light Navy
const Color kSecondary    = Color(0xFF8B1538); // Xiamen Crimson
const Color kAccent       = Color(0xFFC5A04D); // University Gold
const Color kSuccess      = Color(0xFF2E7D5E);
const Color kWarning      = Color(0xFFD4A017);
const Color kError        = Color(0xFFC62828);

// Legacy color constants for compatibility
const Color kGreen        = kSuccess;
const Color kYellow       = kAccent;
const Color kMapGreen     = Color(0xFFD4E8DC);

// Color aliases for compatibility
const Color kSetelGreen = kPrimary;
const Color kSetelDark  = kPrimaryDark;
const Color kSetelDeep  = Color(0xFF081A30);
const Color kSetelLight = Color(0xFFEEF2F8);
const Color kSetelAccent = kSecondary;
const Color kNavy = kPrimary;
const Color kGold = kAccent;
const Color kWhite = Color(0xFFFFFFFF);
const Color kGrey = Color(0xFFF5F3EF);
const Color kGreyLight = Color(0xFFFAF8F5);
const Color kTextDark = Color(0xFF0C1A2E);
const Color kTextMuted = Color(0xFF5C6B7A);
const Color kTextLight = Color(0xFF8E9BAA);
const Color kCardShadow = Color(0x0A0C2340);
const Color kDivider = Color(0xFFE8E4DE);

const double kRadiusSm = 10.0;
const double kRadiusMd = 16.0;
const double kRadiusLg = 22.0;
const double kRadiusXl = 32.0;

// ─── Motion tokens ────────────────────────────────────────────────────────────
const Duration kAnimFast = Duration(milliseconds: 200);
const Duration kAnimMedium = Duration(milliseconds: 350);
const Duration kAnimSlow = Duration(milliseconds: 500);
const Duration kThemeAnimDuration = Duration(milliseconds: 400);
const Curve kAnimCurve = Curves.easeOutCubic;
const Curve kAnimSpring = Curves.easeOutBack;

// Dark mode colors
const Color kDarkBackground = Color(0xFF0A1628);
const Color kDarkCard = Color(0xFF142238);
const Color kDarkSurface = Color(0xFF1E3050);
const Color kDarkText = Color(0xFFF0EDE8);
const Color kDarkTextMuted = Color(0xFF8E9BAA);
const Color kDarkDivider = Color(0xFF243550);

// ─── Gradients ────────────────────────────────────────────────────────────────
LinearGradient get setelHeaderGradient => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [kPrimaryDark, kPrimary, kPrimaryLight],
      stops: [0.0, 0.55, 1.0],
    );

LinearGradient get xmumPremiumGradient => const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [kPrimaryDark, kPrimary, Color(0xFF1E4D8C)],
      stops: [0.0, 0.6, 1.0],
    );

LinearGradient get xmumGoldAccent => const LinearGradient(
      colors: [kAccent, Color(0xFFE8C97A)],
    );

// ─── Shadows ──────────────────────────────────────────────────────────────────
const BoxShadow kSoftShadow = BoxShadow(
  color: Color(0x0D0C2340),
  blurRadius: 24,
  offset: Offset(0, 6),
);

const BoxShadow kMediumShadow = BoxShadow(
  color: Color(0x120C2340),
  blurRadius: 32,
  offset: Offset(0, 10),
);

const BoxShadow kStrongShadow = BoxShadow(
  color: Color(0x1A0C2340),
  blurRadius: 40,
  offset: Offset(0, 16),
);

const BoxShadow kGoldGlow = BoxShadow(
  color: Color(0x33C5A04D),
  blurRadius: 20,
  offset: Offset(0, 4),
);

// ─── Decorations ──────────────────────────────────────────────────────────────
BoxDecoration setelCardDecoration({Color? color, bool elevated = true}) =>
    BoxDecoration(
      color: color ?? kWhite,
      borderRadius: BorderRadius.circular(kRadiusMd),
      border: Border.all(color: kDivider.withValues(alpha: 0.6), width: 0.5),
      boxShadow: elevated ? const [kSoftShadow] : null,
    );

BoxDecoration xmumGlassDecoration({double opacity = 0.15}) => BoxDecoration(
      color: kWhite.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(kRadiusMd),
      border: Border.all(color: kWhite.withValues(alpha: 0.25), width: 1),
    );

BoxDecoration xmumPremiumCard({bool isDark = false}) => BoxDecoration(
      color: isDark ? kDarkCard : kWhite,
      borderRadius: BorderRadius.circular(kRadiusLg),
      border: Border.all(
        color: isDark
            ? kDarkDivider
            : kPrimary.withValues(alpha: 0.08),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: kPrimary.withValues(alpha: isDark ? 0.2 : 0.08),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ],
    );

// ─── Typography helper ────────────────────────────────────────────────────────
TextStyle xmumFont({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
  double? height,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

// ─── Theme ────────────────────────────────────────────────────────────────────
ThemeData appTheme({bool isDark = false}) {
  final backgroundColor = isDark ? kDarkBackground : kGrey;
  final cardColor = isDark ? kDarkCard : kWhite;
  final textColor = isDark ? kDarkText : kTextDark;
  final textMutedColor = isDark ? kDarkTextMuted : kTextMuted;
  final dividerColor = isDark ? kDarkDivider : kDivider;

  final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
    isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    primaryColor: kPrimary,
    scaffoldBackgroundColor: backgroundColor,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      primary: kPrimary,
      secondary: kSecondary,
      tertiary: kAccent,
      surface: cardColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? kDarkCard : kWhite,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      iconTheme: IconThemeData(color: textColor),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMd),
        side: BorderSide(color: dividerColor.withValues(alpha: 0.5)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusLg),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusLg),
          side: const BorderSide(color: kPrimary, width: 1.5),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? kDarkSurface : kGreyLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMd),
        borderSide: BorderSide(
          color: dividerColor.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMd),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMd),
        borderSide: const BorderSide(color: kError, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: textMutedColor,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: textMutedColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: textColor, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: textColor, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.8,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: textColor, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: textColor, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: textColor, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: textColor, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: textColor, fontSize: 16, fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: textColor, fontSize: 15, fontWeight: FontWeight.w500,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: textColor, fontSize: 14, fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: textColor, fontSize: 16, fontWeight: FontWeight.w400,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: textColor, fontSize: 15, fontWeight: FontWeight.w400,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: textMutedColor, fontSize: 13, fontWeight: FontWeight.w400,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: textColor, fontSize: 14, fontWeight: FontWeight.w600,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: textMutedColor, fontSize: 12, fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: textMutedColor, fontSize: 11, fontWeight: FontWeight.w500,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: kPrimary,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: kPrimary,
      unselectedLabelColor: textMutedColor,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kSecondary,
      foregroundColor: kWhite,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    bottomAppBarTheme: BottomAppBarThemeData(
      color: isDark ? kDarkCard : kWhite,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMd)),
      backgroundColor: isDark ? kDarkSurface : kTextDark,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: kWhite,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kWhite;
        return isDark ? kDarkTextMuted : kTextLight;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return kPrimary.withValues(alpha: 0.5);
        }
        return isDark ? kDarkDivider : kDivider;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMd)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    )
);}

// ─── Reusable UI helpers ──────────────────────────────────────────────────────
class XmumSectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onActionTap;
  final bool isDark;

  const XmumSectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: xmumGoldAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: xmumFont(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? kDarkText : kTextDark,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        if (action != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              action!,
              style: xmumFont(
                fontSize: 13,
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class XmumHeaderPattern extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const XmumHeaderPattern({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: xmumPremiumGradient,
        borderRadius: borderRadius ??
            const BorderRadius.only(
              bottomLeft: Radius.circular(kRadiusXl),
              bottomRight: Radius.circular(kRadiusXl),
            ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kWhite.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kAccent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kWhite.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(24, 60, 24, 32),
            child: child,
          ),
        ],
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  static const _keyDarkMode = 'darkMode';
  static const _keyLanguage = 'language';
  static const _keyNotifications = 'notifications';
  static const _keyLocationServices = 'locationServices';

  bool _isDark = false;
  String _language = 'en';
  bool _notifications = true;
  bool _locationServices = true;
  bool _loaded = false;

  bool get isDark => _isDark;
  String get language => _language;
  bool get notifications => _notifications;
  bool get locationServices => _locationServices;
  bool get isLoaded => _loaded;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_keyDarkMode) ?? false;
    _language = prefs.getString(_keyLanguage) ?? 'en';
    _notifications = prefs.getBool(_keyNotifications) ?? true;
    _locationServices = prefs.getBool(_keyLocationServices) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setTheme(!_isDark);
  }

  Future<void> setTheme(bool isDark) async {
    _isDark = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, _isDark);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, _language);
    notifyListeners();
  }

  Future<void> setNotifications(bool enabled) async {
    _notifications = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, _notifications);
    notifyListeners();
  }

  Future<void> setLocationServices(bool enabled) async {
    _locationServices = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLocationServices, _locationServices);
    notifyListeners();
  }
}
