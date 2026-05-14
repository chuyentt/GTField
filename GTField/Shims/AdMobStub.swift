//
//  AdMobStub.swift
//  GTField
//
//  Stub cho các API AdMob đã bị Google xoá khỏi Google-Mobile-Ads-SDK v8.0+.
//  - GADInterstitial → đã migrate sang InterstitialHelper.swift (GADInterstitialAd async)
//  - kGADSimulatorID → đã xoá; simulators tự động ở test mode, không cần set
//
//  Banner thật (GADBannerView, GADRequest, GADBannerViewDelegate, GADAdSizeBanner)
//  đến từ pod Google-Mobile-Ads-SDK 10.x — KHÔNG stub ở đây.
//

import UIKit
import GoogleMobileAds
// Không còn stub nào cần thiết sau khi migrate sang GADInterstitialAd + GADRewardedAd.
