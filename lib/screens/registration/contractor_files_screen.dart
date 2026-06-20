import 'dart:io';

import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ContractorFilesScreen extends StatefulWidget {
  const ContractorFilesScreen({super.key});

  @override
  State<ContractorFilesScreen> createState() => _ContractorFilesScreenState();
}

class _ContractorFilesScreenState extends State<ContractorFilesScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final DataController _dataController = Get.find<DataController>();
  final ImagePicker _picker = ImagePicker();

  final Map<String, bool> _uploadedStates = {};

  @override
  void initState() {
    super.initState();
  }

  Color _getThemeColor() {
    final userType = _authController.registrationData['userType'] ?? PrefManager.userType;
    switch (userType.toLowerCase()) {
      case 'contractor':
        return const Color(0xFFD48D3B);
      case 'investor':
        return const Color(0xFF4CAF50);
      case 'equipment_owner':
        return const Color(0xFF2196F3);
      case 'supplier':
        return const Color(0xFF673AB7);
      case 'craftsman':
        return const Color(0xFFFFC107);
      default:
        return AppTheme.primaryBlue;
    }
  }

  String _getUserTypeImage() {
    final userType = _authController.registrationData['userType'] ?? PrefManager.userType;
    String id = userType.toLowerCase();
    if (id.isEmpty) id = 'contractor';
    return "assets/userType/$id.png";
  }

  Future<void> _handleUpload(Map<String, dynamic> field) async {
    final fieldName = field['fieldName'];
    final bool isMulti = field['fieldType'] == 'multi_file';

    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('التقاط صورة (كاميرا)'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(
                isMulti ? 'المعرض (اختيار صور متعددة)' : 'المعرض (صور)',
              ),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(
                isMulti ? 'ملفات PDF (اختيار متعدد)' : 'ملف PDF / مستندات',
              ),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    List<File> pickedFiles = [];

    if (source == 'camera') {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) pickedFiles.add(File(image.path));
    } else if (source == 'gallery') {
      if (isMulti) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
        if (result != null) {
          pickedFiles.addAll(
            result.paths.where((p) => p != null).map((p) => File(p!)),
          );
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) pickedFiles.add(File(image.path));
      }
    } else if (source == 'pdf') {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: isMulti,
      );
      if (result != null) {
        pickedFiles.addAll(
          result.paths.where((p) => p != null).map((p) => File(p!)),
        );
      }
    }

    if (pickedFiles.isNotEmpty) {
      if (isMulti) {
        final List<File> currentFiles = List<File>.from(
          _authController.selectedFiles[fieldName] ?? [],
        );
        currentFiles.addAll(pickedFiles);
        _authController.selectedFiles[fieldName] = currentFiles;
      } else {
        _authController.selectedFiles[fieldName] = pickedFiles;
      }

      setState(() {
        _uploadedStates[fieldName] = true;
      });
    }
  }

  void _save() async {
    final fileFields = _dataController.dynamicFields.where(
      (f) =>
          (f['fieldType'] == 'file' || f['fieldType'] == 'multi_file') &&
          f['required'] == true,
    );

    final allFileFields = _dataController.dynamicFields.where(
      (f) => f['fieldType'] == 'file' || f['fieldType'] == 'multi_file',
    ).toList();

    if (allFileFields.isEmpty) {
      if (_dataController.isLoading.value) {
        Get.snackbar("تنبيه", "يرجى الانتظار حتى تحميل بيانات التسجيل");
      } else {
        final success = await _authController.registerFinal();
        if (success) {
          Get.offAllNamed('/verification_pending');
        } else {
          String error = _authController.generalError.value ?? "فشل إتمام التسجيل";
          Get.snackbar("خطأ", error);
        }
      }
      return;
    }

    bool allUploaded = fileFields.every(
      (f) => _authController.selectedFiles.containsKey(f['fieldName']),
    );

    if (allUploaded) {
      try {
        final success = await _authController.registerFinal();
        if (success) {
          Get.offAllNamed('/verification_pending');
        } else {
          String error = _authController.generalError.value ?? "فشل إتمام التسجيل";
          Get.snackbar("خطأ", error, backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
        }
      } catch (e) {
        print("Navigation/Auth Error: $e");
        Get.snackbar("خطأ تقني", "حدث خطأ غير متوقع: $e");
      }
    } else {
      Get.snackbar("تنبيه", "الرجاء اختيار كافة الوثائق المطلوبة المشار إليها بعلامة النجمة", 
          backgroundColor: Colors.orange.withOpacity(0.8), colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [themeColor.withOpacity(0.2), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final fileFields = _dataController.dynamicFields
                .where(
                  (f) =>
                      f['fieldType'] == 'file' ||
                      f['fieldType'] == 'multi_file',
                )
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back_ios, color: themeColor),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeColor.withOpacity(.12),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        _getUserTypeImage(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.upload,
                          size: 42,
                          color: themeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "رفع الوثائق",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "المرحلة الثالثة: إثبات الهوية والنشاط",
                    style: TextStyle(
                      color: AppTheme.textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  BuildCard(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "اختيار الوثائق المطلوبة",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (fileFields.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("لا توجد وثائق مطلوبة لهذا النوع"),
                          ),
                        )
                      else
                        ...fileFields.map(
                          (field) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildUploadCard(
                              field['fieldLabel_ar'] ??
                                  field['fieldLabel'] ??
                                  "",
                              _authController.selectedFiles.containsKey(
                                field['fieldName'],
                              ),
                              () => _handleUpload(field),
                              _authController
                                      .selectedFiles[field['fieldName']]
                                      ?.length ??
                                  0,
                              themeColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 34),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      floatingActionButton: Obx(
        () => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          height: 56,
          child: ElevatedButton(
            onPressed: _authController.isLoading.value ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
            ),
            child: _authController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "إكمال التسجيل النهائي",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildUploadCard(
    String label,
    bool uploaded,
    VoidCallback upload,
    int fileCount,
    Color themeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: themeColor.withOpacity(0.1),
            child: Icon(
              uploaded ? Icons.check : Icons.upload_file,
              color: themeColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  uploaded
                      ? "تم اختيار $fileCount ملفات"
                      : "PDF، صور، مستندات",
                  style: TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: upload,
            icon: Icon(
              uploaded ? Icons.refresh : Icons.cloud_upload,
              color: uploaded ? themeColor : AppTheme.accentOrange,
            ),
          ),
        ],
      ),
    );
  }
}
