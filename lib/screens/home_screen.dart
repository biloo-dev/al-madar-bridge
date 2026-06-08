import 'dart:io';
import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/services/firestore_seeder.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  final AuthController _authController = Get.find<AuthController>();
  final DataController _dataController = Get.find<DataController>();
  final ImagePicker _picker = ImagePicker();

  // Track uploading state for the Archive tab
  final Map<String, bool> _archiveUploading = {};

  final Map<String, String> _fieldLabels = {
    "companyName": "اسم المؤسسة",
    "registerNum": "رقم السجل التجاري",
    "taxId": "رقم التعريف الجبائي",
    "address": "العنوان",
    "specialty": "التخصص",
    "class": "الصنف",
    "supplierName": "اسم النشاط",
    "description": "الوصف",
    "parentCategory": "الفئة الرئيسية",
    "subcategories": "الفئات الفرعية",
    "selectedCraft": "الحرفة",
    "experienceYears": "سنوات الخبرة",
    "dayRate": "السعر اليومي (دج)",
    "investorType": "نوع الاستثمار",
    "investmentValue": "الميزانية",
    "targetWilayas": "الولايات المستهدفة",
    "equipmentType": "نوع العتاد",
    "serviceType": "نوع الخدمة",
    "pricingRate": "السعر (دج)",
  };

  final List<String> _notifications = [
    "الديوان الولائي لرقابة الصفقات: حالة ملفك قيد المراجعة الفورية",
    "تحديث جديد: صدر المجهود الفني المطلوب لمطابقة أشغال الصنف 3",
    "تمت إضافة وثيقة 'البطاقة الجبائية.pdf' وحفظها بالأرشيف الرقمي الموحد",
  ];

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "مركز التنبيهات والإشعارات العاجلة",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ..._notifications.map(
                (notif) => ListTile(
                  leading: const Icon(
                    Icons.circle,
                    size: 8,
                    color: AppTheme.accentOrange,
                  ),
                  title: Text(notif, style: const TextStyle(fontSize: 13)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حول المنصة والرقابة"),
        content: const Text(
          "تم تصميم هذه المنصة الموحدة لتخزين ورقمنة وثائق المطابقة الرسمية للمقاولين والموردين المعتمدين والمستثمرين لضمان تكافؤ الفرص في عقود الأداء الإعماري بالجزائر.\n\nالإصدار: GetX M3",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Refresh data when home screen opens to ensure Auth session is caught
    _dataController.fetchInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: _showNotificationsSheet,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                "${PrefManager.userFirstName} ${PrefManager.userLastName}",
              ),
              accountEmail: Text(PrefManager.userEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppTheme.primaryBlueLight,
                child: Text(
                  PrefManager.userFirstName.isNotEmpty
                      ? PrefManager.userFirstName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              decoration: const BoxDecoration(color: AppTheme.primaryBlue),
            ),
            ListTile(
              leading: const Icon(Icons.sync, color: Colors.black87),
              title: const Text(
                "تحديث البيانات الأساسية",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                await FirestoreSeeder.seedAll();
                await _authController.fetchUserProfile();
                await _dataController.fetchInitialData();
                setState(() {});
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "تسجيل الخروج",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _authController.logout(),
            ),
          ],
        ),
      ),
      body: _buildSelectedTabBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (idx) {
          setState(() => _currentTab = idx);
          // Auto-refresh data when switching tabs
          if (idx == 0) _dataController.fetchNews();
          if (idx == 1) _dataController.fetchInitialData(); // Refresh profile/fields
          if (idx == 2) _dataController.fetchUserFiles();
          if (idx == 3) _dataController.fetchNews();
        },
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "ملفاتي"),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared),
            label: "الأرشيف",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: "المستجدات",
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    if (_currentTab == 0) {
      return Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryBlueLight,
            radius: 17,
            child: Text(
              PrefManager.userFirstName.isNotEmpty
                  ? PrefManager.userFirstName[0]
                  : 'U',
              style: const TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "مرحباً بك،",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                "${PrefManager.userFirstName} ${PrefManager.userLastName}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    }
    return Text(
      _currentTab == 1
          ? "ملفاتي وتفاصيل النشاط"
          : _currentTab == 2
          ? "أرشيف المستندات"
          : "الأخبار والمناقصات",
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSelectedTabBody() {
    switch (_currentTab) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildProfileTab();
      case 2:
        return _buildFilesTab();
      case 3:
        return _buildNewsTab();
      default:
        return const Center(child: Text("غير متوفر"));
    }
  }

  Widget _buildHomeTab() {
    final status = PrefManager.userStatus;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppTheme.primaryBlueLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppTheme.primaryBlue),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "حالة تدقيق الحساب",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryBlueDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == "approved"
                                  ? const Color(0xFFE7F7ED)
                                  : AppTheme.accentOrangeLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status == "approved"
                                  ? "نشط ومعتمد"
                                  : "موافقة معلقة",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: status == "approved"
                                    ? const Color(0xFF0E6B35)
                                    : AppTheme.accentOrangeDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        status == "approved"
                            ? "تم التحقق الفوري والموافقة على كافة الأوراق الثبوتية بالمنصة."
                            : "تصفح ومطابقة وثائق المقاول جارية من قبل مكتب التدقيق والتربية الفنية الفرعية.",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryBlueDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  backgroundColor: Colors.white54,
                  child: Icon(Icons.gavel, color: AppTheme.accentOrange),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "إحصائيات المتابعة الفنية للمطابقة",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppTheme.borderGray),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "المستندات المودعة بالأرشيف",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          "${_dataController.userFiles.length} مستندات",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => LinearProgressIndicator(
                          value: _dataController.userFiles.isEmpty ? 0.0 : 1.0,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppTheme.borderGray),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "المناقصات المفتوحة فورا",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "مشاريع 2",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlueLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "مفتوح فوري",
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.primaryBlueDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "روابط الخدمات السريعة وحلقات الجودة",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),
        _buildUtilityRow(
          "تحميل كتالوج وضوابط الجودة الفنية",
          "دليل ومقاييس البناء والري الجاري به العمل",
          Icons.menu_book,
        ),
        const SizedBox(height: 8),
        _buildUtilityRow(
          "مراجعة ميثاق النزاهة وكشف الجريدة الفنية ولاية",
          "مبادئ وعقود الرقابة ومحاربة الاحتكار والفساد",
          Icons.verified_user,
        ),
      ],
    );
  }

  Widget _buildUtilityRow(String t, String d, IconData i) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlueLight,
          child: Icon(i, color: AppTheme.primaryBlue, size: 20),
        ),
        title: Text(
          t,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          d,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildProfileTab() {
    final extraData = PrefManager.customProfileData;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: AppTheme.primaryBlue,
                child: Text(
                  PrefManager.userFirstName.isNotEmpty
                      ? PrefManager.userFirstName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "${PrefManager.userFirstName} ${PrefManager.userLastName}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                PrefManager.userEmail,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _buildSectionTitle("المعلومات الأساسية"),
        _buildInfoTile(
          Icons.person_pin,
          "الاسم الكامل",
          "${PrefManager.userFirstName} ${PrefManager.userLastName}",
        ),
        _buildInfoTile(Icons.phone, "رقم الهاتف ", PrefManager.userPhone),
        _buildInfoTile(
          Icons.badge_outlined,
          "نوع الحساب",
          _getArabicUserType(PrefManager.userType),
        ),

        const SizedBox(height: 20),
        if (extraData.isNotEmpty) ...[
          _buildSectionTitle("تفاصيل النشاط والتسجيل"),
          ...extraData.entries.map((entry) {
            final label = _fieldLabels[entry.key] ?? entry.key;
            String value = entry.value.toString();
            if (entry.value is List) {
              value = (entry.value as List).join(", ");
            }
            return _buildInfoTile(Icons.info_outline, label, value);
          }).toList(),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  String _getArabicUserType(String type) {
    switch (type) {
      case 'contractor':
        return 'مقاول';
      case 'supplier':
        return 'مورد سلع وخدمات';
      case 'craftsman':
        return 'صاحب حرفة';
      case 'investor':
        return 'مستثمر';
      case 'equipment_owner':
        return 'صاحب عتاد وآلات';
      default:
        return type;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  void _openFile(UserFileDocument file) async {
    final ext = file.fileExtension.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(ext)) {
      // Show Image in Dialog
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  file.fileCategory,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.open_in_browser,
                      color: AppTheme.primaryBlue,
                    ),
                    onPressed: () => _launchURL(file.fileUrl),
                  ),
                ],
              ),
              Flexible(
                child: Container(
                  color: Colors.black,
                  child: Image.network(
                    file.fileUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          "فشل تحميل الصورة",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (ext == 'pdf') {
      // Show PDF using flutter_cached_pdfview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(file.fileCategory),
              actions: [
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () => _launchURL(file.fileUrl),
                ),
              ],
            ),
            body: const PDF().cachedFromUrl(
              file.fileUrl,
              placeholder: (progress) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text('جاري التحميل... $progress%'),
                  ],
                ),
              ),
              errorWidget: (error) => Center(child: Text(error.toString())),
            ),
          ),
        ),
      );
    } else {
      // Open in Browser/System Viewer for Other
      _launchURL(file.fileUrl);
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      // On some Android versions, canLaunchUrl returns false but launchUrl works.
      // We attempt to launch directly with externalApplication mode.
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        throw "Could not launch";
      }
    } catch (e) {
      print("Error launching URL: $e");
      Get.snackbar(
        "خطأ",
        "لا يمكن فتح الملف. تأكد من وجود متصفح أو قارئ PDF مثبت.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _handleArchiveUpload(Map<String, dynamic> field, bool isOverride) async {
    if (isOverride) {
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("تأكيد الاستبدال"),
          content: Text("هل أنت متأكد من رغبتك في استبدال مستند '${field['fieldLabel']}' الحالي بمستند جديد؟"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("إلغاء")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("استبدال", style: TextStyle(color: Colors.red))),
          ],
        ),
      ) ?? false;
      if (!confirm) return;
    }

    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('الكاميرا'), onTap: () => Navigator.pop(context, 'camera')),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('المعرض'), onTap: () => Navigator.pop(context, 'gallery')),
            ListTile(leading: const Icon(Icons.picture_as_pdf), title: const Text('ملف PDF'), onTap: () => Navigator.pop(context, 'pdf')),
          ],
        ),
      ),
    );

    if (source == null) return;

    File? file;
    String? fileName;

    if (source == 'camera' || source == 'gallery') {
      final XFile? image = await _picker.pickImage(source: source == 'camera' ? ImageSource.camera : ImageSource.gallery);
      if (image != null) { file = File(image.path); fileName = image.name; }
    } else if (source == 'pdf') {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
      if (result != null) { file = File(result.files.single.path!); fileName = result.files.single.name; }
    }

    if (file != null && fileName != null) {
      final fieldName = field['fieldName'];
      setState(() => _archiveUploading[fieldName] = true);
      try {
        await _dataController.uploadFileWithMeta(file, fileName, field['fieldLabel'], fieldName);
        Get.snackbar("نجاح", "تم تحديث المستند بنجاح", snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar("خطأ", "فشل الرفع: $e", snackPosition: SnackPosition.BOTTOM);
      } finally {
        setState(() => _archiveUploading[fieldName] = false);
      }
    }
  }

  Widget _buildFilesTab() {
    return Obx(() {
      // Stay in loading state if currently fetching OR if slots (dynamicFields) haven't arrived yet
      if (_dataController.isLoading.value || (_dataController.dynamicFields.isEmpty && PrefManager.userType.isNotEmpty)) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("جاري جلب المستندات من الأرشيف...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      final fileFields = _dataController.dynamicFields.where((f) => f['fieldType'] == 'file').toList();
      
      if (fileFields.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_off, size: 60, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                "لا توجد متطلبات ملفات لهذا النوع من الحساب",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fileFields.length,
        itemBuilder: (context, idx) {
          final field = fileFields[idx];
          final fieldName = field['fieldName'];
          
          // Find uploaded file for this specific requirement using the label/fieldName
          final uploadedFile = _dataController.userFiles.firstWhereOrNull((f) => f.fileCategory == field['fieldLabel']);
          
          final isUploading = _archiveUploading[fieldName] ?? false;
          final hasFile = uploadedFile != null;
          final isImage = hasFile && ['jpg', 'jpeg', 'png'].contains(uploadedFile.fileExtension.toLowerCase());

          return Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    hasFile ? (isImage ? Icons.image : Icons.picture_as_pdf) : Icons.cloud_upload_outlined, 
                    color: hasFile ? (isImage ? Colors.blue : Colors.red) : Colors.grey, 
                    size: 32
                  ),
                  if (isUploading) const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              title: Text(
                field['fieldLabel'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? uploadedFile.fileName : "لم يتم الرفع بعد",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasFile) Text(
                    uploadedFile.status == "approved"
                        ? "تم التدقيق والمطابقة"
                        : "قيد المراجعة",
                    style: TextStyle(
                      fontSize: 11,
                      color: uploadedFile.status == "approved"
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasFile) IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                    onPressed: () => _openFile(uploadedFile),
                  ),
                  IconButton(
                    icon: Icon(hasFile ? Icons.refresh : Icons.add_circle_outline, color: AppTheme.primaryBlue, size: 20),
                    onPressed: isUploading ? null : () => _handleArchiveUpload(field, hasFile),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildNewsTab() {
    return Obx(() {
      if (_dataController.isLoading.value && _dataController.newsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (_dataController.newsList.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.newspaper, size: 60, color: Colors.grey),
              SizedBox(height: 12),
              Text("لا توجد أخبار أو مناقصات حالياً", style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dataController.newsList.length,
        itemBuilder: (context, idx) {
          final item = _dataController.newsList[idx];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.publishedBy,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item.publishedAt,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.content,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text("تفاصيل المناقصة"),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
