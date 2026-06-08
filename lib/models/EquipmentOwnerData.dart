import 'package:al_madar_bridge/models/Abstract/profileData.dart';

class EquipmentOwnerData extends ProfileData {
  final String equipmentType;
  final String serviceType;
  final double pricingRate;

  EquipmentOwnerData({
    required this.equipmentType,
    required this.serviceType,
    required this.pricingRate,
  });

  factory EquipmentOwnerData.fromJson(Map<String, dynamic> json) {
    return EquipmentOwnerData(
      equipmentType: json['equipmentType'] ?? '',
      serviceType: json['serviceType'] ?? '',
      pricingRate: (json['pricingRate'] ?? 0).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'equipmentType': equipmentType,
      'serviceType': serviceType,
      'pricingRate': pricingRate,
    };
  }
}