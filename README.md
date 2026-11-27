# Campus Companion

A Flutter student app for Android with login, a weekly timetable, attendance tracking, announcements, and offline storage.

## Features
- Login with demo student credentials (mock REST backend with JWT-style tokens)
- Dashboard with today's classes, attendance rate, and unread announcements
- Weekly timetable view with course details
- Attendance marking and per-course attendance history
- Announcements feed with categories
- Local notifications for class reminders
- Offline storage: data is cached in SQLite and loads without a network connection

## Demo account
- Email: aown.rafaqat@student.edu.pk
- Password: any 6+ characters (demo backend accepts it)

## Tech
- Flutter (Dart), Provider for state management
- dio for HTTP with an auth interceptor
- sqflite for offline storage
- flutter_local_notifications for reminders

## Download
Install the APK from [Releases](../../releases). Android 6.0+.

## Run it yourself
```
flutter pub get
flutter run
```
