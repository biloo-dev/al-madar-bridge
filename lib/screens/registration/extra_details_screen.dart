import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/screens/widgets/gender_selection_field.dart';
import 'package:al_madar_bridge/screens/widgets/searchable_dropdown_field.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExtraDetailsScreen extends StatefulWidget {
  const ExtraDetailsScreen({super.key});

  @override
  State<ExtraDetailsScreen> createState() => _ExtraDetailsScreenState();
}

class _ExtraDetailsScreenState extends State<ExtraDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataController _dataController = Get.find<DataController>();
  final AuthController _authController = Get.find<AuthController>();

  final Map<String, dynamic> _fieldValues = {};
  bool _isLoadingCommunes = false;

  @override
  void initState() {
    super.initState();
    _fieldValues.addAll(_authController.extraData);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFieldsAndCommunes();
    });
  }

  void _initFieldsAndCommunes() async {
    final userType =
        _authController.registrationData['userType'] ?? PrefManager.userType;
    if (userType.isNotEmpty) {
      await _dataController.fetchDynamicFields(userType);
    }

    String? wilayaFieldName;
    for (var f in _dataController.dynamicFields) {
      if (f['dataSource'] == 'wilaya' || f['dataSource'] == 'wilayas') {
        wilayaFieldName = f['fieldName'];
        break;
      }
    }

    if (wilayaFieldName != null) {
      final initialWilayaId = _fieldValues[wilayaFieldName];
      if (initialWilayaId != null) {
        setState(() => _isLoadingCommunes = true);
        await _dataController.fetchCommunes(initialWilayaId.toString());
        if (mounted) setState(() => _isLoadingCommunes = false);
      }
    }
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

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _authController.extraData.clear();
      _authController.extraData.addAll(_fieldValues);

      final bool hasFiles = _dataController.dynamicFields.any(
        (f) => f['fieldType'] == 'file' || f['fieldType'] == 'multi_file',
      );

      if (hasFiles) {
        Get.toNamed('/files_contractor');
      } else {
        final success = await _authController.registerFinal();
        if (success) {
          Get.offAllNamed('/verification_pending');
        } else {
          Get.snackbar("خطأ", "فشل التسجيل النهائي، يرجى المحاولة لاحقاً");
        }
      }
    } else {
      Get.snackbar(
        "تنبيه",
        "يرجى ملء الحقول المطلوبة",
        snackPosition: SnackPosition.BOTTOM,
      );
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
          child: SingleChildScrollView(
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
                        Icons.assignment_outlined,
                        size: 42,
                        color: themeColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "تفاصيل النشاط",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "المرحلة الثانية: معلومات إضافية",
                  style: TextStyle(
                    color: AppTheme.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Obx(() {
                  if (_dataController.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final fields = _dataController.dynamicFields
                      .where(
                        (f) =>
                            f['fieldType'] != 'file' &&
                            f['fieldType'] != 'multi_file',
                      )
                      .toList();
                  fields.sort(
                    (a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0),
                  );

                  if (fields.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          const Text("لا توجد حقول إضافية"),
                          TextButton(
                            onPressed: () {
                              final uType = _authController.registrationData['userType'] ?? PrefManager.userType;
                              if (uType.isNotEmpty) {
                                _dataController.fetchDynamicFields(uType);
                              }
                            },
                            child: const Text("إعادة المحاولة"),
                          ),
                        ],
                      ),
                    );
                  }

                  return BuildCard(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: fields
                              .map((field) => _buildField(field, themeColor))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "المتابعة لرفع الوثائق",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildField(Map<String, dynamic> field, Color themeColor) {
    final String type = field['fieldType'] ?? 'text';
    final String name = field['fieldName'] ?? '';
    final String label = field['fieldLabel_ar'] ?? field['fieldLabel'] ?? '';
    final bool isRequired = field['required'] ?? false;
    final String dataSource = field['dataSource'] ?? '';

    if (dataSource == 'genders') {
      return GenderSelectionField(
        label: label,
        items: _dataController.genders,
        selectedValue: _fieldValues[name],
        onChanged: (v) => setState(() => _fieldValues[name] = v),
      );
    }

    switch (type) {
      case 'text':
      case 'textarea':
      case 'number':
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: TextFormField(
            initialValue: _fieldValues[name]?.toString(),
            key: ValueKey(name),
            keyboardType: type == 'number'
                ? TextInputType.number
                : TextInputType.text,
            maxLines: type == 'textarea' ? 3 : 1,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(_getIcon(field['icon']), color: themeColor),
            ),
            onChanged: (v) => _fieldValues[name] = v,
            validator: (v) =>
                (isRequired && (v == null || v.isEmpty)) ? "مطلوب" : null,
          ),
        );
      case 'select':
      case 'radio':
      case 'radion':
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: _buildSelectField(field, themeColor),
        );
      case 'multi_select':
      case 'checkbox':
        return _buildMultiSelect(field, themeColor);
      case 'boolean':
        return SwitchListTile(
          title: Text(label),
          activeColor: themeColor,
          value: _fieldValues[name] ?? false,
          onChanged: (v) => setState(() => _fieldValues[name] = v),
        );
      case 'date':
        return _buildDatePicker(field, themeColor);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMultiSelect(Map<String, dynamic> field, Color themeColor) {
    final name = field['fieldName'] as String;
    final label = field['fieldLabel_ar'] ?? field['fieldLabel'] ?? '';
    final sourceKey = field['dataSource'] as String?;

    return SearchableDropdownField(
      label: label,
      icon: _getIcon(field['icon']),
      items: _getOptionsFromSource(sourceKey),
      isMultiSelect: true,
      selectedValue: _fieldValues[name] ?? [],
      onChanged: (v) => setState(() => _fieldValues[name] = v),
    );
  }

  Widget _buildSelectField(Map<String, dynamic> field, Color themeColor) {
    final String name = field['fieldName'];
    final String label = field['fieldLabel_ar'] ?? field['fieldLabel'] ?? '';
    final String dataSource = field['dataSource'] ?? '';

    String? hint;
    if (dataSource == 'supplierSubCategories' ||
        dataSource == 'supplierSubcategories') {
      bool parentSelected = false;
      for (var f in _dataController.dynamicFields) {
        if (f['dataSource'] == 'supplierCategories' &&
            _fieldValues[f['fieldName']] != null) {
          parentSelected = true;
          break;
        }
      }
      if (!parentSelected) hint = "يرجى اختيار الصنف الرئيسي أولاً";
    }

    return SearchableDropdownField(
      label: label,
      icon: _getIcon(field['icon']),
      items: _getOptionsFromSource(dataSource),
      selectedValue: _fieldValues[name],
      hint: hint ?? "",
      isLoading:
          (dataSource == 'commune' || dataSource == 'communes') &&
          _isLoadingCommunes,
      onChanged: (v) => _onDropdownChanged(dataSource, name, v),
    );
  }

  Widget _buildDatePicker(Map<String, dynamic> field, Color themeColor) {
    final name = field['fieldName'] as String;
    final label = field['fieldLabel_ar'] ?? field['fieldLabel'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: themeColor,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (date != null)
            setState(() => _fieldValues[name] = date.toIso8601String());
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(Icons.calendar_today, color: themeColor),
          ),
          child: Text(
            _fieldValues[name] != null
                ? "${DateTime.parse(_fieldValues[name]).day}/${DateTime.parse(_fieldValues[name]).month}/${DateTime.parse(_fieldValues[name]).year}"
                : "اختر التاريخ",
          ),
        ),
      ),
    );
  }

  List<dynamic> _getOptionsFromSource(String? source) {
    if (source == null) return [];
    switch (source) {
      case 'contractorCategories':
        return _dataController.contractorCategories;
      case 'contractorClasses':
        return _dataController.contractorClasses;
      case 'supplierCategories':
        return _dataController.supplierCategories;
      case 'supplierSubCategories':
      case 'supplierSubcategories':
        String? parentCatId;
        for (var f in _dataController.dynamicFields) {
          if (f['dataSource'] == 'supplierCategories') {
            parentCatId = _fieldValues[f['fieldName']]?.toString();
            break;
          }
        }
        if (parentCatId == null) return _dataController.supplierSubcategories;

        return _dataController.supplierSubcategories.where((sub) {
          final subCatId = (sub['categoryId'] ?? sub['category_id'])?.toString();
          return subCatId == parentCatId;
        }).toList();
      case 'genders':
        return _dataController.genders;
      case 'educationLevels':
        return _dataController.educationLevels;
      case 'crafts':
        return _dataController.crafts;
      case 'offerTypes':
        return _dataController.offerTypes;
      case 'equipments':
        return _dataController.equipments;
      case 'equipmentConditions':
        return _dataController.equipmentConditions;
      case 'deplomeDTP':
        return _dataController.deplomeDTPData;
      case 'investmentTypes':
        return _dataController.investmentTypes;
      case 'investmentBudgetRanges':
        return _dataController.investmentBudgetRanges;
      case 'investmentDurations':
        return _dataController.investmentDurations;
      case 'riskLevels':
        return _dataController.riskLevels;
      case 'returnTypes':
        return _dataController.returnTypes;
      case 'skills':
        return _dataController.skills;
      case 'availabilities':
        return _dataController.availabilities;
      case 'languages':
        return _dataController.languages;
      case 'salaryRanges':
        return _dataController.salaryRanges;
      case 'drivingLicenseTypes':
        return _dataController.drivingLicenseTypes;
      case 'wilaya':
      case 'wilayas':
        return _dataController.wilayas;
      case 'commune':
      case 'communes':
        return _dataController.communes;
      default:
        return [];
    }
  }

  void _onDropdownChanged(String dataSource, String name, dynamic value) async {
    setState(() => _fieldValues[name] = value);
    if (dataSource == 'wilaya' || dataSource == 'wilayas') {
      String? communeFieldName;
      for (var f in _dataController.dynamicFields) {
        if (f['dataSource'] == 'commune' || f['dataSource'] == 'communes') {
          communeFieldName = f['fieldName'];
          break;
        }
      }
      setState(() {
        if (communeFieldName != null) _fieldValues[communeFieldName] = null;
        _isLoadingCommunes = true;
      });
      if (value != null) await _dataController.fetchCommunes(value.toString());
      if (mounted) setState(() => _isLoadingCommunes = false);
    }
    if (dataSource == 'supplierCategories') {
      String? subCatFieldName;
      for (var f in _dataController.dynamicFields) {
        if (f['dataSource'] == 'supplierSubCategories' ||
            f['dataSource'] == 'supplierSubcategories') {
          subCatFieldName = f['fieldName'];
          break;
        }
      }
      if (subCatFieldName != null) {
        setState(() {
          _fieldValues[subCatFieldName ?? ""] = null;
        });
      }
    }
  }

  IconData _getIcon(String? iconName) {
    if (iconName == null) return Icons.edit;
    String name = iconName.toLowerCase();
    if (name.contains('apartment')) return Icons.apartment;
    if (name.contains('tune')) return Icons.tune;
    if (name.contains('bar_chart')) return Icons.bar_chart;
    if (name.contains('location')) return Icons.location_on;
    if (name.contains('business')) return Icons.business;
    if (name.contains('school')) return Icons.school;
    if (name.contains('construction')) return Icons.construction;
    if (name.contains('receipt')) return Icons.receipt_long;
    if (name.contains('workspace')) return Icons.workspace_premium;
    if (name.contains('registre')) return Icons.badge;
    return Icons.edit;
  }
}
