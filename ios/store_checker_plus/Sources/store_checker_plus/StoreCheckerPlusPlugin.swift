import Flutter
import Foundation

/// Finds out whether the app was installed from the App Store, TestFlight or another source.
public class StoreCheckerPlusPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "store_checker_plus", binaryMessenger: registrar.messenger())
        let instance = StoreCheckerPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getSource":
            if isRunningInTestFlightEnvironment() {
                result("TestFlight")
            } else if isRunningInAppStoreEnvironment() {
                result("AppStore")
            } else {
                // Simulator, Xcode, ad hoc, enterprise or any other locally signed build.
                result("")
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // TestFlight builds have a sandbox receipt but no embedded provisioning profile.
    private func isRunningInTestFlightEnvironment() -> Bool {
        if isSimulator() {
            return false
        }
        return isAppStoreReceiptSandbox() && !hasEmbeddedMobileProvision()
    }

    // App Store builds have neither a sandbox receipt nor an embedded provisioning profile.
    private func isRunningInAppStoreEnvironment() -> Bool {
        if isSimulator() {
            return false
        }
        return !isAppStoreReceiptSandbox() && !hasEmbeddedMobileProvision()
    }

    private func hasEmbeddedMobileProvision() -> Bool {
        return Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil
    }

    private func isAppStoreReceiptSandbox() -> Bool {
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    private func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
