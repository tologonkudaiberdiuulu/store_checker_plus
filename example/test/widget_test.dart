import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_checker_plus_example/main.dart';

void main() {
  const MethodChannel channel = MethodChannel('store_checker_plus');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('shows the installation source', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (MethodCall call) async => 'com.android.vending',
        );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Installed from: Play Store'), findsOneWidget);
    expect(find.text('Installer package: com.android.vending'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });
}
