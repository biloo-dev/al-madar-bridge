import 'dart:developer';
import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/screens/widgets/gender_selection_field.dart';
import 'package:al_madar_bridge/screens/widgets/searchable_dropdown_field.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'archive_tab.dart'; // Import to use logic or widget

class ProfileEditTab extends StatefulWidget {
  const ProfileEditTab({super.key});

  @override
  State<ProfileEditTab> createState() => _ProfileEditTabState();
}

class _ProfileEditTabState extends State<ProfileEditTab> with SingleTickerProviderStateMixin {
  final _personalFormKey = GlobalKey<FormState>();
  final _technicalFormKey = GlobalKey<FormState>();
  final DataController _dataController = Get.find<DataController>();
  final AuthController _authController = Get.find<AuthController>();
  late TabController _innerTabController;

  final RxMap<String, dynamic> _fieldValues = <String, dynamic>{}.obs;
  final RxMap<String, List<dynamic>> _fieldOptions = <String, List<dynamic>>{}.obs;
  final RxMap<String, bool> _fieldLoading = <String, bool>{}.obs;

  @override
  void initState() {
    super.initState();
    _innerTabController = TabController(length: 3, vsync: this);
    _loadCurrentData();
  }

  @override
  void dispose() {
    _innerTabController.dispose();
    super.dispose();
  }

  void _loadCurrentData() {
    _fieldValues.clear();
    _fieldValues['firstName'] = PrefManager.userFirstName;
    _fieldValues['lastName'] = PrefManager.userLastName;
    _fieldValues['phone'] = PrefManager.userPhone;
    _fieldValues['address'] = PrefManager.userAddress;
    _fieldValues['wilayaId'] = PrefManager.wilayaId;
    _fieldValues['communeId'] = PrefManager.communeId;
    _fieldValues.addAll(PrefManager.customProfileData);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _dataController.fetchWilayas();
      if (PrefManager.userType.isNotEmpty) {
        await _dataController.fetchDynamicFields("${PrefManager.userType}_fields");
      }
      if (_fieldValues['wilayaId'] != null && _fieldValues['wilayaId'].toString().isNotEmpty) {
        _fetchFieldCommunes('communeId', _fieldValues['wilayaId'].toString());
      }
    });
  }

  Future<void> _fetchFieldCommunes(String fieldName, String wilayaId) async {
    _fieldLoading[fieldName] = true;
    try {
      final list = await _dataController.getCommunesForWilaya(wilayaId);
      _fieldOptions[fieldName] = list;
    } catch (e) {
      log("Error fetching communes: $e");
    } finally {
      _fieldLoading[fieldName] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _innerTabController,
            children: [
              Form(key: _personalFormKey, child: _buildPersonalInfoTab()),
              Form(key: _technicalFormKey, child: _buildTechnicalInfoTab()),
              const ArchiveTab(), // Reusing the ArchiveTab as "My Files"
            ],
          ),
        ),
        // Save button only for the first two tabs
        AnimatedBuilder(
          animation: _innerTabController,
          builder: (context, child) {
            if (_innerTabController.index == 2) return const SizedBox.shrink();
            return _buildSaveButton();
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.white,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
            child: Text(
              PrefManager.userFirstName.isNotEmpty ? PrefManager.userFirstName[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 8),
          Text("${PrefManager.userFirstName} ${PrefManager.userLastName}", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TabBar(
        controller: _innerTabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.primaryBlue,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade700,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        tabs: const [
          Tab(text: "البيانات الشخصية"),
          Tab(text: "البيانات المهنية"),
          Tab(text: "ملفاتي"),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BuildCard(
          children: [
            _buildTextField("firstName", "الاسم", Icons.person_outline),
            _buildTextField("lastName", "اللقب", Icons.person_outline),
            _buildTextField("phone", "رقم الهاتف", Icons.phone_android, isPhone: true),
            _buildTextField("address", "العنوان", Icons.location_on_outlined),
            _buildRootLocationFields(),
          ],
        ),
      ],
    );
  }

  Widget _buildTechnicalInfoTab() {
    return Obx(() {
      final fields = _dataController.dynamicFields
          .where((f) => f['fieldType'] != 'file' && f['fieldType'] != 'multi_file')
          .toList();
      fields.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));

      if (_dataController.isLoading.value && fields.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BuildCard(
            children: fields.map((f) => _buildField(f)).toList(),
          ),
        ],
      );
    });
  }

  Widget _buildSaveButton() {
    return Obx(() => Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _authController.isLoading.value ? null : _updateProfile,
          icon: _authController.isLoading.value 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save_outlined, size: 20),
          label: const Text("حفظ التعديلات", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    ));
  }

  Widget _buildTextField(String key, String label, IconData icon, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: _fieldValues[key]?.toString(),
        key: ValueKey("prof_$key"),
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        onChanged: (v) => _fieldValues[key] = v,
        validator: (v) => (v == null || v.isEmpty) ? "مطلوب" : null,
      ),
    );
  }

  Widget _buildRootLocationFields() {
    return Column(
      children: [
        SearchableDropdownField(
          label: "الولاية",
          icon: Icons.map_outlined,
          items: _dataController.wilayas,
          selectedValue: _fieldValues['wilayaId'],
          onChanged: (v) {
            _fieldValues['wilayaId'] = v;
            _fieldValues['communeId'] = null;
            _fetchFieldCommunes('communeId', v.toString());
          },
        ),
        Obx(() => SearchableDropdownField(
          label: "البلدية",
          icon: Icons.location_city_outlined,
          items: _fieldOptions['communeId'] ?? [],
          selectedValue: _fieldValues['communeId'],
          isLoading: _fieldLoading['communeId'] == true,
          onChanged: (v) => _fieldValues['communeId'] = v,
        )),
      ],
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    final String type = field['fieldType'] ?? 'text';
    final String name = field['fieldName'] ?? '';
    final String label = field['fieldLabel_ar'] ?? field['fieldLabel'] ?? '';
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
        return _buildTextField(name, label, Icons.edit_note);
      case 'select':
        return _buildSelectField(field);
      case 'multi_select':
        return _buildMultiSelect(field);
      case 'boolean':
        return SwitchListTile(
          title: Text(label),
          value: _fieldValues[name] ?? false,
          onChanged: (v) => setState(() => _fieldValues[name] = v),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSelectField(Map<String, dynamic> field) {
    final String name = field['fieldName'];
    final String label = field['fieldLabel_ar'] ?? field['fieldLabel'] ?? '';
    final String dataSource = field['dataSource'] ?? '';

    return Obx(() {
      return SearchableDropdownField(
        label: label,
        icon: Icons.list_alt,
        items: _getOptionsFromSource(dataSource, name),
        selectedValue: _fieldValues[name],
        isLoading: (dataSource.contains('commune')) && _fieldLoading[name] == true,
        onChanged: (v) => _onDropdownChanged(dataSource, name, v),
      );
    });
  }

  Widget _buildMultiSelect(Map<String, dynamic> field) {
    final name = field['fieldName'];
    final label = field['fieldLabel_ar'] ?? field['fieldLabel'] ?? '';
    final source = field['dataSource'] ?? '';

    return Obx(() {
      return SearchableDropdownField(
        label: label,
        icon: Icons.checklist_rtl,
        items: _getOptionsFromSource(source, name),
        selectedValue: _fieldValues[name],
        isMultiSelect: true,
        onChanged: (v) {
          _fieldValues[name] = v;
          _fieldValues.refresh();
        },
      );
    });
  }

  void _onDropdownChanged(String dataSource, String name, dynamic value) async {
    _fieldValues[name] = value;
    if (dataSource.contains('wilaya')) {
      String? communeFieldName;
      for (var f in _dataController.dynamicFields) {
        if (f['dataSource'].toString().contains('commune')) {
          communeFieldName = f['fieldName'];
          break;
        }
      }
      if (communeFieldName != null) {
        _fieldValues[communeFieldName] = null;
        await _fetchFieldCommunes(communeFieldName, value.toString());
      }
    }
  }

  List<dynamic> _getOptionsFromSource(String source, String fieldName) {
    final String s = source.toLowerCase();
    switch (s) {
      case 'contractorcategories': return _dataController.contractorCategories;
      case 'contractorclasses': return _dataController.contractorClasses;
      case 'wilaya':
      case 'wilayas': return _dataController.wilayas;
      case 'commune':
      case 'communes': return _fieldOptions[fieldName] ?? [];
      case 'investmenttypes': return _dataController.investmentTypes;
      case 'crafts': return _dataController.crafts;
      case 'suppliercategories': return _dataController.supplierCategories;
      case 'genders': return _dataController.genders;
      case 'educationlevels': return _dataController.educationLevels;
      case 'deplomedtp': return _dataController.deplomeDTPData;
      case 'skills': return _dataController.skills;
      case 'availabilities': return _dataController.availabilities;
      case 'languages': return _dataController.languages;
      case 'salaryranges': return _dataController.salaryRanges;
      case 'drivinglicensetypes': return _dataController.drivingLicenseTypes;
      case 'metiers': return _dataController.metiers;
      case 'equipments': return _dataController.equipments;
      case 'equipmentcategories': return _dataController.equipmentCategories;
      case 'equipmenttransactiontypes': return _dataController.equipmentTransactionTypes;
      case 'equipmentconditions': return _dataController.equipmentConditions;
      case 'worklocationtypes': return _dataController.workLocationTypes;
      case 'investmentbudgetranges': return _dataController.investmentBudgetRanges;
      case 'investmentdurations': return _dataController.investmentDurations;
      case 'returntypes': return _dataController.returnTypes;
      case 'risklevels': return _dataController.riskLevels;
      case 'offertypes': return _dataController.offerTypes;
      case 'suppliersubcategories': return _dataController.supplierSubcategories;
      default: return [];
    }
  }

  Future<void> _updateProfile() async {
    final bool isPersonalValid = _personalFormKey.currentState?.validate() ?? true;
    final bool isTechnicalValid = _technicalFormKey.currentState?.validate() ?? true;

    if (isPersonalValid && isTechnicalValid) {
      Map<String, dynamic> rootData = {
        'firstName': _fieldValues['firstName'],
        'lastName': _fieldValues['lastName'],
        'phone': _fieldValues['phone'],
        'address': _fieldValues['address'],
        'wilayaId': _fieldValues['wilayaId'],
        'communeId': _fieldValues['communeId'],
      };
      Map<String, dynamic> extraData = Map.from(_fieldValues);
      rootData.forEach((key, value) => extraData.remove(key));
      extraData['__root__'] = rootData;

      bool success = await _authController.updateProfile(data: extraData, isCompleted: true);
      if (success) {
        Get.snackbar("تم الحفظ", "تم تحديث بياناتك بنجاح", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar("خطأ", "فشل الحفظ، يرجى المحاولة لاحقاً", backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }
}
