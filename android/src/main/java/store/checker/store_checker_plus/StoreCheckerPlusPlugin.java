package store.checker.store_checker_plus;

import android.content.Context;
import android.content.pm.InstallSourceInfo;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** StoreCheckerPlusPlugin finds the package that installed the current application. */
public class StoreCheckerPlusPlugin implements FlutterPlugin, MethodCallHandler {
  // MethodChannel is used to provide communication between Flutter and native Android
  private MethodChannel channel;
  private Context applicationContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    applicationContext = binding.getApplicationContext();
    channel = new MethodChannel(binding.getBinaryMessenger(), "store_checker_plus");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getSource")) {
      try {
        result.success(getInstallerPackageName());
      } catch (PackageManager.NameNotFoundException e) {
        result.error("PACKAGE_NOT_FOUND", e.getMessage(), null);
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    applicationContext = null;
  }

  /**
   * Returns the package name of the app that installed this application, or {@code null} when it
   * was installed without one (for example with {@code adb install}).
   */
  @Nullable
  private String getInstallerPackageName() throws PackageManager.NameNotFoundException {
    final PackageManager packageManager = applicationContext.getPackageManager();
    final String packageName = applicationContext.getPackageName();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      final InstallSourceInfo installSourceInfo = packageManager.getInstallSourceInfo(packageName);
      return installSourceInfo.getInstallingPackageName();
    }
    return getInstallerPackageNameBeforeApi30(packageManager, packageName);
  }

  /**
   * {@link PackageManager#getInstallerPackageName(String)} is deprecated since API 30 but is the
   * only option on older devices. It is only called when {@link PackageManager#getInstallSourceInfo}
   * is unavailable.
   */
  @SuppressWarnings("deprecation")
  @Nullable
  private static String getInstallerPackageNameBeforeApi30(
      @NonNull PackageManager packageManager, @NonNull String packageName) {
    return packageManager.getInstallerPackageName(packageName);
  }
}
