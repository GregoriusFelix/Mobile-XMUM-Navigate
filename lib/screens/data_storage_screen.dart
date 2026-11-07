import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../widgets.dart';
import '../l10n/app_localizations.dart';

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  bool _clearing = false;
  String _cacheSize = '—';

  @override
  void initState() {
    super.initState();
    _estimateCacheSize();
  }

  Future<void> _estimateCacheSize() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    var bytes = 0;
    for (final key in keys) {
      final value = prefs.get(key);
      bytes += key.length + (value?.toString().length ?? 0);
    }
    if (mounted) {
      setState(() {
        _cacheSize = bytes < 1024
            ? '$bytes B'
            : bytes < 1024 * 1024
                ? '${(bytes / 1024).toStringAsFixed(1)} KB'
                : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      });
    }
  }

  Future<void> _clearCache() async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.clearCache),
        content: Text(localizations.clearCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              localizations.clearCache,
              style: const TextStyle(color: kError),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _clearing = true);
    final prefs = await SharedPreferences.getInstance();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Preserve user preferences while clearing other cached data
    final darkMode = themeProvider.isDark;
    final language = themeProvider.language;
    final notifications = themeProvider.notifications;
    final locationServices = themeProvider.locationServices;

    await prefs.clear();
    await prefs.setBool('darkMode', darkMode);
    await prefs.setString('language', language);
    await prefs.setBool('notifications', notifications);
    await prefs.setBool('locationServices', locationServices);

    await _estimateCacheSize();
    if (mounted) {
      setState(() => _clearing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.cacheCleared)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : kGrey,
      appBar: AppBar(
        title: Text(localizations.dataStorage, style: xmumFont(fontWeight: FontWeight.w700)),
        flexibleSpace: Container(decoration: BoxDecoration(gradient: xmumPremiumGradient)),
        foregroundColor: kWhite,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: xmumPremiumCard(isDark: isDark),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storage_rounded, color: kPrimary, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.cachedData,
                    style: xmumFont(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? kDarkText : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _cacheSize,
                    style: xmumFont(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: kPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.cacheDescription,
                    textAlign: TextAlign.center,
                    style: xmumFont(
                      fontSize: 13,
                      color: isDark ? kDarkTextMuted : kTextMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ParkButton(
              label: localizations.clearCache,
              icon: Icons.delete_outline_rounded,
              isSecondary: true,
              onPressed: _clearing ? null : _clearCache,
            ),
            if (_clearing) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: kPrimary),
            ],
          ],
        ),
      ),
    );
  }
}
