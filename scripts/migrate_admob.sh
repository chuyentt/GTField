#!/bin/bash
# Migrate AdMob legacy API → GMA SDK 10.x
set -e
cd /Users/chuyentrungtran/Development/src/GTField

VC_FILES=(
  "GTField/MapViews/GPXFilesTableViewController.swift"
  "GTField/MapPoiViewController.swift"
  "GTField/GeoServerDetailView/GWFViewController.swift"
  "GTField/ViewControllers/PhotoMap/PhotosViewController/DataViewController.swift"
  "GTField/MainViewController.swift"
  "GTField/PoiDetailViewController.swift"
  "GTField/SectionsViewController.swift"
  "GTField/ViewControllers/PhotoMap/PhotoMapViewController.swift"
  "GTField/ViewControllers/Camera/CameraViewController.swift"
  "GTField/ViewControllers/Settings/SettingsViewController.swift"
  "GTField/ViewControllers/Camera/CameraViewController1.swift"
  "GTField/MapViewController.swift"
)

# Step A: insert `import GoogleMobileAds` after `import UIKit` (only if missing)
for f in "${VC_FILES[@]}"; do
  if ! grep -q "^import GoogleMobileAds" "$f"; then
    perl -i -pe 's|^(import UIKit\s*)$|${1}\nimport GoogleMobileAds|' "$f"
  fi
done

# Step B: rename delegate methods (GMA 8+ rename)
for f in "${VC_FILES[@]}"; do
  perl -i -pe '
    s/func adViewDidReceiveAd\(_ view: GADBannerView\)/func bannerViewDidReceiveAd(_ bannerView: GADBannerView)/g;
    s/func adView\(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError\)/func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error)/g;
  ' "$f"
done

# Step C: remove deprecated `request.testDevices = [...]`
for f in "${VC_FILES[@]}"; do
  perl -i -ne 'print unless /^\s*request\.testDevices\s*=/' "$f"
done

echo "=== Verification ==="
echo "Files with old adViewDidReceiveAd: $(grep -l 'func adViewDidReceiveAd(' "${VC_FILES[@]}" 2>/dev/null | wc -l)"
echo "Files with old adView(_:didFailToReceiveAdWithError: GADRequestError): $(grep -l 'didFailToReceiveAdWithError error: GADRequestError' "${VC_FILES[@]}" 2>/dev/null | wc -l)"
echo "Files with request.testDevices: $(grep -l 'request.testDevices' "${VC_FILES[@]}" 2>/dev/null | wc -l)"
echo "Files with import GoogleMobileAds: $(grep -l '^import GoogleMobileAds' "${VC_FILES[@]}" | wc -l)"
echo "Total VC files: ${#VC_FILES[@]}"
