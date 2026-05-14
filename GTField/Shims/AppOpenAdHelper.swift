//
//  AppOpenAdHelper.swift
//  GTField
//
//  Quản lý App Open Ad (GADAppOpenAd) theo pattern chuẩn của Google:
//  - Load khi app khởi động (applicationDidBecomeActive lần đầu)
//  - Hiện khi app foreground lại sau ≥ 4 giờ ở background (tránh spam)
//  - Không hiện nếu: user là Pro/Unlimited, ADS_ENABLED = false,
//    đang có màn hình khác present, hoặc ad còn mới hơn 4 giờ
//  - Tự reload sau khi đóng

import UIKit
import GoogleMobileAds

class AppOpenAdHelper: NSObject {

    static let shared = AppOpenAdHelper()

    private var appOpenAd: GADAppOpenAd?
    private var isLoadingAd = false
    private var isShowingAd = false
    private var loadTime: Date?

    /// Thời gian tối thiểu giữa 2 lần hiện App Open Ad (giây). Mặc định 4 giờ.
    private let minIntervalSeconds: TimeInterval = 4 * 3600

    private override init() { super.init() }

    // MARK: - Load

    func loadAd() {
        guard !isLoadingAd, !isAdAvailable() else { return }
        guard ADS_ENABLED, !getProVersion(), !getUnlimited() else { return }

        isLoadingAd = true
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: ADMOB_UNIT_ID_AppOpen,
                          request: request) { [weak self] ad, error in
            guard let self else { return }
            self.isLoadingAd = false
            if let error = error {
                print("[AppOpenAd] Load failed: \(error.localizedDescription)")
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.loadTime = Date()
            print("[AppOpenAd] Loaded successfully.")
        }
    }

    // MARK: - Show

    /// Gọi từ applicationDidBecomeActive. Tự kiểm tra điều kiện trước khi hiện.
    func showAdIfAvailable() {
        guard !isShowingAd else { return }
        guard ADS_ENABLED, !getProVersion(), !getUnlimited() else { return }

        guard isAdAvailable() else {
            loadAd()   // reload nếu hết hạn hoặc chưa có
            return
        }

        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else { return }

        // Không hiện nếu đang present modal nào đó
        if rootVC.presentedViewController != nil { return }

        isShowingAd = true
        appOpenAd?.present(fromRootViewController: rootVC)
    }

    // MARK: - Private

    private func isAdAvailable() -> Bool {
        guard appOpenAd != nil, let loadTime else { return false }
        return Date().timeIntervalSince(loadTime) < minIntervalSeconds
    }
}

// MARK: - GADFullScreenContentDelegate

extension AppOpenAdHelper: GADFullScreenContentDelegate {

    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("[AppOpenAd] Impression recorded.")
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        isShowingAd = true
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        isShowingAd = false
        appOpenAd = nil
        loadAd()   // pre-load cho lần tiếp theo
    }

    func ad(_ ad: GADFullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        appOpenAd = nil
        print("[AppOpenAd] Failed to present: \(error.localizedDescription)")
        loadAd()
    }
}
