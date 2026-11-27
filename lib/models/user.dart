class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String studentId;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.studentId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'].toString(),
        email: json['email'] as String,
        fullName: json['fullName'] as String,
        role: json['role'] as String? ?? 'Student',
        studentId: json['studentId'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'role': role,
        'studentId': studentId,
      };
}
