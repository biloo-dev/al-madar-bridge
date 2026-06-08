class UserTypeModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final bool isActive;

  const UserTypeModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.isActive = true,
  });

  factory UserTypeModel.fromJson(Map<String, dynamic> json) {
    return UserTypeModel(
      id: json['id'] ?? '',
      nameAr: json['nameAr'] ?? '',
      nameEn: json['nameEn'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'isActive': isActive,
    };
  }

  @override
  String toString() => 'UserTypeModel(id: $id, nameAr: $nameAr)';
}
