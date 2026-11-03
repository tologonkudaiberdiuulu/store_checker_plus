// The SCREAMING_CASE enum values are part of the public API since 0.0.1 and
// are kept as they are to avoid breaking existing apps.
// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Where the currently running app was installed from.
enum Source {
  /// Installed from Google Play Store (`com.android.vending`).
  IS_INSTALLED_FROM_PLAY_STORE,

  /// Installed by the system package installer, for example by opening an APK
  /// file or through Firebase App Distribution.
  ///
  /// Matches both Google's build of the installer
  /// (`com.google.android.packageinstaller`) and the AOSP one
  /// (`com.android.packageinstaller`) used by OnePlus and other OEMs.
  IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER,

  /// Installed from RuStore (`ru.vk.store`).
  IS_INSTALLED_FROM_RU_STORE,

  /// Installed without an installer app: `adb install`, `flutter run`, a
  /// side-loaded file on Android, or a debug, ad hoc or enterprise build on
  /// iOS and macOS.
  IS_INSTALLED_FROM_LOCAL_SOURCE,

  /// Installed from Amazon Appstore (`com.amazon.venezia`).
  IS_INSTALLED_FROM_AMAZON_APP_STORE,

  /// Installed from Huawei AppGallery (`com.huawei.appmarket`).
  IS_INSTALLED_FROM_HUAWEI_APP_GALLERY,

  /// Installed from Samsung Galaxy Store (`com.sec.android.app.samsungapps`).
  IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE,

  /// Transferred by Samsung Smart Switch Mobile (`com.sec.android.easyMover`).
  IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE,

  /// Installed from the OPPO / OnePlus / realme App Market
  /// (`com.oppo.market` or `com.heytap.market`).
  IS_INSTALLED_FROM_OPPO_APP_MARKET,

  /// Installed from Xiaomi GetApps (`com.xiaomi.mipicks`).
  IS_INSTALLED_FROM_XIAOMI_GET_APPS,

  /// Installed from vivo App Store (`com.vivo.appstore`).
  IS_INSTALLED_FROM_VIVO_APP_STORE,

  /// Installed from Indus Appstore (`com.indus.appstore`).
  IS_INSTALLED_FROM_INDUS_APP_STORE,

  /// Installed by an Android app that this plugin does not recognise. Use
  /// [StoreChecker.installerPackageName] to see which one.
  IS_INSTALLED_FROM_OTHER_SOURCE,

  /// Installed from the App Store or the Mac App Store.
  IS_INSTALLED_FROM_APP_STORE,

  /// Installed from TestFlight.
  IS_INSTALLED_FROM_TEST_FLIGHT,

  /// The source could not be determined, or the platform is not supported.
  UNKNOWN,
}

/// Finds the origin of the installed apk/ipa/app.
class StoreChecker {
  static const MethodChannel _channel = MethodChannel('store_checker_plus');

  /// Android installer package names and the [Source] each one maps to.
  static const Map<String, Source> _androidInstallers = <String, Source>{
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
  };

  /// Gets the origin of the installed apk/ipa/app.
  ///
  /// Returns [Source.UNKNOWN] on platforms other than Android, iOS and macOS,
  /// including the web.
  static Future<Source> get getSource async {
    if (kIsWeb) {
      return Source.UNKNOWN;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidSource(await _invokeGetSource());
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _appleSource(await _invokeGetSource());
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return Source.UNKNOWN;
    }
  }

  /// The package name of the app that installed this app on Android, for
  /// example `com.android.vending` for Google Play.
  ///
  /// Use it to handle installers that [getSource] reports as
  /// [Source.IS_INSTALLED_FROM_OTHER_SOURCE]. It is `null` when the app was
  /// installed without an installer app, and always `null` on other
  /// platforms.
  static Future<String?> get installerPackageName async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    return _invokeGetSource();
  }

  static Future<String?> _invokeGetSource() =>
      _channel.invokeMethod<String>('getSource');

  static Source _androidSource(String? installer) {
    if (installer == null || installer.isEmpty) {
      // Installed with adb, side-loaded, or the installer was uninstalled.
      return Source.IS_INSTALLED_FROM_LOCAL_SOURCE;
    }
    return _androidInstallers[installer] ??
        Source.IS_INSTALLED_FROM_OTHER_SOURCE;
  }

  static Source _appleSource(String? source) {
    switch (source) {
      case null:
        return Source.UNKNOWN;
      case '':
        // Simulator, Xcode, ad hoc, enterprise or Developer ID build.
        return Source.IS_INSTALLED_FROM_LOCAL_SOURCE;
      case 'AppStore':
        return Source.IS_INSTALLED_FROM_APP_STORE;
      case 'TestFlight':
        return Source.IS_INSTALLED_FROM_TEST_FLIGHT;
      default:
        return Source.UNKNOWN;
    }
  }
}
