import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../widgets.dart';
import '../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text(localizations.about, style: xmumFont(fontWeight: FontWeight.w700, color: kWhite)),
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        iconTheme: const IconThemeData(color: kWhite),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: xmumPremiumCard(isDark: isDark),
              child: Column(
                children: [
                  const Center(
                    child: XmumLogo(size: 72, showText: false),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localizations.aboutXMUMNavigate,
                    textAlign: TextAlign.center,
                    style: xmumFont(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? kDarkText : kTextDark,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: xmumGoldAccent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      localizations.version,
                      style: xmumFont(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kWhite,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    localizations.aboutDescription,
                    textAlign: TextAlign.center,
                    style: xmumFont(
                      fontSize: 14,
                      color: isDark ? kDarkTextMuted : kTextMuted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _infoTile(
              context,
              Icons.school_rounded,
              localizations.aboutUniversity,
              'Xiamen University Malaysia\n厦门大学马来西亚分校',
              isDark,
            ),
            const SizedBox(height: 12),
            _infoTile(
              context,
              Icons.email_outlined,
              localizations.supportEmail,
              localizations.supportEmail,
              isDark,
            ),
            const SizedBox(height: 12),
            _infoTile(
              context,
              Icons.phone_outlined,
              'Support',
              localizations.supportPhone,
              isDark,
            ),
            const SizedBox(height: 32),
            Text(
              localizations.aboutCopyright,
              textAlign: TextAlign.center,
              style: xmumFont(
                fontSize: 12,
                color: isDark ? kDarkTextMuted : kTextLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: xmumPremiumCard(isDark: isDark),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: kPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: xmumFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? kDarkText : kTextDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: xmumFont(
                    fontSize: 13,
                    color: isDark ? kDarkTextMuted : kTextMuted,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
