#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint store_checker_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'store_checker_plus'
  s.version          = '0.0.1'
  s.summary          = 'Finds out whether the app was installed from the App Store, TestFlight or another source.'
  s.description      = <<-DESC
Flutter plugin that finds the origin of the currently installed app.
                       DESC
  s.homepage         = 'https://github.com/tologonkudaiberdiuulu/store_checker_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'store_checker_plus contributors'
  s.source           = { :path => '.' }
  s.source_files     = 'store_checker_plus/Sources/store_checker_plus/**/*.swift'
  s.resource_bundles = { 'store_checker_plus_privacy' => ['store_checker_plus/Sources/store_checker_plus/PrivacyInfo.xcprivacy'] }
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
