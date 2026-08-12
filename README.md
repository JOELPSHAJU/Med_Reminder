# 💊 Med Reminder

> An offline-first Flutter medicine reminder application with reliable alarm-based dose scheduling, adherence tracking, local data persistence, and a clean teal UI — built with Clean Architecture, Riverpod, Hive, and native Android alarm capabilities.

<p align="center">
  <img src="assets/images/app_logo.png" width="120" alt="Med Reminder Logo"/>
</p>

---

## ✨ Features

* 📅 **Smart Dose Scheduling** — Add medicines with custom frequencies, reminder times, and durations
* ⏰ **Reliable Medicine Alarms** — Schedule time-critical medicine reminders using a dedicated alarm-based system
* 🔔 **Local Notifications** — Provides notification support alongside the alarm system
* 🔒 **Background & Locked-Screen Support** — Designed to trigger reminders when the app is running in the background, closed, or the device is locked
* 🔄 **Rolling Alarm Scheduling** — Upcoming medicine doses are synchronized with the device alarm system using a rolling scheduling window
* 🔊 **Sound & Vibration** — Medicine alarms provide audible and vibration alerts
* ✅ **Adherence Tracking** — Mark doses as Taken, Skipped, or Missed
* ⚠️ **Early Dose Warning** — Warns users when attempting to mark a dose as taken before its scheduled time
* 📊 **Dashboard Statistics** — View daily completion percentages and dose status summaries
* 📂 **History Log** — View and filter previous medicine dose activity
* 💾 **Offline-First** — Core medicine and dose data is stored locally using Hive
* 🎨 **Premium Teal UI** — Clean blue-green interface with an animated splash screen

---

## 🏗️ Architecture

The application follows **Clean Architecture** principles with a feature-based project structure.

```text
lib/
├── core/
│   ├── services/
│   ├── theme/
│   └── utilities/
│
├── features/
│   ├── splash/
│   ├── dashboard/
│   ├── medicine_core/
│   ├── add_edit_medicine/
│   ├── history/
│   └── settings/
│
└── main.dart
```

### Technology Stack

| Layer               | Technology                      |
| ------------------- | ------------------------------- |
| Framework           | Flutter                         |
| Language            | Dart                            |
| Architecture        | Clean Architecture              |
| State Management    | Riverpod                        |
| Local Storage       | Hive                            |
| Alarm Scheduling    | `alarm` package                 |
| Notifications       | `flutter_local_notifications`   |
| Android Integration | Native Kotlin / Method Channels |

---

## ⏰ Alarm & Reminder System

Medicine reminders are treated as **time-critical alarms rather than simple scheduled notifications**.

When a medicine is added, the application generates individual dose occurrences and stores them locally. Upcoming doses are then synchronized with the Android alarm system.

### Reminder Flow

```text
Add Medicine
     │
     ▼
Generate Dose Occurrences
     │
     ▼
Store Locally in Hive
     │
     ▼
Synchronize Upcoming Doses
     │
     ▼
Schedule Android Alarms
     │
     ▼
Scheduled Time Reached
     │
     ▼
Medicine Alarm
     ├── Sound
     ├── Vibration
     └── Notification / Alarm UI
```

The application uses a **rolling scheduling approach** so that upcoming reminders are synchronized without unnecessarily scheduling a large number of alarms at once.

The reminder system is designed to support:

* App in foreground
* App in background
* App closed
* Device screen locked
* Multiple medicines
* Multiple reminder times
* Sound and vibration
* Android background restrictions
* Device reboot/background handling where supported

> **Note:** Android manufacturers such as Xiaomi, Samsung, Vivo, and others may apply their own battery-management restrictions. The application handles the required Android permissions and provides appropriate background/autostart guidance where necessary.

---

## 💾 Offline-First Data

Med Reminder is designed to work without an internet connection.

Medicine information, dose occurrences, and adherence records are stored locally using **Hive**.

```text
User
 │
 ▼
Medicine
 │
 ▼
Dose Occurrences
 │
 ├── Scheduled
 ├── Taken
 ├── Skipped
 └── Missed
```

This allows users to manage their medicines and track adherence without requiring a network connection.

---

## 📊 Adherence Tracking

Each medicine dose can have one of several states:

* 🕐 **Scheduled**
* ✅ **Taken**
* ⏭️ **Skipped**
* ❌ **Missed**

The dashboard uses these records to calculate daily adherence statistics and provide an overview of the user's medicine schedule.

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK `>=3.0.0`
* Dart SDK `>=3.0.0`
* Android Studio
* Android SDK
* A physical Android device is recommended for testing alarm behavior

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

The generated release APK can be found under:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Testing

The reminder system should be tested on a **physical Android device**, particularly for time-critical alarm behavior.

Recommended scenarios:

* [ ] Create a medicine with a future reminder
* [ ] Verify the alarm at the scheduled time
* [ ] Test with the app open
* [ ] Test with the app in the background
* [ ] Test after closing the app
* [ ] Test with the phone locked
* [ ] Test sound
* [ ] Test vibration
* [ ] Test multiple medicines
* [ ] Test multiple reminder times
* [ ] Test Android notification permissions
* [ ] Test exact-alarm permissions where applicable
* [ ] Test device restart and reminder restoration
* [ ] Test manufacturer-specific battery restrictions

---

## 📁 Project Structure

```text
Med_Reminder/
│
├── android/
├── assets/
│   └── images/
│       └── app_logo.png
│
├── lib/
│   ├── core/
│   ├── features/
│   └── main.dart
│
├── test/
├── pubspec.yaml
└── README.md
```

---

## 🔐 Android Permissions

The application may require Android permissions related to:

* Notifications
* Exact alarms
* Background alarm execution
* Boot/background handling
* Full-screen alarm presentation where supported

Some Android manufacturers may additionally require users to allow **Autostart** or disable battery optimization for reliable time-critical reminders.

---

## 📦 Key Packages

* **Riverpod** — State management
* **Hive** — Local persistence
* **alarm** — Alarm scheduling and alarm execution
* **flutter_local_notifications** — Local notification support

---

## 📄 License

This project is open source and available under the MIT License.

---

<p align="center">
  Joel P Shaju
</p>
