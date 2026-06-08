import 'package:al_madar_bridge/screens/widgets/BuildButton.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/screens/widgets/BuildHeader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/data_controller.dart';
import '../../services/pref_manager.dart';

class InvestorRegScreen extends StatefulWidget {
  const InvestorRegScreen({super.key});

  @override
  State<InvestorRegScreen> createState() => _InvestorRegScreenState();
}

class _InvestorRegScreenState extends State<InvestorRegScreen> {
  final _investmentValueController = TextEditingController();
  final _wilayasController = TextEditingController();
  final _descController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final DataController _dataController = Get.find<DataController>();

  String? _selectedType;

  @override
  void initState() {
    super.initState();
    // Pre-fill
    final data = PrefManager.customProfileData;
    if (data.isNotEmpty) {
      _investmentValueController.text = data["investmentValue"] ?? "";
      _wilayasController.text = data["targetWilayas"] ?? "";
      _descController.text = data["description"] ?? "";
      _selectedType = data["investorType"];
    }

    if (_selectedType == null && _dataController.investmentCategories.isNotEmpty) {
      _selectedType = _dataController.investmentCategories[0];
    }
  }

  void _save() async {
    if (_investmentValueController.text.isNotEmpty && _selectedType != null) {
      final data = {
        "investorType": _selectedType!,
        "investmentValue": _investmentValueController.text,
        "targetWilayas": _wilayasController.text,
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
                  icon: Icons.account_balance,
                  title: "الملف المالي",
                  subtitle: "أكمل معلومات الاستثمار",
                ),
                BuildCard(
                  children: [
                    Obx(() => DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        hintText: "نوع الاستثمار",
                        prefixIcon: Icon(Icons.trending_up),
                      ),
                      items: _dataController.investmentCategories
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedType = v!;
                        });
                      },
                      validator: (v) => v == null ? "مطلوب" : null,
                    )),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _investmentValueController,
                      decoration: const InputDecoration(
                        hintText: "الميزانية",
                        prefixIcon: Icon(Icons.payments),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _wilayasController,
                      decoration: const InputDecoration(
                        hintText: "الولايات المستهدفة",
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _descController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: "وصف الاستثمار",
                      ),
                    ),
                    const SizedBox(height: 32),
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
