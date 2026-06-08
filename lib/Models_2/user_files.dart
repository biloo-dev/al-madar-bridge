class UserFileModel {
  final String id;

  final String userId;

  final String fileName;

  final String fileUrl;

  final String fileType;

  final String fileCategory;

  final String status;

  UserFileModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileCategory,
    required this.status,
  });

  factory UserFileModel.fromJson(Map<String, dynamic> json) {
    return UserFileModel(
      id: json['id'],
      userId: json['userId'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
      fileCategory: json['fileCategory'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'fileType': fileType,
    'fileCategory': fileCategory,
    'status': status,
  };
}