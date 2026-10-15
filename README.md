# Doctor Appointment Booking App

A Flutter-based mobile application that helps patients find doctors and book appointments. The application uses Firebase for authentication and cloud data storage.

## Features

- **User Authentication:** Register and log in using email and password.
- **Role-Based Access:** Supports patients, doctors, and administrators.
- **Find Doctors:** View doctor profiles, qualifications, specializations, and experience.
- **Doctor Availability:** Administrators can manage doctor availability.
- **Appointment Booking:** Patients can book appointments with available doctors.
- **Appointment Management:** Store appointment details and statuses in Firestore.
- **Cloud Database:** Store application data using Firebase Cloud Firestore.

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Material Design

## Project Structure

```text
doctor_appointment/
├── lib/
│   ├── screens/
│   ├── services/
│   ├── models/
│   └── main.dart
├── android/
├── ios/
├── web/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

*Note: The folders shown are a general example. Adjust them to match your actual project structure.*

## Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Firebase project
- Android device or emulator

## Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/doctor-Appointment.git
```

Replace `YOUR_USERNAME` with your GitHub username.

### 2. Open the Project

```bash
cd doctor_appointment
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Configure your Firebase project for the Flutter application.

Ensure that:

- Firebase Authentication is enabled.
- Email/password authentication is enabled.
- Cloud Firestore is created.
- Firebase configuration files are correctly configured for your platforms.
- Firestore security rules restrict access according to user roles and ownership.

### 5. Run the Application

```bash
flutter run
```

## Build the Android APK

To generate a release APK, run:

```bash
flutter build apk --release
```

The APK will be generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

You can distribute this APK to Android users for installation.

## Firebase Collections

The application uses the following Firestore collections:

| Collection | Purpose |
|---|---|
| `users` | Stores user profiles and roles |
| `doctors` | Stores doctor profiles and availability |
| `appointments` | Stores appointment and booking information |

## Security

- Use Firebase Authentication to identify users.
- Configure Firestore security rules to protect user and appointment data.
- Never upload service-account private keys or other sensitive credentials to GitHub.
- Do not allow unrestricted public access to the database.

## Future Enhancements

- Appointment reminders and notifications
- Doctor search and filtering
- Appointment history
- Improved user interface
- Online payment integration

## Author

**Project:** Doctor Appointment Booking App

**Developed using:** Flutter and Firebase
