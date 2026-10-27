/// The signed-in user's profile row.
class Profile {
  Profile({
    required this.id,
    required this.username,
    this.name,
    this.birthday,
    this.avatarPath,
    this.role = 'student',
  });

  final String id;
  final String username;
  final String? name;
  final DateTime? birthday;
  final String? avatarPath;
  final String role;

  bool get isAdmin => role == 'admin';

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        username: j['username'] as String,
        name: j['name'] as String?,
        birthday: j['birthday'] == null ? null : DateTime.parse(j['birthday'] as String),
        avatarPath: j['avatar_path'] as String?,
        role: (j['role'] as String?) ?? 'student',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'birthday': birthday?.toIso8601String().substring(0, 10),
        'avatar_path': avatarPath,
        'role': role,
      };
}
