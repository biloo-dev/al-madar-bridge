import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // معرفات التحكم بالحقول النصية المترابطة إدخالاً وتعديلاً
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _wilayaController;
  late TextEditingController _communeController;

  final _formKey = GlobalKey<FormState>();

  // الألوان الخاصة بثيم "Clean Utility / Minimal"
  final Color cleanBlue = const Color(0xFF005AC1);
  final Color cleanBlueLight = const Color(0xFFD7E3FF);
  final Color cleanBlueDark = const Color(0xFF001D36);
  final Color lavenderSecondary = const Color(0xFF6750A4);
  final Color lavenderContainer = const Color(0xFFE8DEF8);
  final Color lavenderBorder = const Color(0xFFD0BCFF);
  final Color lavenderDark = const Color(0xFF21005D);
  final Color greySurface = const Color(0xFFF3F3FA);
  final Color borderGray = const Color(0xFFE1E2E8);
  final Color charcoalDark = const Color(0xFF1A1C1E);
  final Color charcoalMedium = const Color(0xFF44474E);
  final Color statusGreenBg = const Color(0xFFC2EFD0);
  final Color statusGreenText = const Color(0xFF00210B);
  final Color tenderRedBg = const Color(0xFFFFD8E4);
  final Color tenderRedText = const Color(0xFF31111D);
  final Color accentTeal = const Color(0xFF006A6A);

  @override
  void initState() {
    super.initState();
    // بيانات افتراضية قابلة للتعديل والمزامنة
    _firstNameController = TextEditingController(text: "أحمد");
    _lastNameController = TextEditingController(text: "صالح");
    _phoneController = TextEditingController(text: "0550123456");
    _wilayaController = TextEditingController(text: "الجزائر");
    _communeController = TextEditingController(text: "باب الزوار");
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _wilayaController.dispose();
    _communeController.dispose();
    super.dispose();
  }

  // دالة تحويل رمز الحساب إلى لغة عربية مقروءة
  String getAccountTypeNameAr(String code) {
    switch (code) {
      case 'contractor':
        return "مقاول";
      case 'supplier':
        return "مورد سلع وخدمات";
      case 'craftsman':
        return "أصحاب الحرف";
      case 'investor':
        return "مستثمرون وأصحاب المال";
      case 'equipment_owner':
        return "أصحاب العتاد والآلات";
      default:
        return "غير محدد";
    }
  }

  // عرض نافذة بطاقة الانتساب الرقمية التفاعلية مع رمز QR مدمج
  void _showCertificateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            title: Row(
              children: [
                Icon(Icons.workspace_premium, color: lavenderSecondary),
                const SizedBox(width: 8),
                const Text(
                  "شهادة التوثيق والانتساب الولائي",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "الجمهورية الجزائرية الديمقراطية الشعبية\nديوان تدقيق وثائق ومستندات المقاولين والموردين",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: charcoalMedium,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // وعاء بيانات الشهادة (Certificate Mockup)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: greySurface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: lavenderBorder, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "بطاقة المقاول المعتمد رقم: ALG-8927-D",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: lavenderSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(color: borderGray),
                        const SizedBox(height: 8),
                        Text(
                          "الاسم الكامل: ${_firstNameController.text} ${_lastNameController.text}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: charcoalDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "نوع النشاط: ${getAccountTypeNameAr('contractor')}",
                          style: TextStyle(fontSize: 12, color: charcoalDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "الولاية: ${_wilayaController.text} ، البلدية: ${_communeController.text}",
                          style: TextStyle(fontSize: 12, color: charcoalMedium),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "مستوى التدقيق: مستوى ج (معتمد بالكامل)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: statusGreenText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // محاكاة رمز QR التفاعلي بصرياً
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderGray, width: 1.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2, size: 55, color: charcoalDark),
                          const SizedBox(height: 4),
                          Text(
                            "ممسوح ضوئياً ومؤمن",
                            style: TextStyle(
                              fontSize: 8,
                              color: charcoalMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "هذه الوثيقة رقمية ومصادق عليها من اللجنة الإدارية للمطابقة. يمكنك مشاركتها مع الموردين وأصحاب المشاريع والشركاء بشكل مباشر.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: charcoalMedium,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("إغلاق", style: TextStyle(color: charcoalMedium)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم حفظ بطاقة الانتساب كـ PDF بنجاح في جهازك!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cleanBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("حفظ الصورة (JPG)", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. ترويسة الحساب البصرية المطورة (Visual Profile Card)
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    side: BorderSide(color: borderGray, width: 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        // دائرة الاسم الرمزية الذكية مع تدرج لوني وبطاقة موثقة
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [cleanBlue, lavenderSecondary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _firstNameController.text.isNotEmpty &&
                                      _lastNameController.text.isNotEmpty
                                      ? "${_firstNameController.text[0]}${_lastNameController.text[0]}"
                                      : "م",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified,
                                color: cleanBlue,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${_firstNameController.text} ${_lastNameController.text}",
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: charcoalDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "ahmed.saleh@enterprise.dz",
                          style: TextStyle(fontSize: 13, color: charcoalMedium),
                        ),
                        const SizedBox(height: 14),
                        // رقعات التصنيف والحالة (Metadata Labels)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cleanBlueLight,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                "الحساب: ${getAccountTypeNameAr('contractor')}",
                                style: TextStyle(
                                  color: cleanBlueDark,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusGreenBg,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                "الهوية: موثقة",
                                style: TextStyle(
                                  color: statusGreenText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. الخدمات والشهادات الرقمية
                Text(
                  "الخدمات والشهادات الرقمية",
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: charcoalDark,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: borderGray, width: 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // بطاقة الخدمة الأولى: استخراج البطاقة الرقمية
                        InkWell(
                          onTap: _showCertificateDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: greySurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: lavenderContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.workspace_premium, color: lavenderSecondary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "استخراج بطاقة الانتساب الرقمية",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: charcoalDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "وثيقة رسمية مشفرة بـ QR تصديق للشركاء",
                                        style: TextStyle(fontSize: 11, color: charcoalMedium),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_left, color: charcoalMedium, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // بطاقة الخدمة الثانية: التزامن الفوري
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تم تنفيذ التدقيق والمزامنة السحابية المحدثة بنجاح!"),
                                backgroundColor: Color(0xFF005AC1),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: greySurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: cleanBlueLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.sync, color: cleanBlue),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "تحيين وتزامن سحابي فوري",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: charcoalDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "مزامنة الوثائق المصادق عليها مع الديوان الولائي",
                                        style: TextStyle(fontSize: 11, color: charcoalMedium),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_left, color: charcoalMedium, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. تعديل البيانات الشخصية
                Text(
                  "تحديث البيانات الشخصية",
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: charcoalDark,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(color: borderGray, width: 1.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // حقل الاسم
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: "الاسم الأول",
                            prefixIcon: Icon(Icons.person, color: cleanBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // حقل اللقب
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: "اللقب المعياري",
                            prefixIcon: Icon(Icons.person, color: cleanBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // رقم الهاتف
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "رقم الهاتف الفعال",
                            prefixIcon: Icon(Icons.phone, color: cleanBlue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ولاية / بلدية بتصميم Row مزدوج
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _wilayaController,
                                decoration: InputDecoration(
                                  labelText: "الولاية",
                                  prefixIcon: Icon(Icons.location_on, color: lavenderSecondary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _communeController,
                                decoration: InputDecoration(
                                  labelText: "البلدية",
                                  prefixIcon: Icon(Icons.location_on, color: lavenderSecondary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // زر الحفظ التفاعلي والبرمجي
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  // يقوم بحفظ التغييرات وإظهارها في الأقسام الأخرى
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "تم تحديث بيانات المعاملة ${_firstNameController.text} بنجاح!",
                                    ),
                                    backgroundColor: cleanBlue,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cleanBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              "حفظ التغييرات الأساسية",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}