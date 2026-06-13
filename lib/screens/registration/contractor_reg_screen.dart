import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/screens/widgets/BuildHeader.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContractorRegScreen extends StatefulWidget {
  const ContractorRegScreen({super.key});

  @override
  State<ContractorRegScreen> createState() => _ContractorRegScreenState();
}

class _ContractorRegScreenState extends State<ContractorRegScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataController _dataController = Get.find<DataController>();
  final AuthController _authController = Get.find<AuthController>();

  // Map to store dynamic field values
  final Map<String, dynamic> _fieldValues = {};

  @override
  void initState() {
    super.initState();
    // Fetch fields specifically for contractor type
    _dataController.fetchDynamicFields('contractor_fields');

    // Load existing data if any
    final existingData = PrefManager.customProfileData;
    _fieldValues.addAll(existingData);
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      // Save data locally and update Firestore
      PrefManager.customProfileData = _fieldValues;

      await _authController.updateProfile(
        data: _fieldValues,
        nextStep: 'files',
      );

      Get.offAllNamed('/files_contractor');
    } else {
      Get.snackbar(
        "تنبيه",
        "يرجى ملء جميع الحقول المطلوبة",
        snackPosition: SnackPosition.BOTTOM,
      );
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
            // Filter out file fields for this screen (they go to the next screen)
            final fields = _dataController.dynamicFields
                .where((f) => f['fieldType'] != 'file')
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  BuildHeader(
                    icon: Icons.business,
                    title: "بيانات المؤسسة",
                    subtitle: "المرحلة الثانية من التسجيل",
                  ),
                  BuildCard(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: fields
                              .map((field) => _buildDynamicField(field))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 30),
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "مرحلة رفع الوثائق",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(Icons.navigate_next),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDynamicField(Map<String, dynamic> field) {
    final String type = field['fieldType'];
    final String name = field['fieldName'];
    final String label = field['fieldLabel'];
    final bool isRequired = field['required'] ?? false;

    switch (type) {
      case 'text':
      case 'textarea':
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: TextFormField(
            initialValue: _fieldValues[name]?.toString(),
            maxLines: type == 'textarea' ? 3 : 1,
            decoration: InputDecoration(
              hintText: label,
              prefixIcon: const Icon(Icons.edit_note),
            ),
            onChanged: (v) => _fieldValues[name] = v,
            validator: (v) =>
                (isRequired && (v == null || v.isEmpty)) ? "مطلوب" : null,
          ),
        );
      case 'select':
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: _buildDropdownField(field),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDropdownField(Map<String, dynamic> field) {
    final String name = field['fieldName'];
    final String label = field['fieldLabel'];
    final String dataSource = field['dataSource'] ?? '';

    List<dynamic> items = [];
    if (dataSource == 'contractor_categories') {
      items = _dataController.contractorCategories;
    } else if (dataSource == 'contractor_classes') {
      items = _dataController.contractorClasses;
    }

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: _fieldValues[name],
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: const Icon(Icons.list),
      ),
      items: items.map((e) {
        String val = "";
        String text = "";
        if (e is String) {
          val = e;
          text = e;
        } else if (e is Map) {
          val = e['id'] ?? e['name'] ?? '';
          text = e['nameAr'] ?? e['name_ar'] ?? e['name'] ?? e['id'] ?? '';
        }
        return DropdownMenuItem<String>(
          value: val,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _fieldValues[name] = v),
      validator: (v) =>
          (field['required'] == true && v == null) ? "مطلوب" : null,
    );
  }
}
