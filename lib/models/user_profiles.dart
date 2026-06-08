
import 'package:al_madar_bridge/models/Abstract/profileData.dart';
import 'package:al_madar_bridge/models/Enums/ProfileTypeEnum.dart';


class UserProfileModel {
  final String userId;
  final ProfileType type;
  final ProfileData data;

  UserProfileModel({
    required this.userId,
    required this.type,
    required this.data,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final type = ProfileTypeX.fromJson(json['type']);

    return UserProfileModel(
      userId: json['userId'] ?? '',
      type: type,
      data: ProfileData.fromJson(type, json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type.toJson(),
      'data': data.toJson(),
    };
  }
}