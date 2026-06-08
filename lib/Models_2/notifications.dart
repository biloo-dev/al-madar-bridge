class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String type;
  final bool isRead;
  final String body;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.isRead,
    required this.body,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(
      Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      type: json['type'],
      isRead: json['isRead'],
      body: json['body'] ?? '',
      createdAt: json['createdAt'] ?? DateTime.timestamp().toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'type': type,
    'isRead': isRead,
    'body': body,
    'createdAt': createdAt,
  };
}