/// Set during app startup in main.dart.
class FirebaseStatus {
  static bool ready = false;
  static bool usingEmulator = false;
  static String? initError;
}
