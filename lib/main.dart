import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'utils/firebase_status.dart';
import 'utils/firebase_emulator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  String? firebaseError;

  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await connectFirebaseEmulatorsIfEnabled();
      firebaseReady = true;
      FirebaseStatus.ready = true;
      FirebaseStatus.usingEmulator =
          const bool.fromEnvironment('USE_FIREBASE_EMULATOR');
    } catch (e) {
      firebaseError = e.toString();
      FirebaseStatus.initError = firebaseError;
    }
  } else {
    firebaseError =
        'Firebase config missing. Run `flutterfire configure` and set isConfigured = true in lib/firebase_options.dart.';
    FirebaseStatus.initError = firebaseError;
  }

  runApp(XMUMNavigateApp(
    firebaseReady: firebaseReady,
    firebaseError: firebaseError,
  ));
}

class XMUMNavigateApp extends StatelessWidget {
  const XMUMNavigateApp({
    super.key,
    required this.firebaseReady,
    this.firebaseError,
  });

  final bool firebaseReady;
  final String? firebaseError;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final theme = appTheme(isDark: themeProvider.isDark);

          return AnimatedTheme(
            duration: kThemeAnimDuration,
            curve: kAnimCurve,
            data: theme,
            child: MaterialApp(
              title: 'XMUM Navigate',
              debugShowCheckedModeBanner: false,
              theme: theme,
              locale: Locale(themeProvider.language),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('ms'),
              ],
              home: SplashScreen(
                firebaseReady: firebaseReady,
                firebaseError: firebaseError,
              ),
            ),
          );
        },
      ),
    );
  }
}
