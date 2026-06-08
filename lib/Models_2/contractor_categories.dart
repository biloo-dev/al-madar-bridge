class ContractorCategoryModel {
  final String id;
  final String name;
  final String description;

  ContractorCategoryModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ContractorCategoryModel.fromJson(
      Map<String, dynamic> json) {
    return ContractorCategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };
}