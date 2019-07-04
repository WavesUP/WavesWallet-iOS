source 'https://github.com/wavesplatform/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

plugin 'cocoapods-binary'

# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

install! 'cocoapods', :disable_input_output_paths => true

# enable_bitcode_for_prebuilt_frameworks!

use_frameworks!(true)
all_binary!

def wavesSDKPod
    pod 'WavesSDKExtension', :git => 'https://github.com/wavesplatform/WavesSDK-iOS.git', :branch => 'develop', :binary => false
    pod 'WavesSDK', :git => 'https://github.com/wavesplatform/WavesSDK-iOS.git', :branch => 'develop', :binary => false
    pod 'WavesSDKCrypto', :git => 'https://github.com/wavesplatform/WavesSDK-iOS.git', :branch => 'develop', :binary => false
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

    pod 'IdentityImg'
    pod 'QRCode'
    pod 'QRCodeReader.swift', '~> 9.0.1'    
    pod 'SwiftDate'
    pod 'Kingfisher'

    
    # Waves Internal
    pod 'DomainLayer', :path => '.', :binary => false
    pod 'DataLayer', :path => '.', :binary => false
    pod 'Extensions', :path => '.', :binary => false

    # Waves
    wavesSDKPod

 
    # Code Gen
    pod 'SwiftGen', '~> 5.3.0'

    # Debug
    # pod 'Reveal-SDK', :configurations => ['Debug']
    pod 'AppSpectorSDK', :configurations => ['Debug', 'Test']
    pod 'SwiftMonkeyPaws', :configurations => ['Debug']
        
    # pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git'
end

# Pods for MonkeyTest
target 'MonkeyTest' do
    pod 'SwiftMonkey'
end 


target 'DomainLayerTests' do

    inherit! :search_paths
    pod 'DomainLayer', :path => '.', :binary => false    
end

target 'DataLayerTests' do

    inherit! :search_paths
    pod 'DataLayer', :path => '.', :binary => false
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

    # Waves    
    wavesSDKPod
    pod 'Extensions', :path => '.', :binary => false
end

target 'InternalExtensions' do

    inherit! :search_paths

    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'
    pod 'DeviceKit'

    # Waves
    wavesSDKPod

end

target 'InternalDataLayer' do

    inherit! :search_paths

    # External Service
    pod 'Firebase/Core'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'Firebase/InAppMessagingDisplay'

    pod 'Fabric'
    pod 'Crashlytics'
    pod 'Amplitude-iOS'
    pod 'AppsFlyerFramework'
    pod 'Sentry'

    # DB
    pod 'RealmSwift'
    pod 'RxRealm'

    # Assisstant
    pod 'RxSwift'
    pod 'RxSwiftExt'
    pod 'RxOptional'
    pod 'CSV.swift'

    # Waves
    wavesSDKPod
    pod 'Extensions', :path => '.', :binary => false   
    pod 'DataLayer', :path => '.', :binary => false   

end

post_install do |installer|

    installer.pods_project.targets.each do |target|
        
        target.build_configurations.each do |config|

            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"

            config.build_settings['SWIFT_VERSION'] = '4.2'
            
        end        
    end
end
