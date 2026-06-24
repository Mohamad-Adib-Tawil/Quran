import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// كشف حالة الاتصال بالإنترنت.
/// يجمع بين واجهة النظام (connectivity_plus) وفحص DNS فعلي.
class ConnectivityService {
  final Connectivity _conn = Connectivity();

  /// هل توجد واجهة شبكة أصلاً (Wi-Fi / Mobile / Ethernet)?
  Future<bool> hasInterface() async {
    final results = await _conn.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// فحص فعلي للإنترنت: DNS lookup على CDN السور مع مهلة قصيرة.
  /// أدق من hasInterface — يكشف "متصل بالراوتر لكن لا إنترنت".
  Future<bool> hasInternet({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!await hasInterface()) return false;
    try {
      final result = await InternetAddress.lookup('quran.devmmnd.com')
          .timeout(timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Stream يصدر true/false عند تغيّر حالة الاتصال.
  Stream<bool> get onlineStream => _conn.onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );
}
