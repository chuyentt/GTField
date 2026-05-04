# Lưu ý: Sau mỗi lần pod update thì phải Pods > Development Pods > Click chuột phải vào GeoTrans
# chọn Add Files to "Pods..." chọn geotrans37 > CCS > src [Add]
# GADBannerViewDelegate
# Các lỗi sau khi pod update:
# - Use of undeclared type 'GADBannerViewDelegate'
# - Use of undeclared type 'GADBannerView'
# Fix:
# Uncomment the next line to define a global platform for your project
use_frameworks!
platform :ios, '13.0'
target 'GTField' do
  # Pods for GTField
  pod 'GoogleMaps', '~> 7.4'
  pod 'GooglePlaces', '~> 7.4'
  # GooglePlacePicker: deprecated by Google + missing arm64-simulator slice -> stubbed locally in GTField/Shims/
  # pod 'GooglePlacePicker'
  #pod 'Google-Maps-iOS-Utils'
  #pod 'Zip'
  pod 'Firebase/Core', '~> 10.29'
  # Google-Mobile-Ads-SDK 10.x: keep GAD-prefixed banner API (GADBannerView, GADRequest, kGADAdSizeBanner)
  # so we don't have to mass-rename the whole project. Interstitial (removed by Google in v8) is still
  # served by the local stub in GTField/Shims/AdMobStub.swift (no-op).
  pod 'Google-Mobile-Ads-SDK', '~> 10.14'
  #pod 'SwiftyStoreKit'
  pod 'Surge', '~> 2.0.0'
  pod 'SwiftyPlistManager'
  
#  pod 'GeoTrans', :git => 'https://github.com/chuyentt/GeoTrans.git'
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
#  use_frameworks!
#  pod 'GeoTrans', :path => 'GeoTrans'
end

pre_install do |installer|
    def installer.verify_no_static_framework_transitive_dependencies; end
end

post_install do |installer|
    # Bump deployment target of all pods to iOS 12.0 (Xcode 14+ requirement, no libarclite for <11)
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
    end

    copy_pods_resources_path = "Pods/Target Support Files/Pods-GTField/Pods-GTField-resources.sh"
    string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
    assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
    text = File.read(copy_pods_resources_path)
    new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
    File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
end

