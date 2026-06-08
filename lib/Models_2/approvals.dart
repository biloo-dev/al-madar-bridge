class ApprovalModel {
  final String id;

  final String userId;

  final String action;

  final String adminId;

  final String note;

  ApprovalModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.adminId,
    required this.note,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      id: json['id'],
      userId: json['userId'],
      action: json['action'],
      adminId: json['adminId'],
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'action': action,
    'adminId': adminId,
    'note': note,
  };
}