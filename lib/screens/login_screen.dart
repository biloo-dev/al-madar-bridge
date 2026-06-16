import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  void _showVerificationDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تأكيد البريد الإلكتروني", textAlign: TextAlign.right),
        content: const Text(
          "يرجى التحقق من بريدك الإلكتروني وتفعيل الحساب قبل الدخول. إذا لم يصلك الرابط، يمكنك إعادة إرساله.",
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => _authController.logout(),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              await _authController.resendVerificationEmail();
            },
            child: const Text("إعادة إرسال الرابط"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authController.reloadUser();
              if (_authController.currentUser?.emailVerified ?? false) {
                Get.back();
                _submit(); // Retry submission after verification
              } else {
                Get.snackbar("تنبيه", "لم يتم تفعيل الحساب بعد");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text(
              "تم التفعيل",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء"),
          ),
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

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  void _checkExistingSession() {
    // إذا كان المستخدم مسجلاً دخوله مسبقاً، نتوجه للرئيسية مباشرة عند الوصول لهذه الواجهة
    final user = _authController.currentUser;
    if (user != null) {
      if (!user.emailVerified) {
        Future.microtask(() => Get.offAllNamed('/verification_pending'));
        return;
      }

      if (PrefManager.isProfileCompleted) {
        Future.microtask(() => Get.offAllNamed('/home'));
      } else {
        Future.microtask(() => _resumeRegistration());
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('تأكيد الخروج', textAlign: TextAlign.right),
            content: const Text(
              'هل أنت متأكد من رغبتك في إغلاق التطبيق؟',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'خروج',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryBlue.withOpacity(.08),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryBlue.withOpacity(.12),
                        ),
                      ),
                      Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_person,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "سجل الدخول للمنصة",
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "بوابة المقاولين والموردين والحرفيين",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Obx(
                            () => TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: "البريد الإلكتروني",
                                prefixIcon: const Icon(Icons.email_outlined),
                                filled: true,
                                fillColor: AppTheme.lightSurface,
                                errorText: _authController.emailError.value,
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
                          const SizedBox(height: 18),
                          Obx(
                            () => TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: "كلمة المرور",
                                prefixIcon: const Icon(Icons.lock_outline),
                                errorText: _authController.passwordError.value,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
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
                                  _authController.passwordError.value = null,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: const Text(
                                "نسيت كلمة المرور؟",
                                style: TextStyle(
                                  color: AppTheme.accentOrange,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
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
                          const SizedBox(height: 28),
                          Obx(
                            () => SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _authController.isLoading.value
                                    ? null
                                    : _submit,
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ليس لديك حساب؟",
                        style: TextStyle(color: AppTheme.textMedium),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: const Text(
                          "إنشاء حساب",
                          style: TextStyle(
                            color: AppTheme.accentOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
