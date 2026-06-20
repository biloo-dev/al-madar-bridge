import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/image_carousel.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingDetailScreen extends StatefulWidget {
  const OnboardingDetailScreen({super.key});

  @override
  State<OnboardingDetailScreen> createState() => _OnboardingDetailScreenState();
}

class _OnboardingDetailScreenState extends State<OnboardingDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool _obscurePassword = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      bool success = await _authController.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        final user = _authController.currentUser;
        if (user != null && !user.emailVerified) {
          Get.offAllNamed('/verification_pending');
          return;
        }

        if (PrefManager.isProfileCompleted) {
          Get.offAllNamed('/home');
        } else {
          _resumeRegistration();
        }
      } else {
        Get.snackbar(
          "خطأ",
          "فشل تسجيل الدخول، يرجى التحقق من البيانات",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  void _resumeRegistration() {
    String step = PrefManager.registrationStep;
    String type = PrefManager.userType;

    if (step == 'extra_details') {
      switch (type) {
        case 'contractor':
          Get.offAllNamed('/reg_contractor');
          break;
        case 'supplier':
          Get.offAllNamed('/reg_supplier');
          break;
        case 'craftsman':
          Get.offAllNamed('/reg_craftsman');
          break;
        case 'investor':
          Get.offAllNamed('/reg_investor');
          break;
        case 'equipment_owner':
          Get.offAllNamed('/reg_equipment_owner');
          break;
        default:
          Get.offAllNamed('/home');
      }
    } else if (step == 'files') {
      if (type == 'contractor') {
        Get.offAllNamed('/files_contractor');
      } else {
        Get.offAllNamed('/home');
      }
    } else {
      Get.offAllNamed('/home');
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("استعادة كلمة المرور", textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "أدخل بريدك الإلكتروني لإرسال رابط إعادة التعيين",
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "البريد الإلكتروني",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                _authController.sendPasswordReset(emailController.text);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text("إرسال", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.find<DataController>();
    final int selectedIndex = Get.arguments as int? ?? 0;

    return Scaffold(
      body: Obx(() {
        if (dataController.isLoading.value &&
            dataController.onboardingPages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final pages = dataController.onboardingPages
            .where((e) => e["id"] != "start_page")
            .toList();

        if (selectedIndex < 0 || selectedIndex >= pages.length) {
          return const Scaffold(body: Center(child: Text("Page not found")));
        }

        final page = pages[selectedIndex];
        final String id = page['id']?.toString() ?? '';

        final List<Color> bgColors = [
          const Color(0xFFD48D3B), // Contractor
          const Color(0xFF4CAF50), // Investor
          const Color(0xFF2196F3), // Equipment
          const Color(0xFF673AB7), // Supplier
          const Color(0xFFFFC107), // Craftsman
        ];

        final Color backgroundColor = bgColors[selectedIndex % bgColors.length];

        return Container(
          color: backgroundColor,
          child: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15),
                        Text(
                          (page['name'] ?? '').toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 60,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          (page['title'] ?? '').toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ImageCarousel(
                          images: List<String>.from(page['image'] ?? []),
                        ),
                        const SizedBox(height: 20),

                        // Login Form Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Icon Stack
                                // Email Field
                                Obx(
                                  () => TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: "البريد الإلكتروني",
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.lightSurface,
                                      errorText:
                                          _authController.emailError.value,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "أدخل البريد الإلكتروني";
                                      }
                                      return null;
                                    },
                                    onChanged: (_) =>
                                        _authController.emailError.value = null,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Password Field
                                Obx(
                                  () => TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      hintText: "كلمة المرور",
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      errorText:
                                          _authController.passwordError.value,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "أدخل كلمة المرور";
                                      }
                                      return null;
                                    },
                                    onChanged: (_) =>
                                        _authController.passwordError.value =
                                            null,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: _showForgotPasswordDialog,
                                    child: Text(
                                      "نسيت كلمة المرور؟",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 00),
                                // Login Button
                                Obx(
                                  () => SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _authController.isLoading.value
                                          ? null
                                          : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: backgroundColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: _authController.isLoading.value
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              "تسجيل الدخول",
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Register Link
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,

                                  children: [
                                    const Text(
                                      "ليس لديك حساب؟ ",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.toNamed(
                                        '/register',
                                        arguments: id,
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        "إنشاء حساب",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              // Custom Back Button at top left
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
