import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/announcement.dart';
import '../models/attendance.dart';
import '../models/course.dart';

/// Local cache in SQLite (sqflite). Announcements and the timetable are
/// fetched from the API and stored here so every screen still works with
/// no network; attendance is written here and summarized per course.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      join(dir, 'campus_companion.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE announcements(id INTEGER PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL, author TEXT NOT NULL, publishedAt TEXT NOT NULL)');
        await db.execute(
            'CREATE TABLE course_slots(id INTEGER PRIMARY KEY, courseCode TEXT NOT NULL, courseName TEXT NOT NULL, instructor TEXT NOT NULL, room TEXT NOT NULL, weekday INTEGER NOT NULL, startTime TEXT NOT NULL, endTime TEXT NOT NULL)');
        await db.execute(
            'CREATE TABLE attendance(id INTEGER PRIMARY KEY AUTOINCREMENT, courseCode TEXT NOT NULL, date TEXT NOT NULL, present INTEGER NOT NULL, UNIQUE(courseCode, date))');
      },
    );
  }

  Future<void> cacheAnnouncements(List<Announcement> items) async {
    final database = await db;
    final batch = database.batch();
    await database.delete('announcements');
    for (final a in items) {
      batch.insert('announcements', a.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Announcement>> cachedAnnouncements() async {
    final database = await db;
    final rows = await database.query('announcements', orderBy: 'id DESC');
    return rows.map(Announcement.fromMap).toList();
  }

  Future<void> cacheTimetable(List<CourseSlot> slots) async {
    final database = await db;
    final batch = database.batch();
    await database.delete('course_slots');
    for (final s in slots) {
      batch.insert('course_slots', s.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<CourseSlot>> cachedTimetable() async {
    final database = await db;
    final rows = await database.query(
      'course_slots',
      orderBy: 'weekday ASC, startTime ASC',
    );
    return rows.map(CourseSlot.fromMap).toList();
  }

  /// Writes one attendance mark for a course on a date. One row per
  /// course per day: marking again the same day overwrites.
  Future<void> markAttendance(
      String courseCode, String date, bool present) async {
    final database = await db;
    await database.insert(
      'attendance',
      {
        'courseCode': courseCode,
        'date': date,
        'present': present ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AttendanceRecord>> attendanceFor(String courseCode) async {
    final database = await db;
    final rows = await database.query(
      'attendance',
      where: 'courseCode = ?',
      whereArgs: [courseCode],
      orderBy: 'date DESC',
    );
    return rows.map(AttendanceRecord.fromMap).toList();
  }

  Future<Map<String, CourseAttendanceSummary>> attendanceSummaries(
      List<CourseSlot> slots) async {
    final database = await db;
    final summaries = <String, CourseAttendanceSummary>{};
    for (final slot in slots) {
      final code = slot.courseCode;
      if (summaries.containsKey(code)) continue;
      final rows = await database.query(
        'attendance',
        where: 'courseCode = ?',
        whereArgs: [code],
      );
      final held = rows.length;
      final attended = rows.where((r) => r['present'] == 1).length;
      summaries[code] = CourseAttendanceSummary(
        courseCode: code,
        courseName: slot.courseName,
        held: held,
        attended: attended,
      );
    }
    return summaries;
  }
}
