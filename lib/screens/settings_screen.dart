import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';
import '../utils/xmum_page_route.dart';
import '../widgets/xmum_animations.dart';
import 'help_screen.dart';
import 'change_password_screen.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'data_storage_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = themeProvider.isDark;

    final sections = <(String, List<Widget>)>[
      (
        localizations.appPreferences,
        [
          _SettingsSwitchTile(
            icon: Icons.notifications_outlined,
            title: localizations.notifications,
            subtitle: localizations.campusAlerts,
            value: themeProvider.notifications,
            onChanged: (v) async {
              await themeProvider.setNotifications(v);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      v ? localizations.notificationsEnabled : localizations.notificationsDisabled,
                    ),
                  ),
                );
              }
            },
          ),
          _SettingsSwitchTile(
            icon: Icons.location_on_outlined,
            title: localizations.locationServices,
            subtitle: localizations.requiredForNavigation,
            value: themeProvider.locationServices,
            onChanged: (v) async {
              await themeProvider.setLocationServices(v);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      v ? localizations.locationEnabled : localizations.locationDisabled,
                    ),
                  ),
                );
              }
            },
          ),
          _SettingsSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: localizations.darkMode,
            subtitle: localizations.switchToDarkTheme,
            value: isDark,
            onChanged: (v) => themeProvider.setTheme(v),
          ),
        ],
      ),
      (
        localizations.languageAndRegion,
        [
          _SettingsDropdownTile(
            icon: Icons.language_outlined,
            title: localizations.language,
            value: _languageName(themeProvider.language),
            items: const ['English', 'Bahasa Malaysia'],
            onChanged: (v) {
              if (v == null) return;
              final code = v == 'Bahasa Malaysia' ? 'ms' : 'en';
              themeProvider.setLanguage(code);
            },
          ),
        ],
      ),
      (
        localizations.privacyAndSecurity,
        [
          _SettingsNavTile(
            icon: Icons.lock_outline,
            title: localizations.changePassword,
            subtitle: localizations.updateYourPassword,
            onTap: () => xmumPush(context, const ChangePasswordScreen()),
          ),
          _SettingsNavTile(
            icon: Icons.privacy_tip_outlined,
            title: localizations.privacyPolicy,
            subtitle: localizations.howWeUseYourData,
            onTap: () => xmumPush(context, const PrivacyPolicyScreen()),
          ),
          _SettingsNavTile(
            icon: Icons.shield_outlined,
            title: localizations.dataStorage,
            subtitle: localizations.manageCachedData,
            onTap: () => xmumPush(context, const DataStorageScreen()),
            showDivider: false,
          ),
        ],
      ),
      (
        localizations.support,
        [
          _SettingsNavTile(
            icon: Icons.help_outline,
            title: localizations.helpAndFAQ,
            subtitle: localizations.getAnswersToCommonQuestions,
            onTap: () => xmumPush(context, const HelpScreen()),
          ),
          _SettingsNavTile(
            icon: Icons.info_outline,
            title: localizations.about,
            subtitle: localizations.version,
            onTap: () => xmumPush(context, const AboutScreen()),
            showDivider: false,
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text(localizations.settings, style: xmumFont(fontWeight: FontWeight.w700, color: kWhite)),
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        iconTheme: const IconThemeData(color: kWhite),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: sections.length,
        itemBuilder: (context, sectionIndex) {
          final (label, tiles) = sections[sectionIndex];
          return XmumStaggeredItem(
            index: sectionIndex,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      label,
                      style: xmumFont(
                        fontSize: 12,
                        color: isDark ? kDarkTextMuted : kTextMuted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    decoration: xmumPremiumCard(isDark: isDark),
                    child: Column(children: tiles),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _languageName(String code) {
    switch (code) {
      case 'ms':
        return 'Bahasa Malaysia';
      case 'en':
      default:
        return 'English';
    }
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? kDarkDivider : kDivider.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        children: [
          _SettingsIconBox(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: xmumFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? kDarkText : kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: xmumFont(
                    fontSize: 12,
                    color: isDark ? kDarkTextMuted : kTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsDropdownTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SettingsDropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _SettingsIconBox(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: xmumFont(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? kDarkText : kTextDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? kDarkSurface : kGreyLight,
              borderRadius: BorderRadius.circular(kRadiusSm),
              border: Border.all(
                color: isDark ? kDarkDivider : kDivider,
              ),
            ),
            child: DropdownButton<String>(
              value: value,
              underline: const SizedBox(),
              dropdownColor: isDark ? kDarkCard : kWhite,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isDark ? kDarkTextMuted : kTextMuted,
              ),
              items: items
                  .map(
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(
                        i,
                        style: xmumFont(
                          fontSize: 13,
                          color: isDark ? kDarkText : kTextDark,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return XmumScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: isDark ? kDarkDivider : kDivider.withValues(alpha: 0.6),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            _SettingsIconBox(icon: icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: xmumFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? kDarkText : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: xmumFont(
                      fontSize: 12,
                      color: isDark ? kDarkTextMuted : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? kDarkTextMuted : kTextLight,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsIconBox extends StatelessWidget {
  final IconData icon;

  const _SettingsIconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimary.withValues(alpha: isDark ? 0.25 : 0.1),
            kAccent.withValues(alpha: isDark ? 0.15 : 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 20, color: isDark ? kAccent : kPrimary),
    );
  }
}
