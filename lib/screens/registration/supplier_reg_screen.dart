import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/BuildButton.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/screens/widgets/BuildHeader.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupplierRegScreen extends StatefulWidget {
  const SupplierRegScreen({super.key});

  @override
  State<SupplierRegScreen> createState() => _SupplierRegScreenState();
}

class _SupplierRegScreenState extends State<SupplierRegScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final DataController _dataController = Get.find<DataController>();
  final AuthController _authController = Get.find<AuthController>();

  String? _selectedCategory;
  final List<String> _selectedSubs = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill
    final data = PrefManager.customProfileData;
    if (data.isNotEmpty) {
      _nameController.text = data["supplierName"] ?? "";
      _descController.text = data["description"] ?? "";
      _selectedCategory = data["parentCategory"];
      if (data["subcategories"] != null && data["subcategories"] is List) {
        _selectedSubs.addAll(List<String>.from(data["subcategories"]));
      }
    }

    if (_selectedCategory == null && _dataController.supplierCategories.isNotEmpty) {
      _selectedCategory = _dataController.supplierCategories[0]['name'];
    }
  }

  void _save() async {
    if (_nameController.text.isNotEmpty && _selectedCategory != null) {
      final data = {
        "supplierName": _nameController.text,
        "description": _descController.text,
        "parentCategory": _selectedCategory!,
        "subcategories": _selectedSubs,
      };
      
      PrefManager.customProfileData = data;
      
      await _authController.updateProfile(
        data: data,
        isCompleted: true,
        nextStep: 'completed',
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
            colors: [Color(0xFFD6EEF8), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                BuildHeader(
                  icon: Icons.store,
                  title: "الملف التجاري",
                  subtitle: "أكمل معلومات المورد",
                ),
                BuildCard(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: "اسم النشاط",
                        prefixIcon: Icon(Icons.store),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _descController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(hintText: "وصف النشاط"),
                    ),
                    const SizedBox(height: 24),
                    Obx(() => Wrap(
                      spacing: 8,
                      children: _dataController.supplierCategories.map((catData) {
                        final cat = catData['name'] as String;
                        final selected = _selectedCategory == cat;

                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          selectedColor: AppTheme.primaryBlueLight,
                          onSelected: (v) {
                            setState(() {
                              _selectedCategory = cat;
                              _selectedSubs.clear();
                            });
                          },
                        );
                      }).toList(),
                    )),
                    const SizedBox(height: 20),
                    Obx(() {
                      final filteredSubs = _dataController.supplierSubcategories
                          .where((sub) => sub['categoryName'] == _selectedCategory)
                          .toList();

                      if (filteredSubs.isEmpty) return const SizedBox.shrink();

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.lightSurface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: filteredSubs.map((subData) {
                            final sub = subData['name'] as String;
                            final checked = _selectedSubs.contains(sub);

                            return CheckboxListTile(
                              title: Text(sub),
                              value: checked,
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedSubs.add(sub);
                                  } else {
                                    _selectedSubs.remove(sub);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                    Obx(() => BuildButton(
                      text: "إكمال التسجيل", 
                      onTap: _authController.isLoading.value ? null : _save
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
