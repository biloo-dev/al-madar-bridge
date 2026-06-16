import 'dart:io';

import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/screens/widgets/BuildHeader.dart';
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

  // Maps to track upload state for dynamic fields
  final Map<String, bool> _uploadedStates = {};
  final Map<String, bool> _uploadingStates = {};
  final Map<String, double> _uploadProgress = {};

  @override
  void initState() {
    super.initState();
    // Fetch fields specifically for contractor type
    //_dataController.fetchDynamicFields('contractor_fields');
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
        // استخدام FilePicker للصور المتعددة لأنه أفضل في دعم الاختيار المتعدد على أندرويد
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
        // إذا كان حقل متعدد، نقوم بإضافة الملفات الجديدة إلى القائمة الموجودة بدلاً من استبدالها
        final List<File> currentFiles = List<File>.from(
          _authController.selectedFiles[fieldName] ?? [],
        );
        currentFiles.addAll(pickedFiles);
        _authController.selectedFiles[fieldName] = currentFiles;
      } else {
        // إذا كان حقل فردي، نستبدل الملف
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
        Get.snackbar("تنبيه", "لا توجد ملفات مطلوبة لهذا النوع حالياً. يرجى التواصل مع الدعم.");
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD6EEF8), Colors.white],
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
                  BuildHeader(
                    icon: Icons.upload,
                    title: "رفع الوثائق",
                    subtitle: "المرحلة الثالثة: إثبات الهوية والنشاط",
                    showBackButton: true,
                  ),
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
                              false,
                              0.0,
                              () => _handleUpload(field),
                              _authController
                                      .selectedFiles[field['fieldName']]
                                      ?.length ??
                                  0,
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
            child: _authController.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "إكمال التسجيل النهائي",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    bool uploading,
    double progress,
    VoidCallback upload,
    int fileCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryBlueLight,
                child: Icon(
                  uploaded ? Icons.check : Icons.upload_file,
                  color: AppTheme.primaryBlue,
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
              uploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      onPressed: upload,
                      icon: Icon(
                        uploaded ? Icons.refresh : Icons.cloud_upload,
                        color: AppTheme.accentOrange,
                      ),
                    ),
            ],
          ),
          if (uploading) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(value: progress),
          ],
        ],
      ),
    );
  }
}
