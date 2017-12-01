# Lưu ý: Sau mỗi lần pod update thì phải Pods > Development Pods > Click chuột phải vào GeoTrans
# chọn Add Files to "Pods..." chọn geotrans37 > CCS > src [Add]
# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
target 'GTField' do
  # Pods for GTField
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'GooglePlacePicker'
  #pod 'Google-Maps-iOS-Utils'
  #pod 'Zip'
  pod 'Firebase'
  pod 'Firebase/AdMob'
  #pod 'SwiftyStoreKit'
  pod 'Surge', '~> 2.0.0'
  
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'GeoTrans', :path => 'GeoTrans'
end

pre_install do |installer|
    def installer.verify_no_static_framework_transitive_dependencies; end
end

post_install do |installer|
    copy_pods_resources_path = "Pods/Target Support Files/Pods-GTField/Pods-GTField-resources.sh"
    string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
    assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
    text = File.read(copy_pods_resources_path)
    new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
    File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
end

