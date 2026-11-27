class CourseSlot {
  final int id;
  final String courseCode;
  final String courseName;
  final String instructor;
  final String room;
  final int weekday; // 1 = Monday ... 7 = Sunday
  final String startTime; // "09:00"
  final String endTime; // "10:30"

  const CourseSlot({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.instructor,
    required this.room,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  factory CourseSlot.fromJson(Map<String, dynamic> json) => CourseSlot(
        id: json['id'] as int,
        courseCode: json['courseCode'] as String,
        courseName: json['courseName'] as String,
        instructor: json['instructor'] as String,
        room: json['room'] as String,
        weekday: json['weekday'] as int,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'courseCode': courseCode,
        'courseName': courseName,
        'instructor': instructor,
        'room': room,
        'weekday': weekday,
        'startTime': startTime,
        'endTime': endTime,
      };

  static CourseSlot fromMap(Map<String, dynamic> map) => CourseSlot(
        id: map['id'] as int,
        courseCode: map['courseCode'] as String,
        courseName: map['courseName'] as String,
        instructor: map['instructor'] as String,
        room: map['room'] as String,
        weekday: map['weekday'] as int,
        startTime: map['startTime'] as String,
        endTime: map['endTime'] as String,
      );
}
