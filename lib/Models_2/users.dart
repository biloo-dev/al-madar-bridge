class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  final String wilayaId;
  final String communeId;

  final String userTypeId;

  final bool profileCompleted;

  final String status;

  final String? avatar;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.wilayaId,
    required this.communeId,
    required this.userTypeId,
    required this.profileCompleted,
    required this.status,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      wilayaId: json['wilayaId'] ?? '',
      communeId: json['communeId'] ?? '',
      userTypeId: json['userTypeId'] ?? '',
      profileCompleted: json['profileCompleted'] ?? false,
      status: json['status'] ?? 'pending',
      avatar: json['avatar'],
      createdAt: json['createdAt']?.toDate(),
      updatedAt: json['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'wilayaId': wilayaId,
      'communeId': communeId,
      'userTypeId': userTypeId,
      'profileCompleted': profileCompleted,
      'status': status,
      'avatar': avatar,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}