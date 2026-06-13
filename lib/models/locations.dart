class WilayaModel {
  final String id;
  final String nameEn;
  final String nameAr;

  WilayaModel({required this.id, required this.nameEn, required this.nameAr});

  factory WilayaModel.fromJson(Map<String, dynamic> json) {
    return WilayaModel(
      id: json['id']?.toString() ?? '',
      nameEn: (json['name'] ?? json['name_en'] ?? '').toString(),
      nameAr: (json['ar_name'] ?? json['arName'] ?? json['name_ar'] ?? '').toString(),
    );
  }
}

class CommuneModel {
  final String id;
  final String nameEn;
  final String nameAr;
  final String wilayaId;

  CommuneModel({required this.id, required this.nameEn, required this.nameAr, required this.wilayaId});

  factory CommuneModel.fromJson(Map<String, dynamic> json) {
    return CommuneModel(
      id: json['id']?.toString() ?? '',
      nameEn: (json['name'] ?? json['name_en'] ?? '').toString(),
      nameAr: (json['ar_name'] ?? json['arName'] ?? json['name_ar'] ?? '').toString(),
      wilayaId: json['wilaya_id']?.toString() ?? json['wilayaId']?.toString() ?? '',
    );
  }
}
