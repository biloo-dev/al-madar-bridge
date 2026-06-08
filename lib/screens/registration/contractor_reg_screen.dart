import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/screens/widgets/BuildHeader.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';

class ContractorRegScreen extends StatefulWidget {
  const ContractorRegScreen({super.key});

  @override
  State<ContractorRegScreen> createState() => _ContractorRegScreenState();
}

class _ContractorRegScreenState extends State<ContractorRegScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _registerNumController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _addressController = TextEditingController();
  final DataController _dataController = Get.find<DataController>();
  final AuthController _authController = Get.find<AuthController>();

  String? _selectedSpecialty;
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    // Pre-fill if data exists (for resumption)
    final data = PrefManager.customProfileData;
    if (data.isNotEmpty) {
      _companyController.text = data["companyName"] ?? "";
      _registerNumController.text = data["registerNum"] ?? "";
      _taxIdController.text = data["taxId"] ?? "";
      _addressController.text = data["address"] ?? "";
      _selectedSpecialty = data["specialty"];
      _selectedClass = data["class"];
    }

    if (_selectedSpecialty == null && _dataController.contractorCategories.isNotEmpty) {
      _selectedSpecialty = _dataController.contractorCategories[0];
    }
    if (_selectedClass == null && _dataController.contractorClasses.isNotEmpty) {
      _selectedClass = _dataController.contractorClasses[0];
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "companyName": _companyController.text,
        "registerNum": _registerNumController.text,
        "taxId": _taxIdController.text,
        "address": _addressController.text,
        "specialty": _selectedSpecialty ?? "",
        "class": _selectedClass ?? "",
      };
      
      PrefManager.customProfileData = data;
      
      await _authController.updateProfile(
        data: data,
        nextStep: 'files',
      );

      Get.offAllNamed('/files_contractor');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "الرجاء استكمال البيانات ورفع كافة الوثائق اللازمة للتدقيق",
          ),
        ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              children: [
                BuildHeader(
                  icon: Icons.business,

                  title: "وثائق وتصنيف المقاول",

                  subtitle: "المرحلة الثانية من التسجيل",
                ),

                BuildCard(
                  children: [
                    Form(
                      key: _formKey,

                      child: Column(
                        children: [
                          TextFormField(
                            controller: _companyController,

                            decoration: const InputDecoration(
                              hintText: "اسم المؤسسة",

                              prefixIcon: Icon(Icons.business),
                            ),

                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "مطلوب";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          TextFormField(
                            controller: _registerNumController,

                            decoration: const InputDecoration(
                              hintText: "رقم السجل التجاري",

                              prefixIcon: Icon(Icons.tag),
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextFormField(
                            controller: _taxIdController,

                            decoration: const InputDecoration(
                              hintText: "رقم التعريف الجبائي",

                              prefixIcon: Icon(Icons.receipt_long),
                            ),
                          ),

                          const SizedBox(height: 18),

                          TextFormField(
                            controller: _addressController,

                            decoration: const InputDecoration(
                              hintText: "العنوان",

                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Obx(() => DropdownButtonFormField<String>(
                            value: _selectedSpecialty,

                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.build),

                              hintText: "التخصص",
                            ),

                            items: _dataController.contractorCategories.map((e) {
                              return DropdownMenuItem(value: e, child: Text(e));
                            }).toList(),

                            onChanged: (value) {
                              setState(() {
                                _selectedSpecialty = value!;
                              });
                            },
                            validator: (v) => v == null ? "مطلوب" : null,
                          )),

                          const SizedBox(height: 18),

                          Obx(() => DropdownButtonFormField<String>(
                            value: _selectedClass,

                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.workspace_premium),

                              hintText: "الصنف",
                            ),

                            items: _dataController.contractorClasses.map((e) {
                              return DropdownMenuItem(value: e, child: Text(e));
                            }).toList(),

                            onChanged: (value) {
                              setState(() {
                                _selectedClass = value!;
                              });
                            },
                            validator: (v) => v == null ? "مطلوب" : null,
                          )),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        height: 56,

        child: ElevatedButton(
          onPressed: _save,

          child: Row(
            children: [
              const Text(
                " مرحلة رفع الملفات",

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Spacer(),
              Icon(Icons.navigate_next),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
