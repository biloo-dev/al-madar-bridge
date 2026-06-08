import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/BuildButton.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/screens/widgets/BuildHeader.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CraftsmanRegScreen extends StatefulWidget {
  const CraftsmanRegScreen({super.key});

  @override
  State<CraftsmanRegScreen> createState() => _CraftsmanRegScreenState();
}

class _CraftsmanRegScreenState extends State<CraftsmanRegScreen> {
  final _experienceController = TextEditingController();
  final _dayRateController = TextEditingController();
  final _descController = TextEditingController();
  final DataController _dataController = Get.find<DataController>();
  final AuthController _authController = Get.find<AuthController>();

  String? _selectedCraft;

  @override
  void initState() {
    super.initState();
    // Pre-fill
    final data = PrefManager.customProfileData;
    if (data.isNotEmpty) {
      _experienceController.text = data["experienceYears"] ?? "";
      _dayRateController.text = data["dayRate"] ?? "";
      _descController.text = data["description"] ?? "";
      _selectedCraft = data["selectedCraft"];
    }

    if (_selectedCraft == null && _dataController.craftsmanCategories.isNotEmpty) {
      _selectedCraft = _dataController.craftsmanCategories[0];
    }
  }

  void _save() async {
    if (_experienceController.text.isNotEmpty &&
        _dayRateController.text.isNotEmpty) {
      final data = {
        "selectedCraft": _selectedCraft ?? "",
        "experienceYears": _experienceController.text,
        "dayRate": _dayRateController.text,
        "description": _descController.text,
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
    final theme = Theme.of(context);

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              children: [
                BuildHeader(
                  icon: Icons.handyman,

                  title: "التسجيل المهني للحرفي",

                  subtitle: "أكمل معلوماتك المهنية",
                ),

                BuildCard(
                  children: [
                    Obx(() => DropdownButtonFormField<String>(
                      value: _selectedCraft,

                      decoration: const InputDecoration(
                        hintText: "التخصص المهني",

                        prefixIcon: Icon(Icons.build),
                      ),

                      items: _dataController.craftsmanCategories.map((craft) {
                        return DropdownMenuItem(
                          value: craft,

                          child: Text(craft),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() {
                          _selectedCraft = value!;
                        });
                      },
                      validator: (v) => v == null ? "مطلوب" : null,
                    )),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _experienceController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        hintText: "سنوات الخبرة",

                        prefixIcon: Icon(Icons.work_outline),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _dayRateController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        hintText: "السعر اليومي (دج)",

                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      controller: _descController,

                      minLines: 4,

                      maxLines: 6,

                      decoration: const InputDecoration(
                        hintText: "وصف مختصر عن الخبرات والأعمال السابقة",

                        alignLabelWithHint: true,

                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 80),

                          child: Icon(Icons.description),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: AppTheme.lightSurface,

                        borderRadius: BorderRadius.circular(18),
                      ),

                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryBlueLight,

                            child: const Icon(
                              Icons.verified_user,

                              color: AppTheme.primaryBlue,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Text(
                              "سيتم استخدام هذه المعلومات لإنشاء ملفك المهني",

                              style: TextStyle(color: AppTheme.textMedium),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        width: double.infinity,

        height: 56,

        child: BuildButton(text: "إكمال التسجيل", onTap: _save),
      ),
    );
  }
}
