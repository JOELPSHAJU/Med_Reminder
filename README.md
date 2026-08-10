# 💊 Med Reminder

> An offline-first Flutter medicine reminder app with smart dose scheduling, real-time adherence tracking, local notifications, and a clean teal UI — built with Clean Architecture, Riverpod, and Hive.

<p align="center">
  <img src="assets/images/app_logo.png" width="120" alt="Med Reminder Logo"/>
</p>

---

## ✨ Features

- 📅 **Smart Dose Scheduling** — Add medicines with custom frequencies, times, and durations
- 🔔 **Local Notifications** — On-device reminders that work completely offline
- ✅ **Real-Time Adherence Tracking** — Mark doses as Taken, Skipped, or Missed
- ⚠️ **Early Dose Warning** — Warns when marking a dose as taken before its scheduled time
- 📊 **Dashboard Stats** — Daily completion percentages and dose status summaries
- 📂 **History Log** — Full log of past dose activity with filtering
- 🎨 **Neutral Blue-Green Theme** — Premium teal UI with animated splash screen

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles:

```
lib/
├── core/                  # Shared utilities, theme, services
├── features/
│   ├── splash/            # Animated splash screen
│   ├── dashboard/         # Daily overview & dose actions
│   ├── medicine_core/     # Medicine CRUD
│   ├── add_edit_medicine/ # Add/edit medicine flow
│   ├── history/           # Dose history log
│   └── settings/          # App settings
```

**State Management**: Riverpod  
**Local Storage**: Hive  
**Notifications**: flutter_local_notifications

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0

### Run Locally

```bash
git clone https://github.com/JOELPSHAJU/Med_Reminder.git
cd Med_Reminder
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
```

---

## 📄 License

This project is open source and available under the MIT License.

---

Made with ❤️ using Flutter
