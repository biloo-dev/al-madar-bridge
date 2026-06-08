import 'package:al_madar_bridge/models/Abstract/profileData.dart';

class SupplierData extends ProfileData {
  final String businessName;
  final String description;

  SupplierData({
    required this.businessName,
    required this.description,
  });

  factory SupplierData.fromJson(Map<String, dynamic> json) {
    return SupplierData(
      businessName: json['business_name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      'description': description,
    };
  }
}