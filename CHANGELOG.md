# CHANGELOG

## 2026-11-04

### Analysis
- Analyzed existing UI architecture, state management (`AppStateScope` / `ChangeNotifier`), network client (`ApiService`), and authentication lifecycles.
- Identified need for a unified, production-grade UI states and visual feedback system supporting all 10 canonical states across both Customer and Vendor application architectures.
- Inspected Home, Explore, Bookings, Chat, Favorites, Vendor Detail, Auth (Login & OTP), and Profile screens to identify gaps in empty states, skeleton loaders, error sanitization, offline detection, slow network handling, search suggestions, permission handling, 401 session expiration, form field validation, and success modals.

### Added
- Created complete, reusable UI states architecture in `lib/core/ui_states/`:
  - `models/ui_state.dart`: Immutable state wrapper `UiState<T>` and `UiStatus` enum covering all 10 states.
  - `theme/ui_state_style.dart`: Centralized design tokens and typography matching OneDestiny Luxury Burgundy (`#6B1028`) and Champagne Gold (`#D4AF37`).
  - `utils/error_message_mapper.dart`: Sanitizes technical exceptions, SQL/schema errors, and HTTP status codes into user-friendly messages.
  - `utils/network_state_handler.dart`: Broadcast bus for 401 session expiration, connectivity changes, and slow request latency detection.
  - `widgets/empty_state_widget.dart`: Context-specific empty states (bookings, chats, favorites, notifications, vendor requests) with actionable CTAs.
  - `widgets/skeleton_shimmer.dart` & `skeleton_loader_card.dart`: Custom shimmering linear gradient skeleton loaders matching vendor cards, vendor grid, booking items, and conversation list.
  - `widgets/inline_loading_button.dart`: Inline loading button with progress spinner and duplicate click prevention.
  - `widgets/full_screen_loader.dart`: Full-screen loading indicator for critical operations.
  - `widgets/error_state_widget.dart`: Human-readable error widget with retry debouncing and secondary back navigation.
  - `widgets/no_internet_widget.dart`: Custom 2D vector flat illustration (`_DisconnectedCloudPainter`) rendering smartphone chassis, cloud, and disconnected Wi-Fi slash with one-tap retry.
  - `widgets/slow_network_widget.dart`: Non-intrusive floating banner and inline card with request cancellation.
  - `widgets/no_search_results_widget.dart`: Suggestions box, search query highlighting, and filter reset CTAs.
  - `widgets/permission_denied_widget.dart`: Permission denial rationale with direct `openAppSettings()` integration and modal bottom sheet helper.
  - `widgets/session_expired_dialog.dart`: Non-dismissible luxury modal for HTTP 401 session timeouts.
  - `widgets/form_field_feedback.dart`: Accessible inline form field captions, state borders, and validation helpers (phone, email, OTP, password).
  - `widgets/success_state_widget.dart`: Animated elastic checkmark confirmation widget and bottom sheet helper.
  - `widgets/state_view_switcher.dart`: Master declarative state view switcher.
  - `ui_states.dart`: Unified barrel export file.
- Added 16 unit and widget tests in `test/ui_states_test.dart` verifying all 10 states, animations, sanitization, validation, and theme switching.
- Added `test/app_version_test.dart` verifying `AppVersionInfo` deserialization and Development Team UI presentation.

### Changed
- `lib/core/network/api_response.dart`: Added optional `statusCode` field to `ApiResponse<T>` with backward compatibility.
- `lib/core/services/api_service.dart`: Added slow request threshold timer (4s), broadcast to `NetworkStateHandler`, and connectivity handling.
- `lib/core/state/app_state.dart`: Added error tracking and getters for vendors, bookings, chats, and search queries.
- `lib/main.dart`: Wired global navigator key, subscribed to `NetworkStateHandler.instance.sessionExpiredStream`, and integrated `SessionExpiredDialog` presentation with clean redirection to `LoginScreen`.
- `lib/features/home/views/home_screen.dart`: Integrated `SkeletonLoaderCard.vendorCardList()`, `ErrorStateWidget`, `NoSearchResultsWidget`, `EmptyStateWidget`, and `SlowNetworkWidget.banner()`.
- `lib/features/explore/views/explore_screen.dart`: Integrated `SkeletonLoaderCard.vendorGrid()`, `ErrorStateWidget`, `NoSearchResultsWidget`, and `EmptyStateWidget`.
- `lib/features/bookings/views/bookings_screen.dart`: Integrated `SkeletonLoaderCard.bookingList()`, filter-specific `EmptyStateWidget` (with "Explore Vendors" tab navigation), and `ErrorStateWidget`.
- `lib/features/chat/views/chat_screen.dart`: Integrated `SkeletonLoaderCard.conversationList()`, `EmptyStateWidget.noConversations()`, and `ErrorStateWidget`.
- `lib/features/favorites/views/favorites_screen.dart`: Integrated `EmptyStateWidget.noFavorites()`.
- `lib/features/vendor_detail/views/vendor_detail_screen.dart`: Integrated `SuccessStateWidget.showSheet()` for booking confirmation with safety note and done CTA.
- `lib/features/auth/views/login_screen.dart`: Integrated `InlineLoadingButton`, `FormFieldFeedback.validatePhone`, `validateEmail`, `validatePassword`, and inline error borders.
- `lib/features/auth/views/otp_verification_screen.dart`: Integrated `InlineLoadingButton`, `FormFieldFeedback.validateOtp`, and wrapped PIN input in `FormFieldFeedback`.
- `lib/features/profile/views/profile_screen.dart`: Integrated `PermissionDeniedWidget.showSheet()` fallback on photo/camera access denial.
- `lib/features/main/views/main_navigation_screen.dart`: Passed tab navigation callbacks to child screens.
- `lib/core/models/app_version_info.dart`: Restored developers array parsing from `assets/config/app_version.json` to properly map the Development Team (Manohar & Datta) with roles and avatars.
- Updated brand logo assets across the entire application: Replaced previous logo with the user's latest 3D beveled gold luxury emblem and cast-shadow typography ("ONE DESTINY - MAKE EVERY CELEBRATION IN ONE PLACE"), processed into pristine 32-bit ARGB PNGs (`assets/images/one_destiny_logo_transparent.png`, `assets/images/one_destiny_logo.png`, and `assets/images/one_destiny_logo_full.png`) at `1072 x 659` with 32px symmetrical safety padding on all edges.
- Refined logo edge antialiasing: Applied a 5x5 Gaussian spatial smoothing filter and cubic Hermite S-curve interpolation to the alpha channel, coupled with edge color inpainting/dilation to decontaminate checkerboard gray and white values, completely eliminating jagged stepping, JPEG ringing, and white/gray halos.
- Refined `lib/features/splash/views/splash_screen.dart`: Integrated the complete un-cropped logo with soft, buttery-smooth antialiased edges on the Deep Burgundy background, removing duplicate visible tagline text while preserving offstage accessibility nodes for automated tests.

### Fixed
- Fixed unhandled HTTP 401 token expiration silently dropping requests without notifying user.
- Fixed raw technical errors leaking to UI during network/server timeouts.
- Fixed duplicate button submissions during authentication and booking submission.
- Fixed commented-out `json['developers']` deserialization in `AppVersionInfo.fromJson` that prevented Development Team members from displaying in `AboutOneDestinyScreen`.

### Refactored
- Unified UI state rendering using clean, declarative component architecture.
- Centralized error message mapping across all features.

### Files Modified
- lib/core/network/api_response.dart
- lib/core/services/api_service.dart
- lib/core/state/app_state.dart
- lib/core/ui_states/models/ui_state.dart
- lib/core/ui_states/theme/ui_state_style.dart
- lib/core/ui_states/utils/error_message_mapper.dart
- lib/core/ui_states/utils/network_state_handler.dart
- lib/core/ui_states/widgets/empty_state_widget.dart
- lib/core/ui_states/widgets/error_state_widget.dart
- lib/core/ui_states/widgets/form_field_feedback.dart
- lib/core/ui_states/widgets/full_screen_loader.dart
- lib/core/ui_states/widgets/inline_loading_button.dart
- lib/core/ui_states/widgets/no_internet_widget.dart
- lib/core/ui_states/widgets/no_search_results_widget.dart
- lib/core/ui_states/widgets/permission_denied_widget.dart
- lib/core/ui_states/widgets/session_expired_dialog.dart
- lib/core/ui_states/widgets/skeleton_loader_card.dart
- lib/core/ui_states/widgets/skeleton_shimmer.dart
- lib/core/ui_states/widgets/state_view_switcher.dart
- lib/core/ui_states/widgets/success_state_widget.dart
- lib/core/ui_states/ui_states.dart
- lib/features/auth/views/login_screen.dart
- lib/features/auth/views/otp_verification_screen.dart
- lib/features/bookings/views/bookings_screen.dart
- lib/features/chat/views/chat_screen.dart
- lib/features/explore/views/explore_screen.dart
- lib/features/favorites/views/favorites_screen.dart
- lib/features/home/views/home_screen.dart
- lib/features/main/views/main_navigation_screen.dart
- lib/features/profile/views/profile_screen.dart
- lib/features/splash/views/splash_screen.dart
- lib/features/vendor_detail/views/vendor_detail_screen.dart
- lib/core/models/app_version_info.dart
- lib/main.dart
- test/app_version_test.dart
- test/ui_states_test.dart
- CHANGELOG.md

### Breaking Changes
- None

### Testing
- `flutter analyze`: 0 issues found across all files.
- `flutter test`: 25/25 tests passed across `test/app_version_test.dart`, `test/ui_states_test.dart`, `test/luxury_header_test.dart`, `test/paged_response_test.dart`, and `test/widget_test.dart`.

### Notes
- Designed for unified consumption across both Customer and Vendor application codebases with zero third-party UI state bloat.

---

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
