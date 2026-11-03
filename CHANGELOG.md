## 2.0.0
First release as `store_checker_plus`, a maintained fork of [store_checker](https://pub.dev/packages/store_checker) 1.8.0. Issue numbers below refer to the [store_checker issue tracker](https://github.com/ravitejaavv/store_checker/issues).

* **Breaking:** renamed the package to `store_checker_plus`. Import `package:store_checker_plus/store_checker_plus.dart`. The method channel is now `store_checker_plus`.
* **Breaking:** requires Flutter 3.47, Dart 3.13, Android API 24, iOS 15 and macOS 12.
* **Breaking:** added `Source.IS_INSTALLED_FROM_INDUS_APP_STORE` (`com.indus.appstore`) ([#43](https://github.com/ravitejaavv/store_checker/issues/43)).
* The AOSP package installer (`com.android.packageinstaller`), used on OnePlus and other devices, is now detected as `IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER` ([#46](https://github.com/ravitejaavv/store_checker/issues/46)).
* The OPPO / OnePlus / realme App Market (`com.heytap.market`) is now detected as `IS_INSTALLED_FROM_OPPO_APP_MARKET`.
* Added `StoreChecker.installerPackageName` to read the raw Android installer package name.
* Android uses `getInstallSourceInfo` on Android 11+ and no longer calls the deprecated `getFlutterEngine`, so the build no longer prints "uses or overrides a deprecated API" ([#12](https://github.com/ravitejaavv/store_checker/issues/12)).
* Platform detection uses `defaultTargetPlatform` instead of `dart:io`, so it can be overridden in tests and the package compiles for the web ([#17](https://github.com/ravitejaavv/store_checker/issues/17)).
* `getSource` returns `Source.UNKNOWN` on unsupported platforms instead of throwing `MissingPluginException`.
* Added Swift Package Manager support for iOS and macOS ([#44](https://github.com/ravitejaavv/store_checker/issues/44)).
* Added a privacy manifest for iOS and macOS.
* Fixed CocoaPods builds on Apple Silicon simulators (the podspec limited simulator builds to `x86_64`).
* Updated Android to AGP 9.1, Gradle 9.3 and compileSdk 36, using the Kotlin DSL.
* Documented macOS support, the Android installer package names and Google Play testing tracks in the README ([#34](https://github.com/ravitejaavv/store_checker/issues/34), [#42](https://github.com/ravitejaavv/store_checker/issues/42)).
* Regenerated the example app with the current Flutter templates.

## 1.8.0
Android gradle fixes
## 1.7.0
flutter 3.29.0 support
## 1.6.0
macos support
## 1.5.0
AGP 8 support
## 1.4.0
Bug fix: Simulator detection
https://github.com/ravitejaavv/store_checker/issues/19
## 1.3.0
* Added RuStore detection
* Migrate jCenter to mavenCentral
## 1.2.0
* Added Google Package Installer detection
## 1.1.0
* Added Samsung Smart Switch Mobile detection
## 1.0.0
* Added Huawei, Samsung, Oppo, Xiaomi & Vivo app stores detection
## 0.1.0
* Migrate to null safety
## 0.0.6
* Removed unused files
* Code format
## 0.0.5
* App Store detection fix
## 0.0.4
* Code format
## 0.0.3
* Added Amazon app store detection
## 0.0.2
* Added more detail to the description field of pubspec.yaml
* Added code documentation
## 0.0.1
* Initial release