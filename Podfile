# Lưu ý: Sau mỗi lần pod update thì phải kéo thư mục src vào GeoTrans
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
target 'GTField' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'GeoTrans', :path => 'GeoTrans'

  # Pods for GTField
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'GooglePlacePicker'
  pod 'Zip'
  pod 'Firebase'
  pod 'Firebase/AdMob'
  pod 'SwiftyStoreKit'
  
end
post_install do |installer|
    copy_pods_resources_path = "Pods/Target Support Files/Pods-GTField/Pods-GTField-resources.sh"
    string_to_replace = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"'
    assets_compile_with_app_icon_arguments = '--compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${BUILD_DIR}/assetcatalog_generated_info.plist"'
    text = File.read(copy_pods_resources_path)
    new_contents = text.gsub(string_to_replace, assets_compile_with_app_icon_arguments)
    File.open(copy_pods_resources_path, "w") {|file| file.puts new_contents }
end
