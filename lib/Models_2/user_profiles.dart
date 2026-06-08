class UserProfileModel {
  final String userId;

  final String type;

  final Map<String, dynamic> data;

  final String approvalStatus;

  final String? approvedBy;

  UserProfileModel({
    required this.userId,
    required this.type,
    required this.data,
    required this.approvalStatus,
    this.approvedBy,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      approvalStatus: json['approvalStatus'] ?? 'pending',
      approvedBy: json['approvedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'data': data,
      'approvalStatus': approvalStatus,
      'approvedBy': approvedBy,
    };
  }
}