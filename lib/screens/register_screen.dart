import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart'
    show DataController;
import 'package:al_madar_bridge/screens/widgets/BuildHeader.dart';
import 'package:al_madar_bridge/screens/widgets/searchable_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthController _authController = Get.find<AuthController>();
  final DataController _dataController = Get.find<DataController>();

  String? _selectedWilayaId;
  String? _selectedCommuneId;
  String? _selectedUserTypeId;

  @override
  void initState() {
    super.initState();
    // Wilayas are fetched automatically in DataController.onInit()
    
    // Set initial user type from arguments if provided
    if (Get.arguments != null) {
      _selectedUserTypeId = Get.arguments.toString();
    }
  }

  void _next() {
    if (_formKey.currentState!.validate() &&
        _selectedUserTypeId != null &&
        _selectedWilayaId != null &&
        _selectedCommuneId != null) {
      // Save data to AuthController instead of creating account now
      _authController.registrationData.addAll({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'address': _addressController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'wilaya': _selectedWilayaId!,
        'commune': _selectedCommuneId!,
        'userType': _selectedUserTypeId!,
      });
      _authController.registrationPassword = _passwordController.text;

      // Navigate to the extra details screen
      Get.toNamed('/reg_extra_details');
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
                  icon: Icons.person_add_alt_1,
                  title: "إنشاء حساب جديد",
                  subtitle: "المرحلة الأولى من التسجيل",
                  showBackButton: true, // Assuming BuildHeader supports it or just use a Leading icon
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            hintText: "الاسم",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            hintText: "اللقب",
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            hintText: "العنوان الكامل",
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "البريد الإلكتروني",
                            prefixIcon: const Icon(Icons.email_outlined),
                            errorText: _authController.emailError.value,
                          ),
                          onChanged: (v) {
                            if (_authController.emailError.value != null) {
                              _authController.emailError.value = null;
                            }
                          },
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "رقم الهاتف",
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "كلمة المرور",
                            prefixIcon: const Icon(Icons.lock_outline),
                            errorText: _authController.passwordError.value,
                          ),
                          onChanged: (v) {
                            if (_authController.passwordError.value != null) {
                              _authController.passwordError.value = null;
                            }
                          },
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 18),
                        Obx(() => SearchableDropdownField(
                              label: "الولاية",
                              icon: Icons.map,
                              items: _dataController.wilayas.toList(),
                              selectedValue: _selectedWilayaId,
                              onChanged: (value) {
                                setState(() {
                                  _selectedWilayaId = value.toString();
                                  _selectedCommuneId = null;
                                });
                                if (value != null) {
                                  _dataController
                                      .fetchCommunes(value.toString());
                                }
                              },
                            )),
                        const SizedBox(height: 18),
                        Obx(() => SearchableDropdownField(
                              label: "البلدية",
                              icon: Icons.location_city,
                              items: _dataController.communes,
                              selectedValue: _selectedCommuneId,
                              isLoading: _dataController.communes.isEmpty &&
                                  _selectedWilayaId != null,
                              onChanged: (value) => setState(
                                  () => _selectedCommuneId = value.toString()),
                              hint: _selectedWilayaId == null
                                  ? "اختر الولاية أولاً"
                                  : "اختر البلدية",
                            )),
                        const SizedBox(height: 18),
                        Obx(() => SearchableDropdownField(
                              label: "نوع الحساب",
                              icon: Icons.business_center,
                              items: _dataController.userTypes.toList(),
                              selectedValue: _selectedUserTypeId,
                              onChanged: (value) => setState(
                                  () => _selectedUserTypeId = value.toString()),
                            )),
                        Obx(
                          () => _authController.generalError.value != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    _authController.generalError.value!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 120), // Space for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _authController.isLoading.value ? null : _next,
              child: _authController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "متابعة",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
