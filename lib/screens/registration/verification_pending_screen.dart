import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationPendingScreen extends StatelessWidget {
  const VerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final email = authController.registrationData['email'] ?? authController.currentUser?.email ?? "";

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD6EEF8), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 100,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(height: 32),
                const Text(
                  "تحقق من بريدك الإلكتروني",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "لقد أرسلنا رابط تفعيل إلى بريدك الإلكتروني:\n$email",
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "يرجى الضغط على الرابط الموجود في الرسالة لتفعيل حسابك والدخول إلى المنصة.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authController.isLoading.value 
                      ? null 
                      : () async {
                          await authController.reloadUser();
                          if (authController.currentUser?.emailVerified ?? false) {
                            if (PrefManager.isProfileCompleted) {
                              Get.offAllNamed('/home');
                            } else {
                              // توجيهه لإكمال التسجيل إذا لم ينتهِ منه
                              String step = PrefManager.registrationStep;
                              if (step == 'extra_details' || step == 'files') {
                                Get.offAllNamed('/login'); // سيتولى منطق تسجيل الدخول توجيهه للخطوة الصحيحة
                              } else {
                                Get.offAllNamed('/home');
                              }
                            }
                          } else {
                            Get.snackbar(
                              "تنبيه", 
                              "لم يتم تفعيل الحساب بعد، يرجى التحقق من بريدك الإلكتروني",
                              backgroundColor: Colors.orange.withOpacity(0.8),
                              colorText: Colors.white,
                            );
                          }
                        },
                    child: authController.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("لقد قمت بالتفعيل، اذهب للرئيسية"),
                  ),
                )),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => authController.resendVerificationEmail(),
                  child: const Text(
                    "لم يصلك الرابط؟ إعادة الإرسال",
                    style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => authController.logout(),
                  child: const Text("العودة لتسجيل الدخول", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
