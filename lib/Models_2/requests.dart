import 'package:cloud_firestore/cloud_firestore.dart';

class RequestDocument {
  final String id;
  final String requestTypeId;
  final String createdBy;
  final String title;
  final String description;
  final String wilayaId;
  final String communeId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RequestDocument({
    required this.id,
    required this.requestTypeId,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.wilayaId,
    required this.communeId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory RequestDocument.fromMap(Map<String, dynamic> map, String id) {
    return RequestDocument(
      id: id,
      requestTypeId: map['requestTypeId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      wilayaId: map['wilayaId'] ?? '',
      communeId: map['communeId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: map['updatedAt'] is Timestamp 
          ? (map['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestTypeId': requestTypeId,
      'createdBy': createdBy,
      'title': title,
      'description': description,
      'wilayaId': wilayaId,
      'communeId': communeId,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class RequestType {
  final String id;
  final String nameAr;
  final String nameFr;
  final String icon;

  RequestType({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.icon,
  });

  factory RequestType.fromMap(Map<String, dynamic> map) {
    return RequestType(
      id: map['id'] ?? '',
      nameAr: map['name_ar'] ?? '',
      nameFr: map['name_fr'] ?? '',
      icon: map['icon'] ?? '',
    );
  }
}
