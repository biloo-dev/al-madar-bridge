class SupplierCategoryModel {
  final String id;
  final String name;
  final String icon;
  final String description;

  SupplierCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  factory SupplierCategoryModel.fromJson(
      Map<String, dynamic> json) {
    return SupplierCategoryModel(
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