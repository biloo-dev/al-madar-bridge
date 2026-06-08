import 'package:al_madar_bridge/models/Abstract/profileData.dart';

class ContractorData extends ProfileData {
  final String companyName;
  final String tradeRegister;
  final String taxNumber;
  final String contractorCategory;
  final String contractorClass;

  ContractorData({
    required this.companyName,
    required this.tradeRegister,
    required this.taxNumber,
    required this.contractorCategory,
    required this.contractorClass,
  });

  factory ContractorData.fromJson(Map<String, dynamic> json) {
    return ContractorData(
      companyName: json['company_name'] ?? '',
      tradeRegister: json['trade_register'] ?? '',
      taxNumber: json['tax_number'] ?? '',
      contractorCategory: json['contractor_category'] ?? '',
      contractorClass: json['contractor_class'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'trade_register': tradeRegister,
      'tax_number': taxNumber,
      'contractor_category': contractorCategory,
      'contractor_class': contractorClass,
    };
  }
}