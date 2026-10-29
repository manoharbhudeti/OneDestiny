# CHANGELOG

## 2026-10-29

### Analysis
- Analyzed header layout structure in `lib/core/widgets/luxury_header.dart` and `lib/features/home/views/home_screen.dart`.
- Identified that `SafeArea` wrapping the home screen body introduced unwanted top padding (preventing the header from touching the top of the screen) and horizontal margin restrictions.
- Identified that background decoration (`GoldLineArtPainter`) positioned with `right: -20` caused potential canvas bleed without container clipping.
- Identified that fixed widths/heights and padding caused edge clipping and lack of responsive adaptation across mobile, tablet, and desktop viewports.

### Added
- Multi-viewport responsive test suite in `test/luxury_header_test.dart` verifying mobile (320x640), notch safe area (390x844), tablet (768x1024), and desktop (1440x900) layout rendering.
- Web-safe image handling using `kIsWeb` condition in `_buildHeaderAvatarImage`.

### Changed
- Configured `home_screen.dart` `SafeArea` to `top: false, left: false, right: false` allowing the header to span 100% viewport width and touch the top edge of the screen.
- Updated `home_screen.dart` scroll column to `CrossAxisAlignment.stretch` ensuring 100% full-width header expansion.
- Dynamically integrated `MediaQuery.paddingOf(context).top` into `LuxuryHeader`'s top padding so the background container touches the screen top while content safely avoids status bar / notch cutouts.
- Implemented responsive layout adapting horizontal padding, logo scale, greeting/location font sizes, and avatar dimensions across Mobile, Tablet, and Desktop resolutions.
- Added `maxWidth: 1400` content constraint centered within full-width background for desktop viewports.

### Fixed
- Fixed header cut-off and clipping at screen edges.
- Fixed unwanted top gap/spacing between header and screen top.
- Fixed header horizontal overflow and subpixel clipping via `Clip.antiAlias` on container and `Clip.hardEdge` on background stack.

### Refactored
- Enhanced `_buildHeaderStatCard` to accept responsive scaling parameters.
- Replaced hardcoded dimensions with dynamic, viewport-aware values.

### Files Modified
- lib/core/widgets/luxury_header.dart
- lib/features/home/views/home_screen.dart
- test/luxury_header_test.dart
- CHANGELOG.md

### Breaking Changes
- None

### Testing
- `flutter analyze`: 0 issues found.
- `flutter test test/widget_test.dart test/luxury_header_test.dart`: All 5 tests passed across mobile, tablet, and desktop screen sizes.

### Notes
- Full backward compatibility maintained for all `LuxuryHeader` props, callbacks, and dark/light themes.

---

## [V 24.8.26] - 2026-08-24 (Build 27)

### 🌟 1. Ratings & Reviews System
- **New Feature Screen:** [`lib/features/reviews/views/vendor_reviews_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/reviews/views/vendor_reviews_screen.dart)
- **Data Model:** [`lib/core/models/review_model.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/core/models/review_model.dart)
- **Highlights:**
  - Overall rating summary card (`4.9 / 5.0`), total verified review count, and 5⭐ to 1⭐ percentage breakdown bars.
  - Interactive Filter Chips (*All, 5 Stars, 4 Stars, With Photos*).
  - Review cards featuring customer avatars, verified booking badges, star ratings, review dates, review text, and horizontal customer photo thumbnails.
  - Interactive full-screen image lightbox viewer for customer upload photos.
  - Integration: Linked from [`vendor_detail_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/vendor_detail/views/vendor_detail_screen.dart) via rating pill and "Customer Reviews" summary section.

---

### 🔔 2. Notification Center Screen
- **New Feature Screen:** [`lib/features/notifications/views/notification_center_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/notifications/views/notification_center_screen.dart)
- **Data Model:** [`lib/core/models/notification_model.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/core/models/notification_model.dart)
- **Highlights:**
  - Full-screen notification inbox with category filter tabs (*All, Unread, Bookings, Messages*).
  - Header actions: "Mark all read" and real-time unread badge count indicators.
  - Category icon badges, relative timestamps (`10m ago`, `1h ago`), and swipe-to-dismiss functionality.
  - Integration: Connected to notification bell icon in [`luxury_header.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/core/widgets/luxury_header.dart).

---

### 🛡️ 3. Help & Policies Screen
- **New Feature Screen:** [`lib/features/help_policies/views/help_policies_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/help_policies/views/help_policies_screen.dart)
- **Data Model:** [`lib/core/models/help_policy_model.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/core/models/help_policy_model.dart)
- **Highlights:**
  - **FAQs & Support Tab:** 24/7 Concierge contact options and expandable FAQ accordions.
  - **Cancellation Policy Tab:** Vendor refund terms breakdown.
  - **Dispute Handling Tab:** Step-by-step resolution roadmap with a "File a Dispute Ticket" button.
  - **Terms & Privacy Tab:** Expandable policy sections covering Terms of Service and Privacy Data Protection.
  - Integration: Connected from [`profile_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/profile/views/profile_screen.dart) under **Preferences & Settings**.

---

### ℹ️ 4. About OneDestiny & Version Management
- **Navigation Path:** **Profile → Preferences & Settings → About OneDestiny**
- **New Feature Screen:** [`lib/features/profile/views/about_onedestiny_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/profile/views/about_onedestiny_screen.dart)
- **Single Source of Truth Config:** [`assets/config/app_version.json`](file:///d:/WORK/OneDestinyCustomerApp/assets/config/app_version.json)
- **Data Model & Service:** [`app_version_info.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/core/models/app_version_info.dart) & [`app_version_service.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/core/services/app_version_service.dart)
- **Highlights:**
  - Displays App Version (`V 24.8.26`), Build (`27`), Released on (`24 August 2026`), and Minimum Supported (`V 24.8.26`).
  - Dynamic "What's New" section listing release notes from JSON as bullet points.
  - Prepared for future Play Store force/optional update management.
  - Zero hardcoding in Dart UI code.

---

### 📞 5. Support & Contact Channel Integration
- **Package Added:** `url_launcher: ^6.3.0` in [`pubspec.yaml`](file:///d:/WORK/OneDestinyCustomerApp/pubspec.yaml)
- **Channels Configured:**
  - **Phone Call Support:** Dial `tel:6302594826` (`+91 63025 94826`)
  - **WhatsApp Live Chat:** Deep-link `https://wa.me/916302594826` (`63025 94826`)
  - **Email Support:** Mailto `mailto:onedestiny50@gmail.com` (`onedestiny50@gmail.com`)

---

### ⚠️ 6. Financial Disclaimer & Safety Policy Updates
- **Platform Role Disclaimer:** Clarified across [`mock_data.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/core/data/mock_data.dart) and [`help_policies_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/help_policies/views/help_policies_screen.dart) that OneDestiny is an intermediary bridge platform and does NOT handle funds or issue direct monetary refunds.
- **Upfront Payment Advisory:** Prominent alert banner advising customers **NOT to pay advance deposits upfront without direct vendor booking confirmation**.
- **Booking Request Safety Note:** Added payment safety reminderSnackBars in [`vendor_detail_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/vendor_detail/views/vendor_detail_screen.dart).

---

### 🎨 7. UI/UX & Architectural Constraints
- **Header & Footer Integrity:** [`luxury_header.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/core/widgets/luxury_header.dart) and [`main_navigation_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/main/views/main_navigation_screen.dart) 100% preserved in design and navigation behavior.
- **Theme Support:** Native Light & Dark theme support across all new screens.
- **Static Analysis:** Verified with `flutter analyze` (**0 issues found**).

---

### 🖼️ 8. Brand Logo, Developer Profiles & Clean-up
- **Updated Brand Logo Asset:** Replaced the previous dark logo with the new clean white/gold infinity emblem (`assets/images/one_destiny_logo.png` & `assets/images/one_destiny_logo_transparent.png`).
- **Developer Credits System:** Added structured developer profiles in [`assets/config/app_version.json`](file:///d:/WORK/OneDestinyCustomerApp/assets/config/app_version.json) featuring **Manohar & Datta**.
- **LinkedIn Hyperlink Integration:** Added direct LinkedIn profile launcher for **Manohar** (`https://www.linkedin.com/in/manoharbhudeti/`) in [`about_onedestiny_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/profile/views/about_onedestiny_screen.dart).
- **Splash Screen:** Updated to render the new white/gold infinity brand emblem.
- **Header Bar:** Updated to display the new white/gold brand logo in [`luxury_header.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/core/widgets/luxury_header.dart).
- **Profile Screen Clean-up:** Removed the redundant logo image and version footer from the bottom of [`profile_screen.dart`](file:///d:/WORK/OneDestinyCustomerApp/lib/features/profile/views/profile_screen.dart).
