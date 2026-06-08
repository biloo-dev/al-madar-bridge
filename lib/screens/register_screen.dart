import 'package:al_madar_bridge/controllers/data_controller.dart' show DataController;
import 'package:al_madar_bridge/screens/widgets/BuildHeader.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_madar_bridge/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _communeController = TextEditingController(text: "الجزائر الوسطى");
  final AuthController _authController = Get.find<AuthController>();
  final DataController _dataController = Get.find<DataController>();

  final List<String> _wilayas = ["الجزائر", "وهران", "قسنطينة", "البليدة", "شلف", "عنابة"];
  late String _selectedWilaya;

  String? _selectedUserTypeId;

  @override
  void initState() {
    super.initState();
    _selectedWilaya = _wilayas[0];
  }

  void _next() async {
    if (_formKey.currentState!.validate() && _selectedUserTypeId != null) {
      bool success = await _authController.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        wilaya: _selectedWilaya,
        commune: _communeController.text,
        userType: _selectedUserTypeId!,
        password: _passwordController.text,
      );

      if (success) {
        switch (_selectedUserTypeId) {
          case 'contractor': Get.toNamed('/reg_contractor'); break;
          case 'supplier': Get.toNamed('/reg_supplier'); break;
          case 'craftsman': Get.toNamed('/reg_craftsman'); break;
          case 'investor': Get.toNamed('/reg_investor'); break;
          case 'equipment_owner': Get.toNamed('/reg_equipment_owner'); break;
        }
      } else {
        Get.snackbar("خطأ", "فشل إنشاء الحساب، يرجى المحاولة لاحقاً",
            snackPosition: SnackPosition.BOTTOM);
      }
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
            colors: [
              Color(0xFFD6EEF8),
              Colors.white,
            ],
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
                          validator: (v) => (v == null || v.isEmpty) ? "مطلوب" : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            hintText: "اللقب",
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Obx(() => TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "البريد الإلكتروني",
                            prefixIcon: const Icon(Icons.email_outlined),
                            errorText: _authController.emailError.value,
                          ),
                          onChanged: (_) => _authController.emailError.value = null,
                        )),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "رقم الهاتف",
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Obx(() => TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "كلمة المرور",
                            prefixIcon: const Icon(Icons.lock_outline),
                            errorText: _authController.passwordError.value,
                          ),
                          onChanged: (_) => _authController.passwordError.value = null,
                        )),
                        const SizedBox(height: 18),
                        DropdownButtonFormField<String>(
                          value: _selectedWilaya,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.location_on),
                            hintText: "الولاية",
                          ),
                          items: _wilayas.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                          onChanged: (value) => setState(() => _selectedWilaya = value!),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _communeController,
                          decoration: const InputDecoration(
                            hintText: "البلدية",
                            prefixIcon: Icon(Icons.location_city),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Obx(() => DropdownButtonFormField<String>(
                          value: _selectedUserTypeId,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.business_center),
                            hintText: "نوع الحساب",
                          ),
                          items: _dataController.userTypes.map((type) => DropdownMenuItem(
                            value: type.id,
                            child: Text(type.nameAr),
                          )).toList(),
                          onChanged: (value) => setState(() => _selectedUserTypeId = value!),
                          validator: (v) => v == null ? "يرجى اختيار نوع الحساب" : null,
                        )),
                        Obx(() => _authController.generalError.value != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  _authController.generalError.value!,
                                  style: const TextStyle(color: Colors.red, fontSize: 12),
                                ),
                              )
                            : const SizedBox.shrink()),
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
        child: Obx(() => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _authController.isLoading.value ? null : _next,
            child: _authController.isLoading.value 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("متابعة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
          ),
        )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
