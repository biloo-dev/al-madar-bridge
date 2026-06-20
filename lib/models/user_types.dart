class UserTypeModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr; // حقل الوصف بالعربية
  final bool isActive;

  const UserTypeModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr = '',
    this.isActive = true,
  });

  factory UserTypeModel.fromJson(Map<String, dynamic> json) {
    return UserTypeModel(
      id: json['id']?.toString() ?? '',
      nameAr: (json['nameAr'] ?? json['name_ar'] ?? '').toString(),
      nameEn: (json['nameEn'] ?? json['name_en'] ?? '').toString(),
      descriptionAr: (json['descriptionAr'] ?? json['description_ar'] ?? json['desc_ar'] ?? '').toString(),
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
