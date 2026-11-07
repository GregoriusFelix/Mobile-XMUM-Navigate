import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../l10n/app_localizations.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I navigate to a building?',
      'a': 'Tap the Map tab, use the search bar to find your destination, then tap "Go Now" to start navigation.',
    },
    {
      'q': 'How do I find halal food?',
      'a': 'Go to the Food tab. All food listings show a Halal badge if the food is certified halal.',
    },
    {
      'q': 'How do I book a venue for my event?',
      'a': 'Go to the Venues tab, select a venue, and tap "Enquire" to send a booking request to the admin.',
    },
    {
      'q': 'How do I update my profile?',
      'a': 'Go to Profile, tap "Edit Profile", update your details, and tap Save Changes.',
    },
    {
      'q': 'Does the app work without internet?',
      'a': 'Basic navigation may work offline but food recommendations and venue bookings require an internet connection.',
    },
  ];

  final List<bool> _expanded = List.filled(5, false);
  final _messageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).helpAndFAQ, style: xmumFont(fontWeight: FontWeight.w700, color: kWhite)),
        backgroundColor: kPrimary,
        foregroundColor: kWhite,
        iconTheme: const IconThemeData(color: kWhite),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: xmumPremiumGradient,
              borderRadius: BorderRadius.circular(kRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: xmumGlassDecoration(),
                child: const Icon(Icons.support_agent_rounded, color: kAccent, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context).needHelp,
                    style: xmumFont(color: kWhite, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context).browseOurFAQs,
                    style: xmumFont(color: kWhite.withValues(alpha: 0.75), fontSize: 13, height: 1.4)),
              ])),
            ]),
          ),
          const SizedBox(height: 24),

          // FAQs
          Text(AppLocalizations.of(context).frequentlyAskedQuestions,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? kDarkText : kTextDark)),
          const SizedBox(height: 12),
          ...List.generate(_faqs.length, (i) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(_faqs[i]['q']!,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? kDarkText : kTextDark)),
                iconColor: kSetelGreen,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(_faqs[i]['a']!,
                        style: TextStyle(fontSize: 14, color: isDark ? kDarkTextMuted : kTextMuted, height: 1.5)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Contact form
          Text(AppLocalizations.of(context).sendUsAMessage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? kDarkText : kTextDark)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(children: [
              TextFormField(
                controller: _messageCtrl,
                maxLines: 4,
                style: TextStyle(fontSize: 14, color: isDark ? kDarkText : kTextDark),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).describeYourIssue,
                  hintStyle: TextStyle(color: (isDark ? kDarkTextMuted : kTextMuted).withValues(alpha: 0.6), fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? kDarkDivider : kDivider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? kDarkDivider : kDivider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kSetelGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: isDark ? kDarkSurface : kGreyLight,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context).messageSent),
                          backgroundColor: Colors.green),
                    );
                    _messageCtrl.clear();
                  },
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(AppLocalizations.of(context).sendMessage, style: const TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: kSetelGreen,
                    foregroundColor: kWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Contact info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kSetelLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kSetelGreen.withValues(alpha: 0.2)),
            ),
            child: Column(children: [
              Row(children: [
                Icon(Icons.email_outlined, size: 18, color: kSetelGreen),
                SizedBox(width: 12),
                Text('support@xmumnavigate.com', style: TextStyle(fontSize: 13, color: isDark ? kDarkText : kTextDark)),
              ]),
              SizedBox(height: 12),
              Row(children: [
                Icon(Icons.phone_outlined, size: 18, color: kSetelGreen),
                SizedBox(width: 12),
                Text('+60 3-8966 xxxx', style: TextStyle(fontSize: 13, color: isDark ? kDarkText : kTextDark)),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
