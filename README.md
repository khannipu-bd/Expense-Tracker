# 💰 Expense Tracker App

A modern, production-grade personal finance and daily expense tracking mobile application built with **Flutter**. Designed with an offline-first architecture, clean UI/UX, and comprehensive analytics to help users manage their money, adhere to dynamic daily budgets, and visualize their spending habits effectively.

---

##  Key Features

### 1. 📊 Smart Dashboard & Home Overview
* **Dynamic Daily Spending Limit:** Automatically calculates your daily allowance based on your monthly budget:
  $$\text{Daily Limit} = \frac{\text{Remaining Budget}}{\text{Remaining Days in Month}}$$
  Includes warning states if daily limits are exceeded[cite: 3].
* **Deficit & Negative Balance Indicators:** Clear visual cues when total expenses exceed income, rendering deficit values in high-visibility warning colors with real-time insight badges[cite: 2].
* **Filter Synchronization:** Instant synchronization between temporal filters (Today, This Week, This Month, All Time) and dashboard balance calculations[cite: 2, 5].

### 2. 📝 Transaction & Ledger Management
* **Intuitive Categorization:** Seamlessly record income and expense entries with custom categories, icons, and timestamps[cite: 1, 2, 4].
* **Grouped Transaction History:** Clean chronological feeds grouped by date with net daily balance indicators[cite: 1].
* **Optimized Floating Action Buttons (FAB):** Streamlined navigation with contextual action triggers restricted exclusively to transactional views[cite: 1, 2].

### 3. 📈 Visual Analytics & Reports (Powered by `fl_chart`)
* **Category Breakdown (Pie Chart):** Interactive, color-coded spending distribution with touch interaction and section expansion[cite: 1, 5].
* **Income vs. Expense Trend (Bar Chart):** Comparative dual-bar visualization tracking cash flows across various periods[cite: 2, 5].
* **Responsive Empty States:** Informative fallback screens guiding users when no transactions exist for the selected date filter[cite: 5].

### 4. 🎯 Budget Management
* **Monthly Budget Tracking:** Establish spending caps with real-time progress bars showing spent vs. remaining balances[cite: 3].
* **Proactive Budget Warnings:** Visual notifications when consumption reaches high-risk thresholds[cite: 3].

### 5. 🔒 Security & Data Privacy
* **Biometric & PIN Authentication:** Dual-layer security featuring fingerprint/face unlock using `local_auth` alongside a 4-digit PIN fallback.
* **Granular Safety Controls:** Two-step confirmation dialogs (typing `DELETE`) for destructive database resets[cite: 4].
* **Offline-First Privacy:** All financial records are stored securely on the local device without unnecessary third-party tracking.

### 6. 📄 Statement Export & Backups
* **Printable PDF Statements:** Generate structured, formatted monthly summaries ready for printing or archiving[cite: 4].
* **Spreadsheet Export (.XLSX / .CSV):** Export raw transaction logs directly into Excel-compatible files[cite: 4].
* **Local JSON Backup & Restore:** Easy migration and local device backup functionality[cite: 4].

### 7. 🎨 Personalization & UX
* **Theming:** Full system-aware Light and Dark modes with true black elements for AMOLED displays[cite: 4].
* **Bilingual Localization:** Comprehensive runtime language switching between **English** and **Bangla (বাংলা)**[cite: 4].
* **Localized Currency:** Native support for the Bangladeshi Taka (`৳`) symbol and regional numerical formatting[cite: 1, 2, 3, 4].

---

## 🛠️ Tech Stack & Packages

* **Framework:** [Flutter](https://flutter.dev/) (Channel Stable)
* **Language:** [Dart](https://dart.dev/)
* **Architecture:** Clean Architecture (Presentation, Domain, Data) with Feature-First structure
* **State Management:** Riverpod / Provider / BLoC
* **Key Dependencies:**
    * Charts: [`fl_chart`](https://pub.dev/packages/fl_chart)
    * Biometric Security: [`local_auth`](https://pub.dev/packages/local_auth)
    * Document Generation: [`pdf`](https://pub.dev/packages/pdf), [`excel`](https://pub.dev/packages/excel)
    * File Sharing: [`share_plus`](https://pub.dev/packages/share_plus)
    * Localization: [`flutter_localizations`](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html), [`intl`](https://pub.dev/packages/intl)
    * Local Storage: `shared_preferences` / `sqflite` / `hive`

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed on your local development machine:
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher)
* [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter/Dart extensions
* Java Development Kit (JDK 17+)
* Android SDK with minimum API Level 23 (Android 6.0+) for Biometric support
