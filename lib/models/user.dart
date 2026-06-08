


import 'package:al_madar_bridge/models/Enums/UserStatusEnum.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String wilayaId;
  final String communeId;
  final String userTypeId;
  final bool isProfileCompleted;
  final UserStatus status;
  final String createdAt;
  final String updatedAt;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.wilayaId,
    required this.communeId,
    required this.userTypeId,
    required this.isProfileCompleted,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
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
      isProfileCompleted: json['isProfileCompleted'] ?? false,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
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
      'isProfileCompleted': isProfileCompleted,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? wilayaId,
    String? communeId,
    String? userTypeId,
    bool? isProfileCompleted,
    UserStatus? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      wilayaId: wilayaId ?? this.wilayaId,
      communeId: communeId ?? this.communeId,
      userTypeId: userTypeId ?? this.userTypeId,
      isProfileCompleted:
      isProfileCompleted ?? this.isProfileCompleted,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '$firstName $lastName';
}