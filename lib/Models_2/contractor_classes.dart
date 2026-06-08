class ContractorClassModel {
  final String id;
  final String name;
  final String description;

  ContractorClassModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ContractorClassModel.fromJson(
      Map<String, dynamic> json) {
    return ContractorClassModel(
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