class UserTypeModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final bool isActive;

  UserTypeModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.isActive,
  });

  factory UserTypeModel.fromJson(Map<String, dynamic> json) {
    return UserTypeModel(
      id: json['id'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'isActive': isActive,
  };
}