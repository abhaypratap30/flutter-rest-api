class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? gender;
  final String? image;
  final String? phone;
  final String? role;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.gender,
    this.image,
    this.phone,
    this.role,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get avatarUrl =>
      image ?? 'https://dummyjson.com/icon/${username.isNotEmpty ? username : 'user'}/150';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: json['firstName'] as String? ?? 'Unknown',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? 'user',
      gender: json['gender'] as String?,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'User',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'gender': gender,
      'image': image,
      'phone': phone,
      'role': role,
    };
  }

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? gender,
    String? image,
    String? phone,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
