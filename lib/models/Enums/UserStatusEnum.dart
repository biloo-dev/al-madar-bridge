
enum UserStatus {
  pending,
  approved,
  rejected,
  needDocuments,
  suspended,
}

extension UserStatusX on UserStatus {
  String toJson() {
    switch (this) {
      case UserStatus.pending:
        return 'pending';
      case UserStatus.approved:
        return 'approved';
      case UserStatus.rejected:
        return 'rejected';
      case UserStatus.needDocuments:
        return 'need_documents';
      case UserStatus.suspended:
        return 'suspended';
    }
  }

  static UserStatus fromJson(String value) {
    switch (value) {
      case 'pending':
        return UserStatus.pending;
      case 'approved':
        return UserStatus.approved;
      case 'rejected':
        return UserStatus.rejected;
      case 'need_documents':
        return UserStatus.needDocuments;
      case 'suspended':
        return UserStatus.suspended;
      default:
        return UserStatus.pending; // fallback
    }
  }
}