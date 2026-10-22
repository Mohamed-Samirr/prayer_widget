# 🌙 Prayer Times & Home Screen Widget (مواقيت الصلاة وودجيت الشاشة الرئيسية)

A minimalist, production-ready, distraction-free **Prayer Times** mobile application built with Flutter, featuring a bespoke **Dark Obsidian UI** and a fully native **Android Home Screen Widget** with real-time countdown recalculation and an instant **Refresh Button**.

---

## ✨ Features (المميزات الرئيسية)

- **100% Offline & Astronomically Accurate Calculation (حساب فلكي دقيق وبدون إنترنت بالكامل):**
  - Powered by the `adhan` Dart package for offline mathematical calculation based on astronomical coordinates.
  - **Egyptian General Authority of Survey (الهيئة المصرية العامة للمساحة)** enabled by default.
  - In-app switcher supporting:
    - Egyptian General Authority of Survey
    - Muslim World League (رابطة العالم الإسلامي)
    - Umm Al-Qura University, Makkah (جامعة أم القرى - مكة المكرمة)
    - Islamic Society of North America - ISNA
    - University of Islamic Sciences, Karachi
    - Dubai (دبي)
    - Kuwait (الكويت)
    - Qatar (قطر)
    - Madhab selector: Standard (Shafi'i, Maliki, Hanbali) vs Hanafi.
  - Smooth midnight handling: automatically transitions to tomorrow's Fajr when Isha has passed.

- **Real-Time Countdown Timer with Tabular Figures (عداد تنازلي فوري بدون اهتزاز للأرقام):**
  - Live `HH:MM:SS` countdown timer showing exact time remaining until the next prayer.
  - Uses `FontFeature.tabularFigures()` on Google Fonts Inter so numeric characters remain fixed-width and never jitter or bounce during counting.
  - Dynamic visual progress indicator displaying elapsed time between prayers.

- **Automatic Location Detection & Offline Caching (تحديد الموقع وحفظه بدون إنترنت):**
  - Detects coordinates using `geolocator` and reverse-geocodes locality & country via `geocoding`.
  - Persists location coordinates and display names to `shared_preferences`.
  - Graceful fallback: If GPS is disabled or permission denied, seamlessly falls back to cached location (or Cairo default: `30.0444, 31.2357`).

- **Bespoke Anti-AI Dark Obsidian Aesthetic (تصميم داكن فاخر وعصري):**
  - Deep matte obsidian background (`#0A0A0C`).
  - Subtle elevated surfaces (`#141417`) with hairline `1px` borders (`#222226`) and `18px` rounded corners.
  - Muted warm gold (`#D4AF37`) & soft sage green (`#4E6E58`) accents applied exclusively to active/next prayer items.
  - Complete list of the 5 daily prayers + Sunrise (Shuruq) with English and Arabic names, exact times, and relative status badges.

---

## 📱 Native Android Home Screen Widget (الويدجيت للشاشة الرئيسية)

The application includes a native Android AppWidget built using Kotlin (`AppWidgetProvider`) and custom XML layouts:

### Widget Components:
1. **Header Row:** Shows your current City/Location name, countdown badge (`"Asr in 01:24:00"`), and the **Interactive Refresh Button**.
2. **Hero Center:** Displays the Next Prayer Name (e.g., `"Asr"`) in high-contrast crisp white and the target time (`"03:22 PM"`) in muted gold.
3. **Bottom 5-Prayer Row:** Displays all 5 daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) in a compact row, with the upcoming/active prayer automatically highlighted in a warm gold pill.
4. **Interactive Refresh Button (زرار تحديث الويدجيت):**
   - Built directly into the widget header (`ic_widget_refresh`).
   - Tapping the refresh button sends a broadcast intent (`ACTION_REFRESH`) to `PrayerWidgetProvider`.
   - The native Kotlin provider immediately recalculates the exact remaining countdown time (`System.currentTimeMillis()`) from the target timestamp without delay or needing to launch the app!
5. **Tap-to-Open:** Tapping anywhere on the widget card opens the application.

---

## 🏗️ Project Architecture (هيكل المشروع)

```text
prayer_widget/
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml                  # Permissions (Location, Internet) & Widget Receiver
│       ├── kotlin/com/example/prayer_widget/
│       │   ├── MainActivity.kt                  # Flutter Activity
│       │   └── PrayerWidgetProvider.kt          # Native Widget Provider with ACTION_REFRESH & instant countdown
│       └── res/
│           ├── drawable/
│           │   ├── ic_widget_refresh.xml        # Vector refresh icon for widget
│           │   ├── widget_active_pill.xml       # Active prayer highlighted pill
│           │   ├── widget_bg.xml                # Obsidian widget container (18dp corner, 1px border)
│           │   ├── widget_btn_refresh_bg.xml    # Refresh button subtle background
│           │   ├── widget_hero_badge.xml        # Countdown badge container
│           │   └── widget_inactive_pill.xml     # Inactive prayer pill
│           ├── layout/
│           │   └── prayer_widget_layout.xml     # XML RemoteViews layout for Home Screen Widget
│           ├── values/
│           │   └── colors.xml                   # Obsidian color palette definitions
│           └── xml/
│               └── prayer_widget_info.xml       # AppWidgetProvider metadata (min dimensions, resize modes)
├── lib/
│   ├── main.dart                                # Entry point & Dark SystemChrome configuration
│   ├── models/
│   │   └── prayer_data.dart                     # PrayerItem, PrayerType, CalculationMethodType, MadhabType
│   ├── providers/
│   │   └── prayer_state.dart                    # Real-time state notifier, 1-second countdown ticker & widget sync
│   ├── screens/
│   │   └── home_screen.dart                     # Distraction-free main screen with pull-to-refresh
│   ├── services/
│   │   ├── location_service.dart                # GPS positioning, reverse geocoding & offline cache
│   │   ├── prayer_service.dart                  # Adhan engine wrapper, next prayer transition, progress & formatting
│   │   └── widget_service.dart                  # HomeWidget data bridge (stores times, names & target epoch)
│   ├── theme/
│   │   └── app_theme.dart                       # Dark obsidian theme tokens, colors & typography
│   └── widgets/
│       ├── hero_countdown_card.dart             # Next prayer hero card with tabular figures & progress bar
│       ├── prayer_tile.dart                     # Individual prayer row item with active gold badges
│       └── settings_sheet.dart                  # Modal bottom sheet to switch calculation methods & madhab
├── test/
│   ├── prayer_test.dart                         # Adhan API integration test
│   └── prayer_service_test.dart                 # Prayer calculations, countdown format & transition unit tests
└── pubspec.yaml                                 # Dependencies (adhan, geolocator, geocoding, home_widget, etc.)
```

---

## 🚀 Getting Started (طريقة التشغيل)

### 1. Prerequisites
- Flutter SDK (v3.24.0 or higher recommended).
- Android SDK (API 21+ / Android 5.0+).

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
Connect your Android phone or start an Android emulator, then run:
```bash
flutter run
```

### 4. How to Add the Home Screen Widget
1. Long-press any empty space on your Android phone's Home Screen.
2. Select **Widgets (الأدوات المصغرة)**.
3. Scroll down to find **Prayer Times**.
4. Drag and drop the widget onto your home screen.
5. Tap the **Refresh Button (زرار التحديث)** on the top-right of the widget at any time to instantly recalculate and refresh the countdown.

---

## 🧪 Testing (الاختبارات الآلية)

Run the test suite to verify prayer calculations, late-night Isha transitions, and countdown formats:
```bash
flutter test
```

All tests pass with 0 warnings or analysis issues.

---

## 📄 License
This project is open-source and free to use.
