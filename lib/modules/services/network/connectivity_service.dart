import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  static Future<bool> isOnline({
    Duration timeout = const Duration(seconds: 5),
    Duration maxResponseTime = const Duration(seconds: 3),
  }) async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) return false;

    // Confirm actual reachability (not just a local network connection).
    try {
      final lookup = await InternetAddress.lookup('linkskool.net')
          .timeout(timeout);
      if (lookup.isEmpty || lookup.first.rawAddress.isEmpty) return false;
    } catch (_) {
      return false;
    }

    try {
      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(Uri.parse('https://linkskool.net'))
          .timeout(timeout);
      stopwatch.stop();

      if (stopwatch.elapsed > maxResponseTime) return false;
      return response.statusCode >= 200 && response.statusCode < 600;
    } catch (_) {
      return false;
    }
  }
}
