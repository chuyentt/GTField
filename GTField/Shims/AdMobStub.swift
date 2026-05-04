//
//  AdMobStub.swift
//  GTField
//
//  Local no-op stub cho cac API AdMob da bi Google xoa khoi Google-Mobile-Ads-SDK
//  tu phien ban 8.0 (2021), nhung codebase 1.4.11/68 van con dung:
//  - GADInterstitial (xoa v8.0; thay bang GADInterstitialAd async)
//  - kGADSimulatorID (xoa v8.0; thay bang GADSimulatorID khong co chu k)
//
//  Banner that (GADBannerView, GADRequest, GADBannerViewDelegate, GADAdSizeBanner)
//  den tu pod Google-Mobile-Ads-SDK 10.x - KHONG duoc stub o day vi trung ten class.
//

import UIKit
import GoogleMobileAds

/// Alias cho hang so da doi ten trong GMA 8.0 (kGADSimulatorID -> GADSimulatorID).
public let kGADSimulatorID: String = GADSimulatorID

/// No-op stub thay cho GADInterstitial da bi xoa tu GMA 8.0.
/// TODO: migrate sang GADInterstitialAd.load(withAdUnitID:request:completionHandler:).
public final class GADInterstitial {
    public let adUnitID: String
    public weak var delegate: AnyObject?

    public init(adUnitID: String) {
        self.adUnitID = adUnitID
    }

    public var isReady: Bool { false }

    public func load(_ request: GADRequest) { /* no-op */ }

    public func present(fromRootViewController rootViewController: UIViewController) { /* no-op */ }
}
