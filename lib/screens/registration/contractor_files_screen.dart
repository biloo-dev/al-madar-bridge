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
    _dataController.fetchDynamicFields('contractor');
  }

  Future<void> _handleUpload(Map<String, dynamic> field) async {
    final fieldName = field['fieldName'];
    final fieldLabel = field['fieldLabel'];

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
              title: const Text('المعرض (صور)'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('ملف PDF / مستندات'),
              onTap: () => Navigator.pop(context, 'pdf'),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    File? file;
    String? fileName;

    if (source == 'camera' || source == 'gallery') {
      final XFile? image = await _picker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
      if (image != null) {
        file = File(image.path);
        fileName = image.name;
      }
    } else if (source == 'pdf') {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );
      if (result != null) {
        file = File(result.files.single.path!);
        fileName = result.files.single.name;
      }
    }

    if (file != null && fileName != null) {
      _startUpload(fieldName, file, fileName, fieldLabel);
    }
  }

  void _startUpload(
    String fieldName,
    File file,
    String name,
    String label,
  ) async {
    setState(() {
      _uploadingStates[fieldName] = true;
      _uploadProgress[fieldName] = 0.0;
    });

    try {
      // Real upload to Cloudinary & Metadata to Firestore
      final url = await _dataController.uploadFileWithMeta(file, name, label, fieldName);
      print('File uploaded to: $url');

      setState(() {
        _uploadingStates[fieldName] = false;
        _uploadedStates[fieldName] = true;
        _uploadProgress[fieldName] = 1.0;
      });
    } catch (e) {
      setState(() => _uploadingStates[fieldName] = false);
      Get.snackbar(
        "خطأ",
        "فشل رفع الملف: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _save() async {
    final requiredFields = _dataController.dynamicFields.where(
      (f) => f['fieldType'] == 'file' && f['required'] == true,
    );
    bool allRequiredUploaded = requiredFields.every(
      (f) => _uploadedStates[f['fieldName']] == true,
    );

    if (allRequiredUploaded) {
      // Collect names of all fields that were actually uploaded
      final uploadedFieldNames = _uploadedStates.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toList();

      await _authController.updateProfile(
        data: {'docsUploaded': uploadedFieldNames},
        isCompleted: true,
        nextStep: 'completed',
      );
      Get.offAllNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء رفع الوثائق المطلوبة (إلزامي)")),
      );
      Get.offAllNamed('/home');
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
                .where((f) => f['fieldType'] == 'file')
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  BuildHeader(
                    icon: Icons.upload,
                    title: "وثائق المقاول",
                    subtitle: "المرحلة الثالثة من التسجيل",
                  ),
                  BuildCard(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "رفع الوثائق المطلوبة",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (fileFields.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        ...fileFields.map(
                          (field) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildUploadCard(
                              field['fieldLabel'] +
                                  (field['required'] == true
                                      ? ""
                                      : " (اختياري)"),
                              _uploadedStates[field['fieldName']] ?? false,
                              _uploadingStates[field['fieldName']] ?? false,
                              _uploadProgress[field['fieldName']] ?? 0.0,
                              () => _handleUpload(field),
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
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        height: 56,
        child: ElevatedButton(
          onPressed: _save,
          child: const Text(
            "إكمال التسجيل النهائي",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      uploaded ? "تم الرفع بنجاح" : "PDF، صور، مستندات",
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
