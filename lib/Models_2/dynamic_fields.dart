class DynamicFieldModel {
  final String id;

  final String userTypeId;

  final String fieldName;

  final String fieldLabel;

  final String fieldType;

  final bool requiredField;

  final String? dataSource;

  DynamicFieldModel({
    required this.id,
    required this.userTypeId,
    required this.fieldName,
    required this.fieldLabel,
    required this.fieldType,
    required this.requiredField,
    this.dataSource,
  });

  factory DynamicFieldModel.fromJson(Map<String, dynamic> json) {
    return DynamicFieldModel(
      id: json['id'],
      userTypeId: json['userTypeId'],
      fieldName: json['fieldName'],
      fieldLabel: json['fieldLabel'],
      fieldType: json['fieldType'],
      requiredField: json['required'] ?? false,
      dataSource: json['dataSource'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userTypeId': userTypeId,
    'fieldName': fieldName,
    'fieldLabel': fieldLabel,
    'fieldType': fieldType,
    'required': requiredField,
    'dataSource': dataSource,
  };
}