import FlutterMacOS
import Foundation

/// Finds out whether the app was installed from the Mac App Store, TestFlight or another source.
public class StoreCheckerPlusPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "store_checker_plus", binaryMessenger: registrar.messenger)
        let instance = StoreCheckerPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getSource":
            if Bundle.main.isTestFlight {
                result("TestFlight")
            } else if Bundle.main.isAppStore {
                result("AppStore")
            } else {
                // Xcode, Developer ID or any other locally signed build.
                result("")
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

private extension Bundle {

    /// Returns whether the bundle was installed through the App Store by checking for the presence of a _MASReceipt folder within the app's package contents.
    /// This method is based on the fact that apps downloaded from the Mac App Store contain a receipt file in a folder named _MASReceipt within their package contents.
    /// This receipt serves as proof of purchase and is used by the system to validate the app.
    var isAppStore: Bool {
        guard let receiptURL = self.appStoreReceiptURL else {
            return false
        }
        return FileManager.default.fileExists(atPath: receiptURL.path)
    }

    /// Returns whether the bundle was signed for TestFlight beta distribution by checking
    /// the existence of a specific extension (marker OID) on the code signing certificate.
    ///
    /// This routine is inspired by the source code from ProcInfo, the underlying library
    /// of the WhatsYourSign code signature checking tool developed by Objective-See. Initially,
    /// it checked the common name but was changed to an extension check to make it more
    /// future-proof.
    ///
    /// For more information, see the following references:
    /// - https://github.com/objective-see/ProcInfo/blob/master/procInfo/Signing.m#L184-L247
    /// - https://gist.github.com/lukaskubanek/cbfcab29c0c93e0e9e0a16ab09586996#gistcomment-3993808
    var isTestFlight: Bool {
        var status = noErr

        var code: SecStaticCode?
        status = SecStaticCodeCreateWithPath(bundleURL as CFURL, [], &code)

        guard status == noErr, let code = code else { return false }

        var requirement: SecRequirement?
        status = SecRequirementCreateWithString(
            "anchor apple generic and certificate leaf[field.1.2.840.113635.100.6.1.25.1]" as CFString,
            [], // default
            &requirement
        )

        guard status == noErr, let requirement = requirement else { return false }

        status = SecStaticCodeCheckValidity(
            code,
            [], // default
            requirement
        )

        return status == errSecSuccess
    }
}
