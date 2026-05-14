//
//  InterstitialHelper.swift
//  GTField
//
//  Helper dùng chung cho GADInterstitialAd (GMA SDK 8+ async API) và GADRewardedAd.
//  Thay thế hoàn toàn class GADInterstitial cũ (đã bị Google xoá từ SDK v8.0).
//
//  Cách dùng trong VC:
//    // Khai báo
//    private let interstitialHelper = InterstitialHelper()
//    private let rewardedHelper     = RewardedAdHelper()
//
//    // Preload (ví dụ trong viewDidLoad hoặc initAdMobBanner)
//    interstitialHelper.load()
//    rewardedHelper.load()
//
//    // Show khi cần
//    interstitialHelper.show(from: self)
//    rewardedHelper.show(from: self) { didEarnReward in
//        if didEarnReward { /* mở khoá tính năng */ }
//    }
//

import UIKit
import GoogleMobileAds

// MARK: - InterstitialHelper

/// Wrapper cho GADInterstitialAd với auto-reload sau khi ad được đóng.
final class InterstitialHelper: NSObject {

    private var interstitialAd: GADInterstitialAd?
    private var isLoading = false

    /// Preload một interstitial ad.
    func load() {
        guard ADS_ENABLED, !getProVersion(), !isLoading else { return }
        isLoading = true
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: ADMOB_UNIT_ID_Interstitial,
                               request: request) { [weak self] ad, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                print("⚠️ Interstitial failed to load: \(error.localizedDescription)")
                return
            }
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }

    /// Hiển thị interstitial nếu đã sẵn sàng. Nếu chưa có, tự reload để lần sau dùng.
    func show(from viewController: UIViewController) {
        guard ADS_ENABLED, !getProVersion(), !getUnlimited() else { return }
        if let ad = interstitialAd {
            ad.present(fromRootViewController: viewController)
        } else {
            load() // ad chưa sẵn → preload cho lần kế
        }
    }
}

extension InterstitialHelper: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        interstitialAd = nil
        load() // auto-reload ngay sau khi đóng
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        interstitialAd = nil
        load()
    }
}

// MARK: - RewardedAdHelper

/// Wrapper cho GADRewardedAd — hiển thị "Xem quảng cáo để mở khoá tính năng".
final class RewardedAdHelper: NSObject {

    private var rewardedAd: GADRewardedAd?
    private var isLoading = false
    private var rewardCallback: ((Bool) -> Void)?

    /// Preload một rewarded ad.
    func load() {
        guard ADS_ENABLED, !isLoading else { return }
        isLoading = true
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: ADMOB_UNIT_ID_Rewarded,
                           request: request) { [weak self] ad, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                print("⚠️ Rewarded Ad failed to load: \(error.localizedDescription)")
                return
            }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    /// Hiển thị rewarded ad. `completion(true)` nếu user đã xem đủ và kiếm được phần thưởng.
    func show(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard ADS_ENABLED else {
            // Ads tắt → cấp phần thưởng luôn (không chặn tính năng khi ads bị tắt toàn cục)
            completion(true)
            return
        }
        guard let ad = rewardedAd else {
            // Ad chưa load → thông báo user và preload cho lần sau
            completion(false)
            load()
            let alert = UIAlertController(
                title: NSLocalizedString("Ad not ready", comment: ""),
                message: NSLocalizedString("Please try again in a moment.", comment: ""),
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel))
            alert.show()
            return
        }
        rewardCallback = completion
        ad.present(fromRootViewController: viewController) { [weak self] in
            // Callback này chạy khi user đã xem đủ để nhận reward.
            self?.rewardCallback?(true)
            self?.rewardCallback = nil
        }
    }
}

extension RewardedAdHelper: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // Nếu user tắt quảng cáo trước khi nhận reward, callback = false
        rewardCallback?(false)
        rewardCallback = nil
        rewardedAd = nil
        load() // auto-reload
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        rewardCallback?(false)
        rewardCallback = nil
        rewardedAd = nil
        load()
    }
}
