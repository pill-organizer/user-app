# Smart Pill Organizer

A cross-platform Flutter application for managing medication schedules with IoT device integration. The app monitors storage conditions, sends timely reminders, and ensures medications are stored safely.

## Features

### Medication Scheduling
- Create and manage pill schedules with custom times
- Set recurring schedules for specific days of the week
- Enable/disable individual schedules
- View today's medications at a glance
- "Next pill" highlight on dashboard

### Environmental Monitoring
- Real-time temperature and humidity tracking
- Historical data with daily min/max/average statistics
- Interactive charts powered by FL Chart
- Configurable threshold alerts
- Visual warnings when conditions are outside safe ranges

### Smart Notifications
- Push notifications via Firebase Cloud Messaging
- Local notifications for medication reminders
- Environmental condition alerts
- Configurable buzzer on IoT device

### Security Features
- Firebase Authentication (email/password)
- PIN protection for device access
- RFID token support for physical authentication
- Secure credential hashing

### Device Configuration
- Temperature thresholds (min/max)
- Humidity thresholds (min/max)
- Buzzer on/off toggle
- Push notifications toggle
- PIN management

## Screenshots

The app features a modern, clean UI with:
- Dashboard with greeting and quick stats
- Schedule management with intuitive forms
- Environmental data cards with alert indicators
- Notification history
- Comprehensive settings screen

## Architecture

```
lib/
├── app/                    # App entry point and configuration
├── config/
│   ├── routes.dart         # Navigation routing
│   └── theme.dart          # Material 3 theming
├── core/
│   ├── constants/          # App-wide constants
│   └── utils/              # Utility functions
├── data/
│   ├── models/             # Data models (Schedule, EnvironmentalData, etc.)
│   └── repositories/       # Data layer (Firebase integration)
├── presentation/
│   ├── blocs/              # BLoC state management
│   ├── screens/            # UI screens
│   └── widgets/            # Reusable widgets
└── main.dart               # Entry point
```

### State Management
The app uses the **BLoC pattern** with `flutter_bloc` for predictable state management:
- `AuthBloc` - Authentication state
- `ScheduleBloc` - Medication schedules
- `EnvironmentalBloc` - Temperature/humidity data
- `SettingsBloc` - Device configuration

### Data Layer
- **Firebase Realtime Database** for cloud sync
- **Firebase Authentication** for user management
- **Firebase Cloud Messaging** for push notifications
- **SharedPreferences** for local settings

## Getting Started

### Prerequisites

- Flutter SDK ^3.9.2
- Dart SDK ^3.9.2
- Firebase project with enabled services:
  - Authentication (Email/Password)
  - Realtime Database
  - Cloud Messaging
- Android Studio / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/smart-pill-organizer.git
   cd smart-pill-organizer/smart_pill_organizer_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   
   For Android:
   - Place `google-services.json` in `android/app/`
   
   For iOS:
   - Place `GoogleService-Info.plist` in `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | User authentication |
| `firebase_database` | Realtime data sync |
| `firebase_messaging` | Push notifications |
| `flutter_bloc` | State management |
| `equatable` | Value equality |
| `fl_chart` | Data visualization |
| `flutter_local_notifications` | Local reminders |
| `google_fonts` | Typography (Plus Jakarta Sans) |
| `intl` | Date/time formatting |
| `crypto` | PIN hashing |
| `shared_preferences` | Local storage |

## Design System

The app uses **Material 3** with a custom color palette:

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#1E3A5F` | Main actions, nav bar |
| Secondary | `#3D8B7A` | Success states, toggles |
| Accent | `#FF6B35` | FAB, highlights |
| Background | `#F8FAFC` | Page background |
| Surface | `#FFFFFF` | Cards, dialogs |

Typography is powered by **Plus Jakarta Sans** for a modern, readable interface.

## IoT Device Integration

This app is designed to work with a companion IoT smart pill organizer device that:
- Reads temperature and humidity sensors
- Controls a pill dispensing mechanism
- Supports RFID authentication
- Has an audible buzzer for alerts
- Syncs data via Firebase Realtime Database

### Firebase Database Structure

```
      device/
      ├── schedules/
      │   └── {scheduleId}/
      │       ├── pillName: string
      │       ├── time: string (HH:mm)
      │       ├── days: string (1,2,3,4,5,6,7)
      │       └── enabled: boolean
      ├── environmental/
      │   └── {timestamp}/
      │       ├── temperature: number
      │       ├── humidity: number
      │       └── timestamp: number
      ├── config/
      │   ├── pinHash: string
      │   ├── tempMin: number
      │   ├── tempMax: number
      │   ├── humidityMin: number
      │   ├── humidityMax: number
      │   ├── buzzerEnabled: boolean
      │   └── pushNotificationsEnabled: boolean
      └── notifications/
          └── {notificationId}/
              ├── title: string
              ├── body: string
              ├── type: string
              ├── timestamp: number
              └── read: boolean
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
