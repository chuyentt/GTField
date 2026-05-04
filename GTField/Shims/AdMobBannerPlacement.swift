//
//  AdMobBannerPlacement.swift
//  GTField
//
//  Centralised Auto Layout placement for `GADBannerView` so that every screen
//  hosts the AdMob banner consistently:
//    • horizontally centred (banners have fixed widths 320 / 468pt while the
//      device may be 390 / 414 / 430 / 768pt — anchoring to x=0 leaves a gap),
//    • pinned to the safe-area bottom (so the home-indicator never overlaps it),
//    • hidden by default; revealed only when an ad is actually received.
//
//  Replaces the legacy frame-based / `UIView.beginAnimations` show/hide logic
//  that was duplicated across MainViewController, MapViewController,
//  MapPoiViewController, PoiDetailViewController, SectionsViewController,
//  GPXFilesTableViewController and GWFViewController.
//

import UIKit

import GoogleMobileAds
extension UIViewController {

    /// Adds the banner to `self.view` (if not already) and pins it with Auto
    /// Layout to the bottom safe-area, horizontally centred. Width / height are
    /// derived from the banner's intrinsic size (set by `GADAdSize`).
    /// The banner starts hidden — call `setAdBannerVisible(_:)` to reveal it
    /// in the `adViewDidReceiveAd` delegate callback.
    func installAdMobBanner(_ banner: GADBannerView) {
        // Defensive: if the user has Pro / Unlimited, never even attach the banner.
        // (Each VC also gates with `ADS_ENABLED && !getProVersion()`, this is a
        // belt-and-braces check in case a screen forgets the gate or the user
        // upgrades to Pro after the VC is already on screen.)
        if getProVersion() || getUnlimited() {
            banner.removeFromSuperview()
            return
        }

        banner.translatesAutoresizingMaskIntoConstraints = false
        if banner.superview !== self.view {
            banner.removeFromSuperview()
            self.view.addSubview(banner)
        }
        banner.isHidden = true
        banner.alpha = 0

        // The banner's frame size was set by `GADBannerView(adSize:)`.
        let bannerSize = banner.frame.size
        let host = self.view!

        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: host.centerXAnchor),
            banner.bottomAnchor.constraint(equalTo: host.safeAreaLayoutGuide.bottomAnchor),
            banner.widthAnchor.constraint(equalToConstant: bannerSize.width),
            banner.heightAnchor.constraint(equalToConstant: bannerSize.height),
        ])

        // Make sure the banner floats above sibling subviews (maps, table views…).
        self.view.bringSubviewToFront(banner)
    }
}

extension UIView {

    /// Animated show/hide for an ad banner that was placed via
    /// `installAdMobBanner(_:)`. Uses alpha so the layout doesn't jump.
    func setAdBannerVisible(_ visible: Bool, animated: Bool = true) {
        if visible { self.isHidden = false }
        let work = { self.alpha = visible ? 1 : 0 }
        let done: (Bool) -> Void = { _ in if !visible { self.isHidden = true } }
        if animated {
            UIView.animate(withDuration: 0.25, animations: work, completion: done)
        } else {
            work(); done(true)
        }
    }
}
