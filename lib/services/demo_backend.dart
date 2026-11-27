import 'dart:convert';

import 'package:dio/dio.dart';

/// Stand-in for the campus REST API. It answers the same routes a real
/// backend exposes (login, session, announcements, timetable) with
/// realistic JSON, including a generated JWT, so the whole app can be
/// exercised without a live server. Point [baseUrl] at a real API and
/// remove this interceptor to go live.
class DemoBackend {
  static const String baseUrl = 'https://demo.campuscompanion.local/v1';

  static const List<Map<String, dynamic>> announcements = [
    {
      'id': 3,
      'title': 'Midterm exams: seating plan published',
      'body': 'Seating plans for the midterm examinations are posted outside the examination cell and on the portal. Bring your student ID to every paper. Mobile phones must be deposited at the counter.',
      'author': 'Examination Cell',
      'publishedAt': '2026-11-26T09:30:00.000Z',
    },
    {
      'id': 2,
      'title': 'Fee challan deadline extended',
      'body': 'The deadline for the Fall semester fee challan has been extended to November 30. Late submissions carry the standard fine after that date.',
      'author': 'Accounts Office',
      'publishedAt': '2026-11-24T12:00:00.000Z',
    },
    {
      'id': 1,
      'title': 'Semester project proposals due',
      'body': 'Final-year project proposals are due with your supervisor by the end of this week. Use the proposal template from the department portal.',
      'author': 'CS Department',
      'publishedAt': '2026-11-21T08:00:00.000Z',
    },
  ];

  static const List<Map<String, dynamic>> timetable = [
    {'id': 1, 'courseCode': 'CS-401', 'courseName': 'Distributed Systems', 'instructor': 'Dr. Salman Raza', 'room': 'Lab 3', 'weekday': 1, 'startTime': '09:00', 'endTime': '10:30'},
    {'id': 2, 'courseCode': 'CS-412', 'courseName': 'Mobile Application Development', 'instructor': 'Ms. Hira Anwar', 'room': 'Lab 1', 'weekday': 1, 'startTime': '11:00', 'endTime': '12:30'},
    {'id': 3, 'courseCode': 'SE-402', 'courseName': 'Software Quality Engineering', 'instructor': 'Dr. Nadia Iqbal', 'room': 'Room 204', 'weekday': 2, 'startTime': '09:00', 'endTime': '10:30'},
    {'id': 4, 'courseCode': 'CS-421', 'courseName': 'Machine Learning', 'instructor': 'Dr. Kamran Ali', 'room': 'Room 301', 'weekday': 2, 'startTime': '13:00', 'endTime': '14:30'},
    {'id': 5, 'courseCode': 'CS-401', 'courseName': 'Distributed Systems', 'instructor': 'Dr. Salman Raza', 'room': 'Lab 3', 'weekday': 3, 'startTime': '10:00', 'endTime': '11:30'},
    {'id': 6, 'courseCode': 'MG-301', 'courseName': 'Entrepreneurship', 'instructor': 'Mr. Bilal Chaudhry', 'room': 'Room 112', 'weekday': 3, 'startTime': '12:00', 'endTime': '13:00'},
    {'id': 7, 'courseCode': 'CS-412', 'courseName': 'Mobile Application Development', 'instructor': 'Ms. Hira Anwar', 'room': 'Lab 1', 'weekday': 4, 'startTime': '09:00', 'endTime': '10:30'},
    {'id': 8, 'courseCode': 'CS-421', 'courseName': 'Machine Learning', 'instructor': 'Dr. Kamran Ali', 'room': 'Lab 5', 'weekday': 4, 'startTime': '11:00', 'endTime': '12:30'},
    {'id': 9, 'courseCode': 'SE-402', 'courseName': 'Software Quality Engineering', 'instructor': 'Dr. Nadia Iqbal', 'room': 'Room 204', 'weekday': 5, 'startTime': '10:00', 'endTime': '11:30'},
    {'id': 10, 'courseCode': 'MG-301', 'courseName': 'Entrepreneurship', 'instructor': 'Mr. Bilal Chaudhry', 'room': 'Room 112', 'weekday': 5, 'startTime': '13:00', 'endTime': '14:00'},
  ];

  static String _b64(String s) =>
      base64Url.encode(utf8.encode(s)).replaceAll('=', '');

  static String issueToken(String email) {
    final header = _b64('{"alg":"HS256","typ":"JWT"}');
    final payload = _b64(jsonEncode({
      'sub': email,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now()
          .add(const Duration(hours: 24))
          .millisecondsSinceEpoch ~/
          1000,
    }));
    final signature = _b64('demo-signature-for-$email');
    return '$header.$payload.$signature';
  }

  static const Map<String, dynamic> me = {
    'id': 42,
    'email': 'aown.rafaqat@student.edu.pk',
    'fullName': 'Muhammad Aown Rafaqat',
    'role': 'Student',
    'studentId': 'AUST-2024-CS-042',
  };
}

class DemoBackendInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final route = options.path;
    final method = options.method.toUpperCase();

    if (method == 'POST' && route == '/auth/login') {
      final data = (options.data ?? {}) as Map;
      final email = (data['email'] ?? '').toString().trim();
      final password = (data['password'] ?? '').toString();
      if (email.isEmpty || password.length < 6) {
        return handler.resolve(Response<Map<String, dynamic>>(
          requestOptions: options,
          data: {'status': 'error', 'message': 'Invalid email or password too short'},
        ));
      }
      final token = DemoBackend.issueToken(email);
      return handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        data: {'status': 'ok', 'token': token, 'me': DemoBackend.me},
      ));
    }

    final auth = options.headers['Authorization'] as String?;
    if (auth == null || !auth.startsWith('Bearer ')) {
      return handler.reject(DioException(
        requestOptions: options,
        error: 'Unauthorized',
      ));
    }

    if (method == 'GET' && route == '/me') {
      return handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        data: DemoBackend.me,
      ));
    }
    if (method == 'GET' && route == '/announcements') {
      return handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        data: {'status': 'ok', 'announcements': DemoBackend.announcements},
      ));
    }
    if (method == 'GET' && route == '/timetable') {
      return handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        data: {'status': 'ok', 'slots': DemoBackend.timetable},
      ));
    }

    return handler.next(options);
  }
}
