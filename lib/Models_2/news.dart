class NewsModel {
  final String id;
  final String title;
  final String content;
  final String image;
  final String publishedAt;
  final String publishedBy;
  final bool isPublished;

  NewsModel({
    required this.id,
    required this.image,
    required this.title,
    required this.publishedBy,
    required this.isPublished,
    required this.content,
    required this.publishedAt,
  });

  factory NewsModel.fromJson(
      Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      image: json['image'],
      title: json['title'],
      publishedBy: json['publishedBy'],
      isPublished: json['isPublished'],
      content: json['content'] ?? '',
      publishedAt: json['publishedAt'] ?? DateTime.timestamp().toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image': image,
    'title': title,
    'publishedBy': publishedBy,
    'isPublished': isPublished,
    'content': content,
    'publishedAt': publishedAt,
  };
}