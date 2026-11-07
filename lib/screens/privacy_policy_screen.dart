import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    final sections = [
      (localizations.privacyDataCollection, localizations.privacyDataCollectionBody),
      (localizations.privacyDataUsage, localizations.privacyDataUsageBody),
      (localizations.privacyDataSharing, localizations.privacyDataSharingBody),
      (localizations.privacyYourRights, localizations.privacyYourRightsBody),
      (localizations.privacySecurity, localizations.privacySecurityBody),
    ];

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text(localizations.privacyPolicy, style: xmumFont(fontWeight: FontWeight.w700)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: xmumPremiumGradient)),
        foregroundColor: kWhite,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: sections.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              localizations.privacyIntro,
              style: xmumFont(
                fontSize: 14,
                color: isDark ? kDarkTextMuted : kTextMuted,
                height: 1.6,
              ),
            );
          }
          final (title, body) = sections[index - 1];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: xmumPremiumCard(isDark: isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        gradient: xmumGoldAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: xmumFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? kDarkText : kTextDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: xmumFont(
                    fontSize: 14,
                    color: isDark ? kDarkTextMuted : kTextMuted,
                    height: 1.6,
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
