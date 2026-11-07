import 'dart:io';

/// Quick reachability checks before Firebase auth calls.
class NetworkDiagnostics {
  static Future<bool> canResolveHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> registrationBlockReason() async {
    final hasGoogle = await canResolveHost('google.com');
    if (!hasGoogle) {
      return 'No internet connection detected. Connect to WiFi or mobile data and try again.';
    }

    final hasFirebase = await canResolveHost('identitytoolkit.googleapis.com');
    if (!hasFirebase) {
      return 'Internet works, but Firebase servers are blocked on this network. '
          'Switch to mobile data, use a personal hotspot, or try a different WiFi network.';
    }

    return null;
  }
}
