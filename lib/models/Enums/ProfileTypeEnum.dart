enum ProfileType {
  contractor,
  supplier,
  craftsman,
  investor,
  equipmentOwner,
}

extension ProfileTypeX on ProfileType {
  String toJson() {
    switch (this) {
      case ProfileType.contractor:
        return 'contractor';
      case ProfileType.supplier:
        return 'supplier';
      case ProfileType.craftsman:
        return 'craftsman';
      case ProfileType.investor:
        return 'investor';
      case ProfileType.equipmentOwner:
        return 'equipment_owner';
    }
  }

  static ProfileType fromJson(String value) {
    switch (value) {
      case 'contractor':
        return ProfileType.contractor;
      case 'supplier':
        return ProfileType.supplier;
      case 'craftsman':
        return ProfileType.craftsman;
      case 'investor':
        return ProfileType.investor;
      case 'equipment_owner':
        return ProfileType.equipmentOwner;
      default:
        return ProfileType.contractor;
    }
  }

  /// Arabic label for UI
  String get labelAr {
    switch (this) {
      case ProfileType.contractor:
        return 'مقاول';
      case ProfileType.supplier:
        return 'مورد سلع وخدمات';
      case ProfileType.craftsman:
        return 'أصحاب الحرف';
      case ProfileType.investor:
        return 'مستثمرون وأصحاب المال';
      case ProfileType.equipmentOwner:
        return 'أصحاب العتاد والآلات';
    }
  }
}