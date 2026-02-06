import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class AppLogger {
  void d(String message, {Object? data}) {
    if (kDebugMode) dev.log(message, name: 'DEBUG', error: data);
  }

  void i(String message, {Object? data}) {
    dev.log(message, name: 'INFO', error: data);
  }

  void w(String message, {Object? data, StackTrace? stackTrace}) {
    dev.log(message, name: 'WARN', error: data, stackTrace: stackTrace);
  }

  void e(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(message, name: 'ERROR', error: error ?? message, stackTrace: stackTrace);
  }
}

class CrashReporter {
  final AppLogger _logger;
  CrashReporter(this._logger);

  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    _logger.e('FlutterError', error: details.exception, stackTrace: details.stack);
    // TODO: Integrate Sentry/FirebaseCrashlytics here.
  }

  Future<void> recordError(Object error, StackTrace stack) async {
    _logger.e('Uncaught error', error: error, stackTrace: stack);
    // TODO: Integrate Sentry/FirebaseCrashlytics here.
  }
}
