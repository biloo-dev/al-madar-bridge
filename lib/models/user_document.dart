class UserDocumentModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String wilaya;
  final String commune;
  final String userTypeId; // contractor, supplier, craftsman, investor, equipment_owner
  final String status; // pending, approved, rejected
  final Map<String, dynamic> extraData;

  UserDocumentModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.wilaya,
    required this.commune,
    required this.userTypeId,
    required this.status,
    required this.extraData,
  });
}