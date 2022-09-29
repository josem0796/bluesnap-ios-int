Pod::Spec.new do |s|
  s.name         = "BluesnapSDK"
  s.version      = "1.5.0"
  s.summary      = "An iOS SDK for Bluesnap "
  s.description  = <<-DESC
  Integrate payment methods into your iOS native apps quickly and easily.
  Bluesnap iOS SDK supports credit card and apple pay, currency conversions and more.
                  DESC
  s.homepage     = "http://www.bluesnap.com"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = { "snpori" => "oribsnap@gmail.com" }
  s.platform = :ios
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.source       = { :git => "https://github.com/bluesnap/bluesnap-ios.git", :tag => "#{s.version}" }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0',
                            'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
                            'ONLY_ACTIVE_ARCH' => 'NO' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.resource_bundles = {
    'BluesnapUI' => [
        'BluesnapSDK/**/*.xib',
        'BluesnapSDK/**/*.storyboard',
        'BluesnapSDK/**/Media.xcassets',
        'BluesnapSDK/**/*.strings' 
	]
  }

  s.default_subspecs = %w[Core BSKDataCollector]


  #s.exclude_files =  ["Frameworks/FATFrameworks/CardinalMobile/**/", "BluesnapSDK/BluesnapSDKTests/**/*.*","BluesnapSDK/BluesnapSDKIntegrationTests/**/*.*","BluesnapSDK/**/libKountDataCollector.a","BluesnapSDK/**/KDataCollector.{h,m}" ]
  s.exclude_files =  ["Frameworks/XCFrameworks/KountDataCollector.xcframework/**" "Frameworks/FATFrameworks/CardinalMobile/**/", "BluesnapSDK/BluesnapSDKTests/**/*.*","BluesnapSDK/BluesnapSDKIntegrationTests/**/*.*", "BluesnapSDK/**/libKountDataCollector.a","BluesnapSDK/**/KDataCollector.{h,m}"]
  s.ios.vendored_frameworks = ['Frameworks/FATFrameworks/CardinalMobile.framework']

  s.resources = "BluesnapSDK/**/Media.xcassets"
  s.frameworks                     = 'Foundation', 'Security', 'WebKit', 'PassKit', 'AddressBook', 'UIKit' ,
  s.weak_frameworks                = 'Contacts'
  s.requires_arc = true

  
  s.subspec "BSKDataCollector" do |s|
      s.public_header_files = "BluesnapSDK/**/KDataCollector*.h","BluesnapSDK/**/KountAnalyticsViewController.h"
      s.vendored_frameworks = "Frameworks/XCFrameworks/KountDataCollector.xcframework"
  
  end


  s.subspec "Core" do |s|
    s.source_files  = "BluesnapSDK/**/*.{h,m}"
    s.public_header_files = "BluesnapSDK/BluesnapSDK.h"
    s.dependency "BluesnapSDK/BSKDataCollector"
  end

end
