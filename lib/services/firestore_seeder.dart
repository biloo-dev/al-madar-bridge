import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedAll() async {
    try {
      await seedOnboarding();
      await seedUserTypes();
      await seedContractorCategories();
      await seedContractorClasses();
      await seedSupplierCategories();
      await seedSupplierSubcategories();
      await seedCraftsmanCategories();
      await seedInvestmentCategories();
      await seedEquipmentCategories();
      await seedDynamicFields();
      await seedNews();
      await seedAppSettings();
      await seedAdminUser();
      print('✅ Firestore seeding completed successfully.');
    } catch (e) {
      print('❌ Firestore seeding failed: $e');
    }
  }

  static Future<void> seedUserTypes() async {
    final data = [
      {"id": "contractor", "nameAr": "مقاول", "nameEn": "Contractor", "isActive": true},
      {"id": "supplier", "nameAr": "مورد سلع وخدمات", "nameEn": "Supplier", "isActive": true},
      {"id": "craftsman", "nameAr": "صاحب حرفة", "nameEn": "Craftsman", "isActive": true},
      {"id": "investor", "nameAr": "مستثمر", "nameEn": "Investor", "isActive": true},
      {"id": "equipment_owner", "nameAr": "صاحب عتاد وآلات", "nameEn": "Equipment Owner", "isActive": true}
    ];
    for (var item in data) {
      await _db.collection('user_types').doc(item['id'] as String).set(item, SetOptions(merge: true));
    }
    print('User types seeded.');
  }

  static Future<void> seedOnboarding() async {
    final pages = [
      {
        'id': 'page1',
        'title': "إدارة وثائق المقاولين",
        'desc': "أرشفة وإدارة ملفات المقاولين والمؤسسات بسهولة وتدقيقها رقمياً لضمان تطابق الضوابط الفنية والقانونية.",
        'icon_path': "business_center",
        'order': 1,
      },
      {
        'id': 'page2',
        'title': "ربط المقاولين بالموردين",
        'desc': "قنوات تواصل سريعة وشفافة بين أصحاب المشاريع وموردي مواد البناء لضمان جودة عالية للتوريد والاستلام.",
        'icon_path': "handshake",
        'order': 2,
      },
      {
        'id': 'page3',
        'title': "متابعة الملفات والمناقصات",
        'desc': "تابع الصفقات العمومية، والمناقصات المباشرة إلكترونياً وبما يطابق لوائح النزاهة والرقابة الولائية المحدثة.",
        'icon_path': "assignment_turned_in",
        'order': 3,
      }
    ];

    for (var page in pages) {
      await _db.collection('onboarding').doc(page['id'] as String).set(page, SetOptions(merge: true));
    }
    print('Onboarding seeded.');
  }

  static Future<void> seedContractorCategories() async {
    final data = [
      {"name": "أشغال الطرق", "description": "Road Works"},
      {"name": "البناء", "description": "Building Construction"},
      {"name": "الري", "description": "Hydraulics"},
      {"name": "الكهرباء", "description": "Electrical Works"},
      {"name": "الغاز", "description": "Gas Networks"},
      {"name": "التهيئة الحضرية", "description": "Urban Development"}
    ];
    for (var item in data) {
      // Using the name as a document ID to avoid duplicates
      await _db.collection('contractor_categories').doc(item['name'] as String).set(item, SetOptions(merge: true));
    }
    print('Contractor categories seeded.');
  }

  static Future<void> seedContractorClasses() async {
    final data = [
      {"name": "صنف 1", "description": "Class 1"},
      {"name": "صنف 2", "description": "Class 2"},
      {"name": "صنف 3", "description": "Class 3"},
      {"name": "صنف 4", "description": "Class 4"},
      {"name": "صنف 5", "description": "Class 5"}
    ];
    for (var item in data) {
      await _db.collection('contractor_classes').doc(item['name'] as String).set(item, SetOptions(merge: true));
    }
    print('Contractor classes seeded.');
  }

  static Future<void> seedSupplierCategories() async {
    final data = [
      {"name": "مواد البناء", "icon": "construction"},
      {"name": "قطع الغيار", "icon": "settings"},
      {"name": "عقارات", "icon": "home"},
      {"name": "خدمات النقل", "icon": "truck"},
      {"name": "خدمات الإقامة", "icon": "hotel"},
      {"name": "معدات السلامة", "icon": "shield"}
    ];
    for (var item in data) {
      await _db.collection('supplier_categories').doc(item['name'] as String).set(item, SetOptions(merge: true));
    }
    print('Supplier categories seeded.');
  }

  static Future<void> seedSupplierSubcategories() async {
    final data = [
      {"categoryName": "مواد البناء", "name": "إسمنت"},
      {"categoryName": "مواد البناء", "name": "حديد"},
      {"categoryName": "مواد البناء", "name": "رمل"},
      {"categoryName": "مواد البناء", "name": "حصى"},
      {"categoryName": "مواد البناء", "name": "طوب"},
      {"categoryName": "قطع الغيار", "name": "قطع غيار حفارات"},
      {"categoryName": "قطع الغيار", "name": "قطع غيار شاحنات"},
      {"categoryName": "عقارات", "name": "قطعة أرض"},
      {"categoryName": "عقارات", "name": "مستودع"},
      {"categoryName": "عقارات", "name": "مرآب"}
    ];
    for (var item in data) {
      final id = "${item['categoryName']}_${item['name']}";
      await _db.collection('supplier_subcategories').doc(id).set(item, SetOptions(merge: true));
    }
    print('Supplier subcategories seeded.');
  }

  static Future<void> seedCraftsmanCategories() async {
    final data = [
      {"name": "نجار"},
      {"name": "حداد"},
      {"name": "سباك"},
      {"name": "كهربائي"},
      {"name": "دهان"},
      {"name": "لحام"},
      {"name": "بناء"}
    ];
    for (var item in data) {
      await _db.collection('craftsman_categories').doc(item['name'] as String).set(item, SetOptions(merge: true));
    }
    print('Craftsman categories seeded.');
  }

  static Future<void> seedInvestmentCategories() async {
    final data = [
      {"name": "تمويل مشاريع"},
      {"name": "شراكة"},
      {"name": "استثمار عقاري"},
      {"name": "استثمار صناعي"},
      {"name": "شراء حصص"}
    ];
    for (var item in data) {
      await _db.collection('investment_categories').doc(item['name'] as String).set(item, SetOptions(merge: true));
    }
    print('Investment categories seeded.');
  }

  static Future<void> seedEquipmentCategories() async {
    final data = [
      {"name": "حفارة"},
      {"name": "جرافة"},
      {"name": "شاحنة"},
      {"name": "رافعة"},
      {"name": "مولد كهربائي"},
      {"name": "خلاطة إسمنت"},
      {"name": "مدحلة"}
    ];
    for (var item in data) {
      await _db.collection('equipment_categories').doc(item['name'] as String).set(item, SetOptions(merge: true));
    }
    print('Equipment categories seeded.');
  }

  static Future<void> seedDynamicFields() async {
    final data = [
      {
        "userTypeId": "contractor",
        "fieldName": "company_name",
        "fieldLabel": "اسم المؤسسة",
        "fieldType": "text",
        "required": true,
        "order": 1
      },
      {
        "userTypeId": "contractor",
        "fieldName": "trade_register",
        "fieldLabel": "رقم السجل التجاري",
        "fieldType": "text",
        "required": true,
        "order": 2
      },
      {
        "userTypeId": "contractor",
        "fieldName": "tax_number",
        "fieldLabel": "رقم التعريف الجبائي",
        "fieldType": "text",
        "required": true,
        "order": 3
      },
      {
        "userTypeId": "contractor",
        "fieldName": "contractor_category",
        "fieldLabel": "التخصص",
        "fieldType": "select",
        "dataSource": "contractor_categories",
        "required": true,
        "order": 4
      },
      {
        "userTypeId": "contractor",
        "fieldName": "contractor_class",
        "fieldLabel": "الصنف",
        "fieldType": "select",
        "dataSource": "contractor_classes",
        "required": true,
        "order": 5
      },
      {
        "userTypeId": "contractor",
        "fieldName": "trade_reg_file",
        "fieldLabel": "السجل التجاري",
        "fieldType": "file",
        "fileTypeFilter": "pdf_image",
        "required": false,
        "order": 6
      },
      {
        "userTypeId": "contractor",
        "fieldName": "classification_cert",
        "fieldLabel": "شهادة التصنيف",
        "fieldType": "file",
        "fileTypeFilter": "pdf_image",
        "required": false,
        "order": 7
      },
      {
        "userTypeId": "contractor",
        "fieldName": "tax_card",
        "fieldLabel": "البطاقة الجبائية",
        "fieldType": "file",
        "fileTypeFilter": "pdf_image",
        "required": false,
        "order": 8
      }
    ];
    for (var item in data) {
      final id = "${item['userTypeId']}_${item['fieldName']}";
      await _db.collection('dynamic_fields').doc(id).set(item, SetOptions(merge: true));
    }
    print('Dynamic fields seeded.');
  }

  static Future<void> seedNews() async {
    final data = [
      {
        "title": "إطلاق النسخة التجريبية للمنصة",
        "content": "تم إطلاق النسخة الأولى من المنصة بنجاح.",
        "isPublished": true,
        "createdAt": FieldValue.serverTimestamp()
      },
      {
        "title": "فتح التسجيل للمقاولين",
        "content": "يمكن الآن للمقاولين التسجيل وإرسال ملفاتهم.",
        "isPublished": true,
        "createdAt": FieldValue.serverTimestamp()
      },
      {
        "title": "إضافة فئة المستثمرين",
        "content": "تمت إضافة المستثمرين وأصحاب رؤوس الأموال للمنصة.",
        "isPublished": true,
        "createdAt": FieldValue.serverTimestamp()
      }
    ];
    for (var item in data) {
      // Use title as document ID to prevent duplicate news entries during re-seeding
      final id = (item['title'] as String).replaceAll(' ', '_');
      await _db.collection('news').doc(id).set(item, SetOptions(merge: true));
    }
    print('News seeded.');
  }

  static Future<void> seedAppSettings() async {
    final data = {
      "appName": "منصة إدارة وثائق المقاولين",
      "appVersion": "1.0.0",
      "maintenanceMode": false,
      "supportPhone": "0555555555",
      "supportEmail": "support@example.com"
    };
    await _db.collection('config').doc('app_settings').set(data, SetOptions(merge: true));
    print('App settings seeded.');
  }

  static Future<void> seedAdminUser() async {
    final data = {
      "firstName": "Admin",
      "lastName": "System",
      "email": "admin@test.com",
      "phone": "0555555555",
      "userTypeId": "admin",
      "status": "approved",
      "profileCompleted": true,
      "role": "admin",
      "createdAt": FieldValue.serverTimestamp()
    };
    await _db.collection('users').doc('admin_system_id').set(data, SetOptions(merge: true));
    print('Admin user seeded.');
  }
}
