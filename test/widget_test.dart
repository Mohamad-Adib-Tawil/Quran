import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_library/quran_library.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran_app/core/di/service_locator.dart';
import 'package:quran_app/main.dart';

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);
const MethodChannel _connectivityChannel = MethodChannel(
  'dev.fluttercommunity.plus/connectivity',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;

  setUpAll(() async {
    tempDirectory = await Directory.systemTemp.createTemp('quran_widget_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getTemporaryDirectory':
            case 'getApplicationDocumentsDirectory':
            case 'getApplicationSupportDirectory':
            case 'getLibraryDirectory':
            case 'getApplicationCacheDirectory':
            case 'getExternalStorageDirectory':
            case 'getDownloadsDirectory':
              return tempDirectory.path;
            case 'getExternalCacheDirectories':
            case 'getExternalStorageDirectories':
              return <String>[tempDirectory.path];
            default:
              return null;
          }
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, (call) async {
          if (call.method == 'check') {
            return <String>['wifi'];
          }
          return null;
        });

    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await sl.reset(dispose: true);
    await QuranLibrary.init();
    await setupLocator();
  });

  tearDownAll(() async {
    await sl.reset(dispose: true);
    GoogleFonts.config.allowRuntimeFetching = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, null);
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const QuranApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
