import 'package:cloud_firestore/cloud_firestore.dart';

class UserDocumentModel {
  String? userId;
  String firstName;
  String lastName;
  String email;
  String phone;
  String address;
  String wilaya;
  String commune;
  String userTypeId;
  String role;
  String status;
  bool profileCompleted;
  String registrationStep;
  Map<String, dynamic> data;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserDocumentModel({
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.wilaya,
    required this.commune,
    required this.userTypeId,
    this.role = 'user',
    this.status = 'pending',
    this.profileCompleted = false,
    this.registrationStep = 'extra_details',
    this.data = const {},
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'wilayaId': wilaya,
      'communeId': commune,
      'userTypeId': userTypeId,
      'role': role,
      'status': status,
      'profileCompleted': profileCompleted,
      'registrationStep': registrationStep,
      'data': data,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class UserFileDocument {
  final String fileName;
  final String fileCategory;
  final String fileExtension;
  final String fileUrl;
  final String uploadedAt;
  final String status;
  final String? fieldName;
  final String? rejectionReason;

  UserFileDocument({
    required this.fileName,
    required this.fileCategory,
    required this.fileExtension,
    required this.fileUrl,
    required this.rejectionReason,
    required this.uploadedAt,
    this.status = 'pending',
    this.fieldName,
  });
}

class NewsDocument {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final String categoryId;
  final String featuredImage;
  final List<String> images;
  final List<String> tags;
  final String status;
  final bool isPublished;
  final bool isFeatured;
  final int viewsCount;
  final int likesCount;
  final int commentsCount;
  final String authorId;
  final String authorName;
  final String seoTitle;
  final String seoDescription;
  final List<String> seoKeywords;
  final List<String> wilayaIds;
  final String sourceName;
  final String sourceUrl;
  final List<String> attachments;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NewsDocument({
    required this.id,
    required this.title,
    this.slug = "",
    this.summary = "",
    required this.content,
    this.categoryId = "",
    this.featuredImage = "",
    this.images = const [],
    this.tags = const [],
    this.status = "published",
    this.isPublished = true,
    this.isFeatured = false,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.authorId = "",
    this.authorName = "إدارة المنصة",
    this.seoTitle = "",
    this.seoDescription = "",
    this.seoKeywords = const [],
    this.wilayaIds = const [],
    this.sourceName = "",
    this.sourceUrl = "",
    this.attachments = const [],
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory NewsDocument.fromMap(Map<String, dynamic> map, String id) {
    return NewsDocument(
      id: id,
      title: (map['title'] ?? '').toString(),
      slug: (map['slug'] ?? '').toString(),
      summary: (map['summary'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      categoryId: (map['categoryId'] ?? '').toString(),
      featuredImage: (map['featuredImage'] ?? '').toString(),
      images: List<String>.from(map['images'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      status: (map['status'] ?? 'published').toString(),
      isPublished: map['isPublished'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      viewsCount: map['viewsCount'] ?? 0,
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      authorId: (map['authorId'] ?? '').toString(),
      authorName: (map['authorName'] ?? 'إدارة المنصة').toString(),
      seoTitle: (map['seoTitle'] ?? '').toString(),
      seoDescription: (map['seoDescription'] ?? '').toString(),
      seoKeywords: List<String>.from(map['seoKeywords'] ?? []),
      wilayaIds: List<String>.from(map['wilayaIds'] ?? []),
      sourceName: (map['sourceName'] ?? '').toString(),
      sourceUrl: (map['sourceUrl'] ?? '').toString(),
      attachments: List<String>.from(map['attachments'] ?? []),
      publishedAt: map['publishedAt'] is Timestamp
          ? (map['publishedAt'] as Timestamp).toDate()
          : (map['publishedAt'] != null
                ? DateTime.tryParse(map['publishedAt'].toString())
                : null),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] != null
                ? DateTime.tryParse(map['createdAt'].toString())
                : null),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : (map['updatedAt'] != null
                ? DateTime.tryParse(map['updatedAt'].toString())
                : null),
    );
  }
}

class ProjectModel {
  final String id;
  final String projectName;
  final String part;
  final String status;
  final String userId;
  final String dateStart;
  final String dateEnd;
  final String dateReceipt;
  final String wilayaId;
  final String communeId;

  ProjectModel({
    required this.id,
    required this.projectName,
    required this.part,
    required this.status,
    required this.userId,
    required this.dateStart,
    required this.dateEnd,
    required this.dateReceipt,
    required this.wilayaId,
    required this.communeId,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      projectName: map['projectName'] ?? '',
      part: map['part'] ?? '',
      status: map['status'] ?? '',
      userId: map['userId'] ?? '',
      dateStart: map['dateStart'] ?? '',
      dateEnd: map['dateEnd'] ?? '',
      dateReceipt: map['dateReceipt'] ?? '',
      wilayaId: map['wilayaId']?.toString() ?? '',
      communeId: map['communeId']?.toString() ?? '',
    );
  }
}

class ProjectStatusModel {
  final String id;
  final String nameAr;
  final String color;
  final String icon;
  final bool isActive;

  ProjectStatusModel({
    required this.id,
    required this.nameAr,
    required this.color,
    required this.icon,
    required this.isActive,
  });

  factory ProjectStatusModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectStatusModel(
      id: id,
      nameAr: map['nameAr'] ?? '',
      color: map['color'] ?? 'grey',
      icon: map['icon'] ?? 'info',
      isActive: map['isActive'] ?? true,
    );
  }
}

class OnboardingPageData {
  final String title;
  final String desc;
  final String iconPath; // Use IconData or String path
  final String startColor;
  final String endColor;

  OnboardingPageData({
    required this.title,
    required this.desc,
    required this.iconPath,
    required this.startColor,
    required this.endColor,
  });
}

class MockFirestore {
  static UserDocumentModel? currentUser;

  static final List<OnboardingPageData> onboardingPages = [
    OnboardingPageData(
      title: "إدارة وثائق المقاولين",
      desc:
          "أرشفة وإدارة ملفات المقاولين والمؤسسات بسهولة وتدقيقها رقمياً لضمان تطابق الضوابط الفنية والقانونية.",
      iconPath: "business_center",
      startColor: "0xFF0670A9",
      endColor: "0xFFD6EEF8",
    ),
    OnboardingPageData(
      title: "ربط المقاولين بالموردين",
      desc:
          "قنوات تواصل سريعة وشفافة بين أصحاب المشاريع وموردي مواد البناء لضمان جودة عالية للتوريد والاستلام.",
      iconPath: "handshake",
      startColor: "0xFFFF8021",
      endColor: "0xFFD6EEF8",
    ),
    OnboardingPageData(
      title: "متابعة الملفات والمناقصات",
      desc:
          "تابع الصفقات العمومية، والمناقصات المباشرة إلكترونياً وبما يطابق لوائح النزاهة والرقابة الولائية المحدثة.",
      iconPath: "assignment_turned_in",
      startColor: "0xFFFF8021",
      endColor: "0xFFE7F7ED",
    ),
  ];

  static final List<UserFileDocument> _userFiles = [
    UserFileDocument(
      fileName: "السجل التجاري الرئيسي",
      fileCategory: "سجل تجاري",
      fileExtension: "PDF",
      rejectionReason: "PDF",
      fileUrl: "https://storage.cloud/docs/trade_reg_2026.pdf",
      uploadedAt: "30 مايو 2026",
      status: "approved",
    ),
    UserFileDocument(
      fileName: "بطاقة التعريف الجبائية NIF",
      fileCategory: "بطاقة ضريبية",
      rejectionReason: "بطاقة ضريبية",
      fileExtension: "PDF",
      fileUrl: "https://storage.cloud/docs/nif_document.pdf",
      uploadedAt: "30 مايو 2026",
      status: "pending",
    ),
  ];

  static List<UserFileDocument> get userFiles => _userFiles;

  static final List<NewsDocument> newsList = [
    NewsDocument(
      id: "mock_1",
      title: "رقمنة خدمات التدقيق وبراءات المشاركة الولائية",
      content:
          "أطلق ديوان المطابقة الولائي المنظومة الجديدة لاستقبال مستندات التأهيل المهني فوريًا دون الحاجة لتنقل المقاولين والموردين.",
      authorName: "ديوان الخدمة العمومية",
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NewsDocument(
      id: "mock_2",
      title: "تحديث شروط الأهلية والضمان المباشر للصفقات العمومية",
      content:
          "تعلن وزارة المالية واللجنة الاقتصادية عن تبسيط مسارات التدقيق المالي للمقاولين الشباب وأصحاب الحرف اليدوية الناشئة بتبسيطات مرنة.",
      authorName: "الجريدة الرسمية للمالية",
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static void registerInitial(
    String first,
    String last,
    String email,
    String phone,
    String address,
    String wilaya,
    String commune,
    String type,
  ) {
    currentUser = UserDocumentModel(
      firstName: first,
      lastName: last,
      email: email,
      phone: phone,
      address: address,
      wilaya: wilaya,
      commune: commune,
      userTypeId: type,
    );
  }

  static void completeUserProfile(Map<String, String> extraData) {
    if (currentUser != null) {
      currentUser!.status = 'pending';
    }
  }

  static void uploadNewFile(String name, String cat) {
    _userFiles.add(
      UserFileDocument(
        fileName: name,
        fileCategory: cat,
        fileExtension: "PDF",
        rejectionReason: "",
        fileUrl: "https://storage.cloud/docs/uploads/${name.hashCode}.pdf",
        uploadedAt: "الآن",
        status: "pending",
      ),
    );
  }
}
