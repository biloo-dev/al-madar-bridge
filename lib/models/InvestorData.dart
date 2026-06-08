import 'package:al_madar_bridge/models/Abstract/profileData.dart';

class InvestorData extends ProfileData {
  final String investorType;
  final double investmentValue;
  final List<String> targetWilayas;
  final String description;

  InvestorData({
    required this.investorType,
    required this.investmentValue,
    required this.targetWilayas,
    required this.description,
  });

  factory InvestorData.fromJson(Map<String, dynamic> json) {
    return InvestorData(
      investorType: json['investorType'] ?? '',
      investmentValue: (json['investmentValue'] ?? 0).toDouble(),
      targetWilayas: List<String>.from(json['targetWilayas'] ?? []),
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'investorType': investorType,
      'investmentValue': investmentValue,
      'targetWilayas': targetWilayas,
      'description': description,
    };
  }
}