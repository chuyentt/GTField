# App Privacy — GTField (App Store Connect)

This is the Admin-only step blocking submission:

> Before you can submit this app for review, an Admin must provide
> information about the app's privacy practices in the App Privacy section.

Path in App Store Connect:

    My Apps → GTField → App Privacy → "Get Started" (or "Edit")

Below is the exact answer set for GTField 1.4.12 (build 69), derived from
the actual code/SDKs shipped:

- Firebase Analytics (GoogleAppMeasurement)            → Analytics, Diagnostics
- Google Mobile Ads (AdMob 10.x) + UMP                 → 3rd-party advertising
- Google Maps SDK / Google Places SDK                  → Maps & nearby search
- Core Location (When-In-Use + Always/Background)      → Map + tracking
- Camera, Photo Library                                → Photo capture/import
- GeoServer `Settings.xml` fetched via URLSession      → User-supplied URL only
- No app account, no login, no in-app purchases, no chat/UGC, no contacts.
- No Facebook SDK is linked (only a legacy URL scheme remains).

---

## 1. Privacy Policy URL (required)

    https://gtfield.rbc.vn/privacy

(Confirm this page exists and lists the items below before submitting.)

## 2. Data Collection

Answer **"Yes, we collect data from this app."**

### Data Types — check ONLY these boxes:

#### Location
- [x] **Precise Location**
  - Linked to the user: **No**
  - Used for tracking: **No**
  - Purposes: **App Functionality** (show user on map, nearby search,
    landmark/track creation, background tracking when user starts a track).

#### Contact Info / Health / Financial / Contacts / User Content
- (none)

#### Identifiers
- [x] **Device ID**
  - Linked to the user: **No**
  - Used for tracking: **Yes** (Google AdMob / UMP may use IDFA when the
    user grants ATT permission; otherwise non-personalized ads only).
  - Purposes: **Third-Party Advertising**, **Analytics**.

#### Usage Data
- [x] **Product Interaction**
  - Linked to the user: **No**
  - Used for tracking: **No**
  - Purposes: **Analytics** (Firebase Analytics — screen views, events).
- [x] **Advertising Data**
  - Linked to the user: **No**
  - Used for tracking: **Yes**
  - Purposes: **Third-Party Advertising** (AdMob banner impressions/clicks).

#### Diagnostics
- [x] **Crash Data**
  - Linked: **No**, Tracking: **No**, Purposes: **App Functionality**, **Analytics**.
- [x] **Performance Data**
  - Linked: **No**, Tracking: **No**, Purposes: **Analytics**.
- [x] **Other Diagnostic Data**
  - Linked: **No**, Tracking: **No**, Purposes: **Analytics**.
  (All three come from Firebase Analytics / Google Mobile Ads SDK.)

### NOT collected (leave unchecked)

Name, Email, Phone Number, Physical Address, Other Contact Info,
Health & Fitness, Financial Info, Sensitive Info, Contacts,
Emails or Text Messages, Photos or Videos, Audio Data, Gameplay Content,
Customer Support, Other User Content, Browsing History, Search History,
Purchases, Credit Info, User ID, Account, Payment Info,
Coarse Location (we use Precise only).

> Photos taken with the camera and imported from the photo library are
> stored **on-device only** and are never transmitted off-device by
> GTField. Therefore "Photos or Videos" is **not** collected.

## 3. Tracking summary

- The app itself does not track users across other companies' apps/sites.
- AdMob may track if the user grants ATT (`NSUserTrackingUsageDescription`
  is already in Info.plist, presented by Google's UMP/AdMob 10.x SDK).
- Therefore "Used for tracking" must be set on **Device ID** and
  **Advertising Data** only, as marked above.

## 4. After saving

1. Click **Publish** in the App Privacy panel.
2. Re-open the version page — the red "Admin must provide…" banner
   disappears and the **Submit for Review** button becomes enabled.

## 5. Side fix to do later (not blocking)

- Remove the unused `FacebookAppID` / `fb328913314185622` URL scheme from
  `GTField/Info.plist` since no Facebook SDK is actually linked. Apple may
  flag it during review otherwise.
