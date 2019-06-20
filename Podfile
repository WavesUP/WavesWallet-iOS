source 'https://github.com/wavesplatform/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

install! 'cocoapods', :disable_input_output_paths => true

use_frameworks!(true)

# Enable the stricter search paths and module map generation for all pods
# use_modular_headers!

# Pods for MonkeyTest
target 'MonkeyTest' do
    pod 'SwiftMonkey'
end 

# Pods for WavesWallet-iOS
target 'WavesWallet-iOS' do

    inherit! :search_paths

    # UI
    pod 'RxCocoa'
    
    pod 'TTTAttributedLabel'    
    pod 'UITextView+Placeholder'

    pod 'SwipeView'
    pod 'MGSwipeTableCell'

    pod 'UPCarouselFlowLayout'
    pod 'InfiniteCollectionView', :git => 'https://github.com/wavesplatform/InfiniteCollectionView.git', :branch => 'swift5'
    pod 'RESideMenu', :git => 'https://github.com/wavesplatform/RESideMenu.git'

    pod 'Skeleton'
    pod 'Charts'
    pod 'Koloda'

    pod 'IQKeyboardManagerSwift'
    pod 'TPKeyboardAvoiding'
    
    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'
    pod 'RxGesture'
    pod 'RxFeedback'
    # pod 'RxReachability'

    pod 'IdentityImg'
    pod 'QRCode'
    pod 'QRCodeReader.swift', '~> 9.0.1'    
    pod 'SwiftDate'
    pod 'Kingfisher'

    # Waves
    pod 'WavesSDKExtension', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'
    pod 'WavesSDK', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'    
    pod 'WavesSDKCrypto', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'

    # Waves Internal
    pod 'DomainLayer', :path => '.'
    pod 'DataLayer', :path => '.'
    pod 'Extensions', :path => '.'
    

    # pod 'KeychainAccess'
    # pod 'DeviceKit', '~> 1.3'

    # Code Gen
    pod 'SwiftGen', '~> 5.3.0'

    # Debug
    # pod 'Reveal-SDK', :configurations => ['Debug']
    pod 'AppSpectorSDK', :configurations => ['Debug', 'Test']
    pod 'SwiftMonkeyPaws', :configurations => ['Debug']
    

    pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git'
    pod 'Fabric'
    pod 'Crashlytics'

    pod 'Amplitude-iOS'
    pod 'AppsFlyerFramework'
end

target 'InternalDomainLayer' do

    inherit! :search_paths

    # DB
    pod 'RealmSwift'
    pod 'RxRealm'

    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'        
    pod 'RxReachability'

    pod 'KeychainAccess'    
    pod 'DeviceKit', '~> 1.3'

    # Waves
    pod 'WavesSDKExtension', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'
    pod 'WavesSDK', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'    
    pod 'WavesSDKCrypto', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'

end

target 'InternalExtensions' do

    inherit! :search_paths

    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'
    pod 'DeviceKit'

    # Waves
    pod 'WavesSDKExtension', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'
    pod 'WavesSDK', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'    
    pod 'WavesSDKCrypto', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'

end

target 'InternalDataLayer' do

    inherit! :search_paths

    # External Service
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'Firebase/InAppMessagingDisplay'

    # DB
    pod 'RealmSwift'
    pod 'RxRealm'

    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'
    pod 'CSV.swift'

    # Waves
    pod 'WavesSDKExtension', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'
    pod 'WavesSDK', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'    
    pod 'WavesSDKCrypto', :path => '/Users/rprokofev/Works/Waves/Vendors/WavesSDK-iOS'

end

post_install do |installer|

    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|

            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"

            config.build_settings['SWIFT_VERSION'] = '4.2'
            
        end        
    end
end
