class AttendanceRecord {
  final int id;
  final String courseCode;
  final String date; // yyyy-MM-dd
  final bool present;

  const AttendanceRecord({
    required this.id,
    required this.courseCode,
    required this.date,
    required this.present,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'courseCode': courseCode,
        'date': date,
        'present': present ? 1 : 0,
      };

  static AttendanceRecord fromMap(Map<String, dynamic> map) => AttendanceRecord(
        id: map['id'] as int,
        courseCode: map['courseCode'] as String,
        date: map['date'] as String,
        present: map['present'] == 1,
      );
}

class CourseAttendanceSummary {
  final String courseCode;
  final String courseName;
  final int held;
  final int attended;

  const CourseAttendanceSummary({
    required this.courseCode,
    required this.courseName,
    required this.held,
    required this.attended,
  });

  double get percent => held == 0 ? 0 : attended / held * 100;
}
