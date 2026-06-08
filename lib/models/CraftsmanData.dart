import 'package:al_madar_bridge/models/Abstract/profileData.dart';

class CraftsmanData extends ProfileData {
  final String selectedCraft;
  final int experienceYears;
  final double dayRate;
  final String description;

  CraftsmanData({
    required this.selectedCraft,
    required this.experienceYears,
    required this.dayRate,
    required this.description,
  });

  factory CraftsmanData.fromJson(Map<String, dynamic> json) {
    return CraftsmanData(
      selectedCraft: json['selectedCraft'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      dayRate: (json['dayRate'] ?? 0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'selectedCraft': selectedCraft,
      'experienceYears': experienceYears,
      'dayRate': dayRate,
      'description': description,
    };
  }
}