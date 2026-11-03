# store_checker_plus

A Flutter plugin that finds where the currently running app was installed from.

store_checker_plus is a maintained fork of [store_checker](https://pub.dev/packages/store_checker) by Raviteja Aketi, updated for current Flutter, Android, iOS and macOS versions. See [Migrating from store_checker](#migrating-from-store_checker).

| Platform | What it detects |
| --- | --- |
| **Android** | Google Play, the system package installer, Amazon Appstore, Huawei AppGallery, Samsung Galaxy Store, Samsung Smart Switch, OPPO / OnePlus / realme App Market, Xiaomi GetApps, vivo App Store, RuStore, Indus Appstore, other installers and local installs (adb or side-loading) |
| **iOS** | App Store, TestFlight and local builds (simulator, Xcode, ad hoc, enterprise) |
| **macOS** | Mac App Store, TestFlight and local builds (Xcode, Developer ID) |

On every other platform, including the web, `getSource` returns `Source.UNKNOWN`.

## Requirements

| | Minimum |
| --- | --- |
| Flutter | 3.47 |
| Dart | 3.13 |
| Android | API 24 (Android 7.0) |
| iOS | 15.0 |
| macOS | 12.0 |

iOS and macOS work with both Swift Package Manager and CocoaPods.

## Installation

```yaml
dependencies:
  store_checker_plus: ^2.0.0
```

## Usage

```dart
import 'package:store_checker_plus/store_checker_plus.dart';

final Source source = await StoreChecker.getSource;

final String name = switch (source) {
  Source.IS_INSTALLED_FROM_PLAY_STORE => 'Google Play',
  Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER => 'Package installer',
  Source.IS_INSTALLED_FROM_RU_STORE => 'RuStore',
  Source.IS_INSTALLED_FROM_LOCAL_SOURCE => 'Local source',
  Source.IS_INSTALLED_FROM_AMAZON_APP_STORE => 'Amazon Appstore',
  Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY => 'Huawei AppGallery',
  Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE => 'Samsung Galaxy Store',
  Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE => 'Samsung Smart Switch',
  Source.IS_INSTALLED_FROM_OPPO_APP_MARKET => 'OPPO App Market',
  Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS => 'Xiaomi GetApps',
  Source.IS_INSTALLED_FROM_VIVO_APP_STORE => 'vivo App Store',
  Source.IS_INSTALLED_FROM_INDUS_APP_STORE => 'Indus Appstore',
  Source.IS_INSTALLED_FROM_OTHER_SOURCE => 'Other source',
  Source.IS_INSTALLED_FROM_APP_STORE => 'App Store',
  Source.IS_INSTALLED_FROM_TEST_FLIGHT => 'TestFlight',
  Source.UNKNOWN => 'Unknown',
};
```

### Android installer package names

`getSource` maps the Android installer package name to a `Source`:

| `Source` | Installer package name |
| --- | --- |
| `IS_INSTALLED_FROM_PLAY_STORE` | `com.android.vending` |
| `IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER` | `com.google.android.packageinstaller`, `com.android.packageinstaller` |
| `IS_INSTALLED_FROM_AMAZON_APP_STORE` | `com.amazon.venezia` |
| `IS_INSTALLED_FROM_HUAWEI_APP_GALLERY` | `com.huawei.appmarket` |
| `IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE` | `com.sec.android.app.samsungapps` |
| `IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE` | `com.sec.android.easyMover` |
| `IS_INSTALLED_FROM_OPPO_APP_MARKET` | `com.oppo.market`, `com.heytap.market` |
| `IS_INSTALLED_FROM_XIAOMI_GET_APPS` | `com.xiaomi.mipicks` |
| `IS_INSTALLED_FROM_VIVO_APP_STORE` | `com.vivo.appstore` |
| `IS_INSTALLED_FROM_RU_STORE` | `ru.vk.store` |
| `IS_INSTALLED_FROM_INDUS_APP_STORE` | `com.indus.appstore` |
| `IS_INSTALLED_FROM_LOCAL_SOURCE` | none (adb, `flutter run`, or the installer was uninstalled) |
| `IS_INSTALLED_FROM_OTHER_SOURCE` | anything else |

Phone makers ship their own installers, so you may get `IS_INSTALLED_FROM_OTHER_SOURCE` on some devices. To see which installer it was, read the raw package name:

```dart
final String? installer = await StoreChecker.installerPackageName; // Android only
```

### Google Play testing tracks

Android does not tell an app which Google Play track (internal, closed, open or production) it was installed from. Every track reports `com.android.vending`, so `getSource` returns `IS_INSTALLED_FROM_PLAY_STORE` for all of them. The same build can also be promoted from one track to another, so a flag compiled into the app cannot tell them apart either. If your app needs to behave differently for testers, decide that on your server or with a remote config keyed by user or version.

### iOS and macOS

* The simulator and builds run from Xcode, ad hoc and enterprise builds (and Developer ID builds on macOS) return `IS_INSTALLED_FROM_LOCAL_SOURCE`.
* TestFlight is detected from the sandbox App Store receipt on iOS and from the code signing certificate on macOS.

## Testing code that uses StoreChecker

The plugin picks the platform from `defaultTargetPlatform`, so in widget and unit tests you can choose the platform with `debugDefaultTargetPlatformOverride` and answer the method channel yourself:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_checker_plus/store_checker_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('detects TestFlight', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('store_checker_plus'),
          (MethodCall call) async => 'TestFlight', // 'AppStore', 'TestFlight' or ''
        );

    expect(await StoreChecker.getSource, Source.IS_INSTALLED_FROM_TEST_FLIGHT);

    debugDefaultTargetPlatformOverride = null;
  });
}
```

On Android, answer with the installer package name instead, for example `'com.android.vending'`.

## Migrating from store_checker

* Replace `store_checker` with `store_checker_plus` in `pubspec.yaml`, and change imports to `package:store_checker_plus/store_checker_plus.dart`. The `StoreChecker` class and the `Source` values keep their names.
* If your tests mock the method channel, its name is now `store_checker_plus`.
* The minimum versions went up: Flutter 3.47, Dart 3.13, Android API 24, iOS 15 and macOS 12. Stay on store_checker 1.8.0 if you can't upgrade yet.
* `Source.IS_INSTALLED_FROM_INDUS_APP_STORE` is new. Add it to any `switch` over `Source` that has no default case.
* `com.android.packageinstaller` now returns `IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER` instead of `IS_INSTALLED_FROM_OTHER_SOURCE`, and `com.heytap.market` now returns `IS_INSTALLED_FROM_OPPO_APP_MARKET`.
* `getSource` now returns `Source.UNKNOWN` on unsupported platforms instead of throwing `MissingPluginException`.

## Issues and feedback

Please file [issues](https://github.com/tologonkudaiberdiuulu/store_checker_plus/issues) to send feedback or report a bug. Thank you!
