# Pre-Release Audit — GTField (next build sau 1.4.11/68)

> Phương pháp: **RIPR** (Reachability → Infection → Propagation → Revealability) cho mỗi điểm rủi ro;
> **EP** (Equivalence Partitioning), **BVA** (Boundary Value Analysis), **MDTD** (Multi-Dimension Test Domain),
> **Graph Coverage** (state graph & control flow) cho test plan.

---

## 1. Các fix đã thực hiện trong đợt audit này

| # | File | Fix | RIPR justification |
|---|---|---|---|
| 1 | `Settings.swift` | `getSettings()` chuyển sang `URLSession.shared.dataTask` (background) | R: mọi launch đều gọi. I: block main thread. P: launch screen treo. **Re: rõ rệt.** |
| 2 | `Info.plist` | Xoá `HELP_VI_URL = HeitiTC-Light.ttf` khỏi `UIAppFonts` | R: mỗi launch. I: parser fail, log spam. P: tăng nhẹ thời gian khởi động. Re: warning log. |
| 3 | `Global.swift` | `UIAlertController.show()` viết lại — dùng `topMostPresented()` thay vì UIWindow phụ | R: mọi alert. I: window bị release. P: alert biến mất. **Re: cao** (đã user-reported). |
| 4 | 18 file | Thay 18 chỗ inline UIWindow bằng `<alert>.show()` | Đồng bộ với #3. |
| 5 | `MapViewController.swift` (4 chỗ) | `UIApplication.shared.keyWindow?.rootViewController?.present` → `.show()` | iOS 13+ multi-scene: keyWindow có thể nil. |
| 6 | `GeoJSONKit.swift` | Như #5. | |
| 7 | `RulerBarView.swift` | `showCrossMarker()` set tường minh `crossLine.isHidden`; `showCrossMarker(_:)` lazy install RulerBarView | Chữ thập không hiện khi thêm mốc nếu user tắt Ruler Bar / Map Center Coordinate. |
| 8 | `RulerBarView.swift` | `UIApplication.shared.statusBarFrame.height` → `window.safeAreaInsets.top` | iOS 13+ deprecated; sai trên iPhone Dynamic Island. |
| 9 | `MapViewController.swift` | `NSKeyedArchiver.archivedData(withRootObject:)` → `requiringSecureCoding: false` overload | iOS 12+ deprecated; sẽ bị remove. |
| 10 | `AppDelegate.swift` | 3 `try!` (mở GPX) → `try?` + alert; `removeItem` → `try?` | Mở file GPX bất kỳ → crash app nếu bad XML. |
| 11 | `PhotoAnnotation.swift` | `try! Data(contentsOf:)` → `guard let try?` | Thumbnail crash khi file bị xoá. |
| 12 | `PhotoMapViewController.swift` | `try! Data(contentsOf:)` + 3 force-unwrap → `guard let` | Đọc EXIF crash khi photo URL invalid. |
| 13 | `GPXFilesTableViewController.swift` (2 chỗ) | `try! AEXMLDocument` → `try?` + early return | Crash khi parse GPX hỏng. |
| 14 | `GPXTableViewController.swift` | `try! AEXMLDocument` → `try?` + return cell | Crash khi vẽ row có GPX hỏng. |
| 15 | `GSLayersViewController.swift` (2 chỗ) | `try! JSONSerialization.jsonObject(...)!` → `guard let` | Crash khi GeoServer trả response không chuẩn. |
| 16 | `MainViewController.swift` + 11 VC | Đồng bộ `if ADS_ENABLED && !getProVersion()` | User Pro vẫn thấy ads ở nhiều màn. |
| 17 | `Shims/AdMobBannerPlacement.swift` | Helper Auto Layout banner pin safe-area bottom | Banner bị home-indicator che, lệch trái trên Plus/Max → vi phạm policy AdMob. |
| 18 | `Podfile` + 12 VCs + `Info.plist` + `AppDelegate` | **Khôi phục Google Mobile Ads SDK 10.14 thật** (banner real, interstitial vẫn stub). Migrate API: `kGADAdSize*` → `GADAdSize*`, `adViewDidReceiveAd` → `bannerViewDidReceiveAd`, `GADRequestError` → `Error`, `request.testDevices` → `requestConfiguration.testDeviceIdentifiers`. Thêm `GADApplicationIdentifier=ca-app-pub-9906627814658770~4067421272` + 39 entries `SKAdNetworkItems` + `NSUserTrackingUsageDescription` vào Info.plist. Pin `Firebase ~> 10.29` để tương thích `GoogleAppMeasurement < 11`. | Banner ads thật bắt đầu được phục vụ thay vì stub im lặng. |
| 19 | `GTField.xcodeproj/project.pbxproj` | Bump `MARKETING_VERSION 1.4.11 → 1.4.12`, `CURRENT_PROJECT_VERSION 68 → 69` (Debug + Release). | Yêu cầu của App Store Connect: build mới phải có version > version đã upload. |

---

## 2. Điểm khả nghi CÒN LẠI (sắp theo RIPR-risk)

### 🔴 Cao — nên fix trước release

> **Trạng thái: ĐÃ FIX HẾT (2026-05-04)**. Build pass.

| # | Điểm | Đã fix |
|---|---|---|
| 1 | `Utilities.swift:252` `getImagePropertyExifUserComment` 4 force-unwrap | ✅ guard let try? + fallback `""` |
| 2 | `MapViews/TileDownloader.swift:45,49` 3 force-unwrap URL | ✅ guard let baseURLString/urlComponents/tileURL → set state .failed |
| 3 | `Spring/Misc.swift:55` `imageFromURL` 3 force-unwrap | ✅ guard let url/data/image → return UIImage() |
| 4 | `Subscription/SubscriptionService.swift:115` | ⚪ False alarm — đã có do/catch |
| 5 | `MapViewController.swift:4464-4475` `myLocation!`, `coordinate!`, `location!` | ✅ guard let location + if let info |
| 6 | `MapViewController.swift:4452` `keyWindow.present` (sót lần trước) | ✅ chuyển sang `.show()` |
| 7 | `GPXFilesTableViewController.swift:458-498` 9 `try! dxf.write(...)` + `try! CSVWriter` | ✅ wrap toàn block trong do/catch + alert "Export DXF failed" |
| 8 | `Settings/SelectingTableViewController.swift:112` `Bundle.main.url(...)!` | ✅ guard let url + return rỗng |
| 9 | `UIImageView+Extensions.swift:123` `try! data?.write(...)` | ✅ `try?` |
| 10 | `KeyboardLayoutConstraint.swift:63,92` `UIApplication.shared.keyWindow` | ✅ helper `activeKeyWindow()` dùng `connectedScenes` foreground active |

### 🟠 Trung bình — nên fix nhưng không block release

- **Deprecation warnings** (đã thấy trong build output):
  - `UIView.beginAnimations / commitAnimations` (DataViewController.swift:287/290/297/302) — chuyển sang `UIView.animate(withDuration:)`.
  - `class` keyword in protocols → `AnyObject` (5 file).
  - `simd.double3` → `SIMD3<Double>` (Global.swift, GraphSegment.swift).
  - `UIActivityIndicatorView.Style.whiteLarge` → `.large` + `.color = .white`.
  - `UIMenuController.setTargetRect/setMenuVisible` → `showMenu(from:rect:)`.
  - `UIApplication.isNetworkActivityIndicatorVisible` → bỏ (Apple đã loại spinner status bar từ iOS 13).
- `MainViewController.handleActive` chỉ remove banner trên `MainViewController`. Các VC khác sau khi user mua Pro **trong khi đang dùng** vẫn hiển thị banner cho tới khi viewWillAppear chạy lại. Helper guard tại `installAdMobBanner` đã giảm rủi ro nhưng banner đang sống vẫn còn.

### 🟢 Thấp — informational

- `print(...)` debug logging vẫn còn nhiều ở MapViewController, AppDelegate. Cân nhắc bọc `#if DEBUG`.
- Nhiều `as! NSDictionary`, `as! Double`, `as! [String: AnyObject]` rải rác — bug tiềm ẩn nhưng chỉ trigger khi GeoServer/Photos trả schema khác.

---

## 3. Test plan (bắt buộc trước khi nâng version)

### 3.1. Equivalence Partitioning (EP)

| Đầu vào | Phân lớp tương đương | Test cases tối thiểu |
|---|---|---|
| Toạ độ nhập tay (lat) | `[-90, -1)`, `[-1, 0)`, `[0, 1)`, `[1, 90]`, `<-90`, `>90`, NaN | 7 |
| Toạ độ nhập tay (lng) | `[-180, 0)`, `[0, 180]`, `<-180`, `>180`, NaN | 5 |
| File GPX upload | Hợp lệ có metadata, hợp lệ thiếu metadata, XML hỏng, rỗng (0 byte), không phải XML | 5 |
| File MBTiles | format `png`/`jpg`/`webp`/missing | 4 |
| settings.xml từ server | Hợp lệ đầy đủ, thiếu `<ads>`, thiếu `<server>`, malformed XML, 404, timeout | 6 |
| Photo source | JPEG có GPS, JPEG không GPS, HEIC, PNG, file đã xoá | 5 |

### 3.2. Boundary Value Analysis (BVA)

- **Coordinate**: 90.0, 89.999999, -90.0, 0.0, 180.0, -180.0, 179.999999.
- **Zoom level**: 0, 1, 20, 21 (GoogleMaps max).
- **GPS accuracy (hdop)**: `0`, `0.5`, `5`, `50`, `100`, `< 0` (invalid).
- **File size**: 0 bytes, 1 byte, 1MB, 100MB GPX (track lớn).
- **Photo count trong PhotoMap**: 0, 1, 100, 1000, 10000.
- **Pro version state transitions**: `(free) → buy Yearly → (pro)`, `(pro) → expire → (free)`, `(free) → buy Unlimited → (unlimited)`, restore.
- **App state**: cold launch, background → foreground, `applicationWillTerminate`.

### 3.3. MDTD (Multi-Dimension Test Domain)

| D1 Device | D2 Network | D3 Locale | D4 Mode | Min combinations |
|---|---|---|---|---|
| iPhone SE (small) / iPhone 17 Pro Max (Dynamic Island) / iPad | WiFi / 4G / Offline | vi / en / zh-Hans / zh-Hant | Light / Dark | Cover ≥ 1 cell mỗi axis: pairwise (≈ 9 cases) |

Các case must-pass: **iPhone Pro Max + Offline + zh-Hant + Dark** (locale RTL/CJK + UI lệch + map cache).

### 3.4. Graph Coverage — state machine

**State graph chính: Map View**

```
   Init ──► Locating ──► Tracking ──► Paused ──┐
     ▲           │            │            │   │
     │           ▼            ▼            ▼   │
     └──── PermDenied ◄── Background ──► Foreground
```

Edges cần test (Edge Coverage):
1. Init → Locating (cold start, đã grant permission)
2. Init → PermDenied (user deny ở alert)
3. Locating → Tracking (bấm Record)
4. Tracking → Paused (bấm Pause)
5. Tracking → Background → Foreground (lock screen 2 phút, mở lại — kiểm tra GPS không mất)
6. Tracking → applicationWillTerminate (force-quit khi đang ghi: kiểm tra archived locations đã save)
7. PermDenied → Settings.app → Foreground (user thay đổi permission, app phải re-prompt)

**State graph: AdMob banner**

```
ADS_ENABLED ─AND─ !getProVersion ─► [installBanner]
       │                                 │
       │                                 └── upgrade Pro ──► [removeFromSuperview]
       └── settings.xml ads_enabled=false ──► [hideBanner]
```

Edges:
1. (ads on, free) → banner hiện, pin safe-area bottom — **đo bằng screenshot trên iPhone Pro Max** (KHÔNG được đè Home Indicator).
2. (ads on, free) → user mua Pro → banner biến mất ngay (không cần đổi VC).
3. settings.xml flip `false` → next launch banner ẩn.
4. (ads off, free) → KHÔNG bao giờ tạo banner.
5. SDK thật trả `didFailToReceiveAdWithError` → banner alpha = 0.

---

## 4. Apple App Store / AdMob compliance check

- [ ] **AdMob banner không đè Home Indicator** trên iPhone 14+ (Pro Max + Mini).
- [ ] **AdMob banner không đè map gestures** ở vùng dưới (test pinch/pan ngay trên banner).
- [ ] **Terms of Use link** — `https://gtfield.rbc.vn/terms-vi.html` trả 200 OK (không 404).
- [ ] **Privacy / Help links** — tất cả 7 URL trên `gtfield.rbc.vn` reachable.
- [ ] **`UISupportedInterfaceOrientations`** không khai `Portrait Upside Down` cho iPhone (hiện đúng).
- [ ] **`NSLocationAlwaysAndWhenInUseUsageDescription`** rõ ràng (đã có).
- [ ] **`ITSAppUsesNonExemptEncryption = false`** (đã có).
- [ ] **Bundle version 68** đã được archive trên App Store Connect → bản kế tiếp **build ≥ 69**.

---

## 5. Quy trình bump version

Khi tất cả mục § 3 và § 4 PASS:

1. Mở `GTField.xcodeproj/project.pbxproj`:
   - `MARKETING_VERSION = 1.4.12;` (cả Debug + Release)
   - `CURRENT_PROJECT_VERSION = 69;` (cả Debug + Release)
2. Chạy `pod install` (sẽ giữ entries Shims nhờ `scripts/inject_shims.py`).
3. `Product → Clean Build Folder (⇧⌘K)`.
4. `Product → Archive` (Generic iOS Device).
5. Trên Organizer, validate trước khi upload.
6. Upload → App Store Connect → ghi release notes:
   - "Hỗ trợ iPhone 14+ Dynamic Island (toolbar, banner)."
   - "Sửa lỗi hộp thoại bị che khi mở bản đồ."
   - "Sửa lỗi crash khi mở GPX/photo bị hỏng."
   - "Tăng tốc khởi động — settings.xml tải bất đồng bộ."
   - "Cập nhật website chính thức sang `gtfield.rbc.vn`."

---

## 6. Smoke test cuối cùng (≤ 10 phút)

| # | Action | Expect |
|---|---|---|
| 1 | Cold launch | Splash tắt < 2s, không log "synchronous URL loading" |
| 2 | Cấp quyền Location khi prompt | Map hiện vị trí ngay |
| 3 | Mở "Recent GeoJSON" alert | Hộp thoại OK/Cancel hiển thị đầy đủ, không bị map che |
| 4 | Bấm "Add marker from map" | Chữ thập tâm + highlight xoay hiện ra; bấm "Done" → marker được thêm |
| 5 | Share file GPX hợp lệ vào app | Alert "copied" hiện đầy đủ |
| 6 | Share file GPX hỏng | Alert "Invalid GPX" thay vì crash |
| 7 | Mở PhotoMap với 1000+ ảnh | Không crash, list scroll mượt |
| 8 | Bật "Subscribe" → mua thử IAP sandbox | Banner biến mất ngay sau khi success |
| 9 | Đổi máy → restore purchases | Pro state khôi phục |
| 10 | iPhone 17 Pro Max landscape | Banner pin đáy, không đè Home Indicator; ruler vẽ đúng cạnh trên dưới Dynamic Island |

---

_Generated 2026-05-04 by automated audit. Update khi có change material._
