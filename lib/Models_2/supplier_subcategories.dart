class SupplierSubCategoryModel {
  final String id;
  final String name;
  final String icon;
  final String description;

  SupplierSubCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  factory SupplierSubCategoryModel.fromJson(
      Map<String, dynamic> json) {
    return SupplierSubCategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'description': description,
  };
}