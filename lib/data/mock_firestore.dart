import 'dart:async';

class UserDocumentModel {
  String firstName;
  String lastName;
  String email;
  String phone;
  String wilaya;
  String commune;
  String userTypeId;
  String status;

  UserDocumentModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.wilaya,
    required this.commune,
    required this.userTypeId,
    this.status = 'pending',
  });
}

class UserFileDocument {
  final String fileName;
  final String fileCategory;
  final String fileExtension;
  final String fileUrl;
  final String uploadedAt;
  final String status;

  UserFileDocument({
    required this.fileName,
    required this.fileCategory,
    required this.fileExtension,
    required this.fileUrl,
    required this.uploadedAt,
    this.status = 'pending',
  });
}

class NewsDocument {
  final String title;
  final String content;
  final String publishedBy;
  final String publishedAt;

  NewsDocument({
    required this.title,
    required this.content,
    required this.publishedBy,
    required this.publishedAt,
  });
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
      desc: "أرشفة وإدارة ملفات المقاولين والمؤسسات بسهولة وتدقيقها رقمياً لضمان تطابق الضوابط الفنية والقانونية.",
      iconPath: "business_center",
      startColor: "0xFF0670A9",
      endColor: "0xFFD6EEF8",
    ),
    OnboardingPageData(
      title: "ربط المقاولين بالموردين",
      desc: "قنوات تواصل سريعة وشفافة بين أصحاب المشاريع وموردي مواد البناء لضمان جودة عالية للتوريد والاستلام.",
      iconPath: "handshake",
      startColor: "0xFFFF8021",
      endColor: "0xFFD6EEF8",
    ),
    OnboardingPageData(
      title: "متابعة الملفات والمناقصات",
      desc: "تابع الصفقات العمومية، والمناقصات المباشرة إلكترونياً وبما يطابق لوائح النزاهة والرقابة الولائية المحدثة.",
      iconPath: "assignment_turned_in",
      startColor: "0xFFFF8021",
      endColor: "0xFFE7F7ED",
    )
  ];

  static final List<UserFileDocument> _userFiles = [
    UserFileDocument(
      fileName: "السجل التجاري الرئيسي",
      fileCategory: "سجل تجاري",
      fileExtension: "PDF",
      fileUrl: "https://storage.cloud/docs/trade_reg_2026.pdf",
      uploadedAt: "30 مايو 2026",
      status: "approved",
    ),
    UserFileDocument(
      fileName: "بطاقة التعريف الجبائية NIF",
      fileCategory: "بطاقة ضريبية",
      fileExtension: "PDF",
      fileUrl: "https://storage.cloud/docs/nif_document.pdf",
      uploadedAt: "30 مايو 2026",
      status: "pending",
    ),
  ];

  static List<UserFileDocument> get userFiles => _userFiles;

  static final List<NewsDocument> newsList = [
    NewsDocument(
      title: "رقمنة خدمات التدقيق وبراءات المشاركة الولائية",
      content: "أطلق ديوان المطابقة الولائي المنظومة الجديدة لاستقبال مستندات التأهيل المهني فوريًا دون الحاجة لتنقل المقاولين والموردين.",
      publishedBy: "ديوان الخدمة العمومية",
      publishedAt: "منذ ساعتين",
    ),
    NewsDocument(
      title: "تحديث شروط الأهلية والضمان المباشر للصفقات العمومية",
      content: "تعلن وزارة المالية واللجنة الاقتصادية عن تبسيط مسارات التدقيق المالي للمقاولين الشباب وأصحاب الحرف اليدوية الناشئة بتبسيطات مرنة.",
      publishedBy: "الجريدة الرسمية للمالية",
      publishedAt: "منذ يوم واحد",
    ),
  ];

  static void registerInitial(String first, String last, String email, String phone, String wilaya, String commune, String type) {
    currentUser = UserDocumentModel(
      firstName: first,
      lastName: last,
      email: email,
      phone: phone,
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
    _userFiles.add(UserFileDocument(
      fileName: name,
      fileCategory: cat,
      fileExtension: "PDF",
      fileUrl: "https://storage.cloud/docs/uploads/${name.hashCode}.pdf",
      uploadedAt: "الآن",
      status: "pending",
    ));
  }
}