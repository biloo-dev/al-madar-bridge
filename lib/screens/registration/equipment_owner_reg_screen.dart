import 'package:al_madar_bridge/screens/widgets/BuildButton.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/screens/widgets/BuildHeader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/data_controller.dart';
import '../../services/pref_manager.dart';

class EquipmentOwnerRegScreen extends StatefulWidget {
  const EquipmentOwnerRegScreen({super.key});

  @override
  State<EquipmentOwnerRegScreen> createState() =>
      _EquipmentOwnerRegScreenState();
}

class _EquipmentOwnerRegScreenState extends State<EquipmentOwnerRegScreen> {
  final _priceController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  final DataController _dataController = Get.find<DataController>();

  String? _selectedEquip;
  final List<String> _services = [
    "عرض كراء بالأيام",
    "صيغة البيع الحر",
    "كراء وبيان بيع معاً",
  ];
  late String _selectedService;

  @override
  void initState() {
    super.initState();
    // Pre-fill
    final data = PrefManager.customProfileData;
    if (data.isNotEmpty) {
      _priceController.text = data["pricingRate"] ?? "";
      _selectedEquip = data["equipmentType"];
      _selectedService = data["serviceType"] ?? _services[0];
    } else {
      _selectedService = _services[0];
    }

    if (_selectedEquip == null && _dataController.equipmentCategories.isNotEmpty) {
      _selectedEquip = _dataController.equipmentCategories[0];
    }
  }

  void _save() async {
    if (_priceController.text.isNotEmpty && _selectedEquip != null) {
      final data = {
        "equipmentType": _selectedEquip!,
        "serviceType": _selectedService,
        "pricingRate": _priceController.text,
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
                  icon: Icons.precision_manufacturing,
                  title: "ملف العتاد والآلات",
                  subtitle: "أكمل معلومات العتاد المتوفر",
                ),
                BuildCard(
                  children: [
                    Obx(() => DropdownButtonFormField<String>(
                      value: _selectedEquip,
                      decoration: const InputDecoration(
                        hintText: "نوع العتاد",
                        prefixIcon: Icon(Icons.construction),
                      ),
                      items: _dataController.equipmentCategories
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedEquip = v!;
                        });
                      },
                      validator: (v) => v == null ? "مطلوب" : null,
                    )),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: _selectedService,
                      decoration: const InputDecoration(
                        hintText: "نوع الخدمة",
                        prefixIcon: Icon(Icons.miscellaneous_services),
                      ),
                      items: _services
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedService = v!;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "السعر",
                        prefixIcon: Icon(Icons.payments),
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
