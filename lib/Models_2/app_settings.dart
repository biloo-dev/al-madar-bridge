class AppSettingModel {
  final String id;
  final String supportPhone;
  final String appVersion;
  final String maintenanceMode;
  final String appDescription;
  final String supportEmail;

  AppSettingModel({
    required this.id,
    required this.supportPhone,
    required this.appVersion,
    required this.maintenanceMode,
    required this.appDescription,
    required this.supportEmail,
  });

  factory AppSettingModel.fromJson(
      Map<String, dynamic> json) {
    return AppSettingModel(
      id: json['id'],
      supportPhone: json['supportPhone'],
      appVersion: json['appVersion'],
      maintenanceMode: json['maintenanceMode'],
      appDescription: json['appDescription'],
      supportEmail: json['supportEmail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'supportPhone': supportPhone,
    'appVersion': appVersion,
    'maintenanceMode': maintenanceMode,
    'appDescription': appDescription,
    'supportEmail': supportEmail,
  };
}