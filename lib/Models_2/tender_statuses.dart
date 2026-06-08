class TenderStatusModel {
  final String id;

  final String contractorId;

  final String projectName;

  final String status;

  final String description;

  TenderStatusModel({
    required this.id,
    required this.contractorId,
    required this.projectName,
    required this.status,
    required this.description,
  });

  factory TenderStatusModel.fromJson(Map<String, dynamic> json) {
    return TenderStatusModel(
      id: json['id'],
      contractorId: json['contractorId'],
      projectName: json['projectName'],
      status: json['status'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'contractorId': contractorId,
    'projectName': projectName,
    'status': status,
    'description': description,
  };
}