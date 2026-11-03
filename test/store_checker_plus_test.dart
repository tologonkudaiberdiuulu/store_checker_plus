import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_checker_plus/store_checker_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('store_checker_plus');
  final List<MethodCall> calls = <MethodCall>[];

  /// Makes the native side answer `getSource` with [value].
  void mockNative(String? value) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return value;
        });
  }

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Android', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

    const Map<String?, Source> expected = <String?, Source>{
      null: Source.IS_INSTALLED_FROM_LOCAL_SOURCE,
      'com.android.vending': Source.IS_INSTALLED_FROM_PLAY_STORE,
      'com.google.android.packageinstaller':
          Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER,
      'com.android.packageinstaller':
          Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER,
      'ru.vk.store': Source.IS_INSTALLED_FROM_RU_STORE,
      'com.amazon.venezia': Source.IS_INSTALLED_FROM_AMAZON_APP_STORE,
      'com.huawei.appmarket': Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY,
      'com.sec.android.app.samsungapps':
          Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE,
      'com.sec.android.easyMover':
          Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE,
      'com.oppo.market': Source.IS_INSTALLED_FROM_OPPO_APP_MARKET,
      'com.heytap.market': Source.IS_INSTALLED_FROM_OPPO_APP_MARKET,
      'com.xiaomi.mipicks': Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS,
      'com.vivo.appstore': Source.IS_INSTALLED_FROM_VIVO_APP_STORE,
      'com.indus.appstore': Source.IS_INSTALLED_FROM_INDUS_APP_STORE,
      'com.example.unknown.store': Source.IS_INSTALLED_FROM_OTHER_SOURCE,
    };

    expected.forEach((String? installer, Source source) {
      test('$installer -> ${source.name}', () async {
        mockNative(installer);
        expect(await StoreChecker.getSource, source);
        expect(calls.single.method, 'getSource');
      });
    });

    test('installerPackageName returns the raw installer', () async {
      mockNative('com.oneplus.backuprestore');
      expect(
        await StoreChecker.installerPackageName,
        'com.oneplus.backuprestore',
      );
    });
  });

  for (final TargetPlatform platform in <TargetPlatform>[
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    group(platform.name, () {
      setUp(() => debugDefaultTargetPlatformOverride = platform);

      const Map<String?, Source> expected = <String?, Source>{
        'AppStore': Source.IS_INSTALLED_FROM_APP_STORE,
        'TestFlight': Source.IS_INSTALLED_FROM_TEST_FLIGHT,
        '': Source.IS_INSTALLED_FROM_LOCAL_SOURCE,
        null: Source.UNKNOWN,
      };

      expected.forEach((String? value, Source source) {
        test('"$value" -> ${source.name}', () async {
          mockNative(value);
          expect(await StoreChecker.getSource, source);
        });
      });

      test('installerPackageName is null', () async {
        mockNative('AppStore');
        expect(await StoreChecker.installerPackageName, isNull);
        expect(calls, isEmpty);
      });
    });
  }

  for (final TargetPlatform platform in <TargetPlatform>[
    TargetPlatform.linux,
    TargetPlatform.windows,
    TargetPlatform.fuchsia,
  ]) {
    test(
      '${platform.name} returns UNKNOWN without calling native code',
      () async {
        debugDefaultTargetPlatformOverride = platform;
        mockNative('com.android.vending');
        expect(await StoreChecker.getSource, Source.UNKNOWN);
        expect(await StoreChecker.installerPackageName, isNull);
        expect(calls, isEmpty);
      },
    );
  }
}
