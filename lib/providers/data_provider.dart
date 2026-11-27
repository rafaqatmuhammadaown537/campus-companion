import 'package:flutter/foundation.dart';

import '../models/announcement.dart';
import '../models/attendance.dart';
import '../models/course.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'auth_provider.dart';

/// Owns the app data: timetable, attendance and announcements.
/// Every read goes to the local SQLite cache first, then the API is
/// consulted and the cache refreshed, so screens stay populated offline.
class DataProvider extends ChangeNotifier {
  DataProvider(this._auth) : _api = _auth.authService.api;

  final AuthProvider _auth;
  final ApiService _api;

  List<CourseSlot> timetable = [];
  List<Announcement> announcements = [];
  Map<String, CourseAttendanceSummary> attendance = {};
  bool offlineMode = false;
  bool loading = false;

  Future<void> loadAll() async {
    if (_auth.user == null) return;
    loading = true;
    notifyListeners();

    final cache = DatabaseService.instance;
    timetable = await cache.cachedTimetable();
    announcements = await cache.cachedAnnouncements();
    attendance = await cache.attendanceSummaries(timetable);
    notifyListeners();

    try {
      final res = await _api.get('/timetable');
      final slots = ((res['slots'] as List).cast<Map<String, dynamic>>())
          .map(CourseSlot.fromJson)
          .toList();
      await cache.cacheTimetable(slots);
      timetable = slots;
      attendance = await cache.attendanceSummaries(timetable);
      offlineMode = false;
    } catch (_) {
      offlineMode = timetable.isNotEmpty || announcements.isNotEmpty;
    }

    try {
      final res = await _api.get('/announcements');
      final items = ((res['announcements'] as List).cast<Map<String, dynamic>>())
          .map(Announcement.fromJson)
          .toList();
      final knownIds = announcements.map((a) => a.id).toSet();
      await cache.cacheAnnouncements(items);
      announcements = items;
      for (final a in items.where((a) => !knownIds.contains(a.id))) {
        await NotificationService.instance.show(
          id: a.id,
          title: 'New announcement',
          body: a.title,
        );
      }
      offlineMode = false;
    } catch (_) {
      offlineMode = offlineMode || announcements.isNotEmpty;
    }

    loading = false;
    notifyListeners();
  }

  List<CourseSlot> slotsForWeekday(int weekday) =>
      timetable.where((s) => s.weekday == weekday).toList();

  Future<void> markAttendance(String courseCode, bool present) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await DatabaseService.instance.markAttendance(courseCode, today, present);
    attendance = await DatabaseService.instance.attendanceSummaries(timetable);
    notifyListeners();
    await NotificationService.instance.show(
      id: 9000 + DateTime.now().millisecondsSinceEpoch % 1000,
      title: 'Attendance marked',
      body: '$courseCode marked ${present ? 'present' : 'absent'} for today',
    );
  }

  void reset() {
    timetable = [];
    announcements = [];
    attendance = {};
    offlineMode = false;
    notifyListeners();
  }
}
