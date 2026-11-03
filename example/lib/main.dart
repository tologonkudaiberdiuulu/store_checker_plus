import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:store_checker_plus/store_checker_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _source = 'Checking…';
  String? _installer;

  @override
  void initState() {
    super.initState();
    _checkSource();
  }

  Future<void> _checkSource() async {
    Source source;
    String? installer;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      source = await StoreChecker.getSource;
      installer = await StoreChecker.installerPackageName;
    } on PlatformException {
      source = Source.UNKNOWN;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _source = describe(source);
      _installer = installer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('store_checker_plus example')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Installed from: $_source'),
              if (_installer != null) Text('Installer package: $_installer'),
            ],
          ),
        ),
      ),
    );
  }
}

/// A readable name for [source].
String describe(Source source) {
  return switch (source) {
    Source.IS_INSTALLED_FROM_PLAY_STORE => 'Play Store',
    Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER => 'Package installer',
    Source.IS_INSTALLED_FROM_RU_STORE => 'RuStore',
    Source.IS_INSTALLED_FROM_LOCAL_SOURCE => 'Local source',
    Source.IS_INSTALLED_FROM_AMAZON_APP_STORE => 'Amazon Appstore',
    Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY => 'Huawei AppGallery',
    Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE => 'Samsung Galaxy Store',
    Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE =>
      'Samsung Smart Switch Mobile',
    Source.IS_INSTALLED_FROM_OPPO_APP_MARKET => 'OPPO App Market',
    Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS => 'Xiaomi GetApps',
    Source.IS_INSTALLED_FROM_VIVO_APP_STORE => 'vivo App Store',
    Source.IS_INSTALLED_FROM_INDUS_APP_STORE => 'Indus Appstore',
    Source.IS_INSTALLED_FROM_OTHER_SOURCE => 'Other source',
    Source.IS_INSTALLED_FROM_APP_STORE => 'App Store',
    Source.IS_INSTALLED_FROM_TEST_FLIGHT => 'TestFlight',
    Source.UNKNOWN => 'Unknown source',
  };
}
