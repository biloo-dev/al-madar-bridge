import 'package:al_madar_bridge/models/ContractorData.dart';
import 'package:al_madar_bridge/models/Enums/ProfileTypeEnum.dart' show ProfileType;
import 'package:al_madar_bridge/models/SupplierData.dart';

abstract class ProfileData {
  Map<String, dynamic> toJson();

  static ProfileData fromJson(ProfileType type, Map<String, dynamic> json) {
    switch (type) {
      case ProfileType.contractor:
        return ContractorData.fromJson(json);
      case ProfileType.supplier:
        return SupplierData.fromJson(json)  ;
      case ProfileType.craftsman:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ProfileType.investor:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ProfileType.equipmentOwner:
        // TODO: Handle this case.
        throw UnimplementedError();

    }
  }
}