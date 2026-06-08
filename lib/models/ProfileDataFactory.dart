import 'package:al_madar_bridge/models/Abstract/profileData.dart';
import 'package:al_madar_bridge/models/ContractorData.dart';
import 'package:al_madar_bridge/models/CraftsmanData.dart';
import 'package:al_madar_bridge/models/Enums/ProfileTypeEnum.dart';
import 'package:al_madar_bridge/models/EquipmentOwnerData.dart';
import 'package:al_madar_bridge/models/InvestorData.dart';
import 'package:al_madar_bridge/models/SupplierData.dart';

class ProfileDataFactory {
  static ProfileData fromJson(ProfileType type, Map<String, dynamic> json) {
    switch (type) {
      case ProfileType.contractor:
        return ContractorData.fromJson(json);

      case ProfileType.supplier:
        return SupplierData.fromJson(json);

      case ProfileType.craftsman:
        return CraftsmanData.fromJson(json);

      case ProfileType.investor:
        return InvestorData.fromJson(json);

      case ProfileType.equipmentOwner:
        return EquipmentOwnerData.fromJson(json);
    }
  }
}