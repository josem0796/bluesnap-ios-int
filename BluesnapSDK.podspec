Pod::Spec.new do |s|
  s.name         = "LukaBluesnapSDK"
  s.version      = "0.0.2"
  s.summary      = "An iOS SDK from Luka for Bluesnap "
  s.description  = <<-DESC
  Integrate payment methods into your iOS native apps quickly and easily.
  Bluesnap iOS SDK supports credit card and apple pay, currency conversions and more.
                  DESC
  s.homepage     = "http://www.luka.io"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = { "jmoran@lukapay.io" }
  s.platform = :ios
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.7'
  s.source       = { :git => "https://github.com/josem0796/bluesnap-ios.git", :tag => "#{s.version}" }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.7',
                            'ONLY_ACTIVE_ARCH' => 'NO' }
  
  #s.resources =[ 'BluesnapSDK/**/Media.xcassets' ,  'BluesnapSDK/**/Assets.car']
  s.frameworks                     = 'Foundation', 'Security', 'WebKit', 'PassKit', 'AddressBook', 'UIKit' ,
  s.weak_frameworks                = 'Contacts'
  s.requires_arc = true

  s.source_files  = ["BluesnapSDK/**/*.swift",  "BluesnapSDK/Kount-Bridging-Header.h", "Frameworks/**/KDataCollector.h", "Frameworks/**/KountAnalyticsViewController.h"]
  s.public_header_files =  ["BluesnapSDK/Kount-Bridging-Header.h" , "Frameworks/**/KDataCollector.h", "Frameworks/**/KountAnalyticsViewController.h"]
  s.ios.vendored_frameworks = ['Frameworks/FATFrameworks/CardinalMobile.framework',"Frameworks/XCFrameworks/KountDataCollector.xcframework" ]
  s.resource_bundles = {
  'BluesnapUI' => [
         'BluesnapSDK/**/*.xib',
         'BluesnapSDK/**/*.storyboard',
         'BluesnapSDK/**/Media.xcassets',
         'BluesnapSDK/**/*.strings'

  ]}


end
