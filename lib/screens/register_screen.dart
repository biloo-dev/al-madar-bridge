import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart'
    show DataController;
import 'package:al_madar_bridge/screens/widgets/searchable_dropdown_field.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
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
    if (Get.arguments != null) {
      _selectedUserTypeId = Get.arguments.toString();
    }
  }

  Color _getThemeColor() {
    switch (_selectedUserTypeId?.toLowerCase()) {
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
    String id = _selectedUserTypeId?.toLowerCase() ?? 'contractor';
    return "assets/userType/$id.png";
  }

  void _next() {
    if (_formKey.currentState!.validate() &&
        _selectedUserTypeId != null &&
        _selectedWilayaId != null &&
        _selectedCommuneId != null) {
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
      Get.toNamed('/reg_extra_details');
    } else if (_selectedUserTypeId == null || _selectedWilayaId == null || _selectedCommuneId == null) {
      Get.snackbar("تنبيه", "يرجى إكمال كافة الاختيارات", snackPosition: SnackPosition.BOTTOM);
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
                // Custom Header with User Type Image
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
                        Icons.person_add_alt_1,
                        size: 42,
                        color: themeColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "إنشاء حساب جديد",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "المرحلة الأولى من التسجيل",
                  style: TextStyle(
                    color: AppTheme.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

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
                          decoration: InputDecoration(
                            hintText: "الاسم",
                            prefixIcon: Icon(Icons.person_outline, color: themeColor),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            hintText: "اللقب",
                            prefixIcon: Icon(Icons.badge_outlined, color: themeColor),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: "العنوان الكامل",
                            prefixIcon: Icon(Icons.location_on_outlined, color: themeColor),
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
                            prefixIcon: Icon(Icons.email_outlined, color: themeColor),
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
                          decoration: InputDecoration(
                            hintText: "رقم الهاتف",
                            prefixIcon: Icon(Icons.phone, color: themeColor),
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
                            prefixIcon: Icon(Icons.lock_outline, color: themeColor),
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
                        // Only show user type selection if it wasn't pre-selected
                        if (_selectedUserTypeId == null)
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
                const SizedBox(height: 120),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
              ),
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
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
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
