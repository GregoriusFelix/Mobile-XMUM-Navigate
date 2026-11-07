import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Connect to local Firebase emulators (auth + firestore).
/// Run: firebase emulators:start --only auth,firestore
/// Then: flutter run --dart-define=USE_FIREBASE_EMULATOR=true
Future<void> connectFirebaseEmulatorsIfEnabled() async {
  const enabled = bool.fromEnvironment('USE_FIREBASE_EMULATOR');
  if (!enabled) return;

  final host = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
      ? '10.0.2.2'
      : 'localhost';

  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

  debugPrint('Firebase emulators connected at $host (auth:9099, firestore:8080)');
}
