import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../config/social_auth_config.dart';
import '../services/firebase_service.dart';
import '../theme.dart';
import '../utils/firebase_errors.dart';
import '../utils/firebase_status.dart';
import '../screens/home_screen.dart';

/// Shared handler for Google, Apple, and Facebook sign-in on login/signup screens.
Future<void> handleSocialSignIn({
  required BuildContext context,
  required FirebaseService service,
  required Future<void> Function(bool loading) setLoading,
  required Future<UserCredential?> Function() signIn,
}) async {
  if (!FirebaseStatus.ready) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          FirebaseStatus.initError ??
              'Firebase is not ready. Restart the app after checking your connection.',
        ),
        backgroundColor: kError,
      ),
    );
    return;
  }

  await setLoading(true);
  try {
    final cred = await signIn();
    if (cred == null) return;

    final user = cred.user;
    if (user == null) return;

    try {
      await service.ensureUserProfile(user);
    } catch (profileError) {
      await service.logout();
      rethrow;
    }

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  } on SocialSignInCancelled {
    // User dismissed the provider flow — no message needed.
  } catch (e) {
    debugPrint('SOCIAL AUTH ERROR: $e (${e.runtimeType})');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyFirebaseError(e)),
          backgroundColor: kError,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  } finally {
    await setLoading(false);
  }
}

class SocialAuthSection extends StatelessWidget {
  final bool loading;
  final bool isDark;
  final VoidCallback onGoogle;

  const SocialAuthSection({
    super.key,
    required this.loading,
    required this.isDark,
    required this.onGoogle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: isDark ? kDarkDivider : kDivider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: xmumFont(
                  fontSize: 13,
                  color: isDark ? kDarkTextMuted : kTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: isDark ? kDarkDivider : kDivider)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _SocialAuthButton(
                label: 'Google',
                color: const Color(0xFFEA4335),
                icon: 'G',
                isDark: isDark,
                onPressed: loading ? null : onGoogle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialAuthButton extends StatelessWidget {
  final String label;
  final Color color;
  final String icon;
  final bool isDark;
  final bool useAppleIcon;
  final VoidCallback? onPressed;

  const _SocialAuthButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.isDark,
    this.onPressed,
  }) : useAppleIcon = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? kDarkCard : kWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? kDarkDivider : kDivider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (useAppleIcon)
                Icon(
                  Icons.apple,
                  size: 22,
                  color: isDark ? kWhite : kTextDark,
                )
              else
                Text(
                  icon,
                  style: xmumFont(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                label,
                style: xmumFont(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? kDarkTextMuted : kTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
