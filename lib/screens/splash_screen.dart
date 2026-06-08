import 'package:al_madar_bridge/models/user_file.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (PrefManager.rememberLogin) {
      if (PrefManager.isProfileCompleted) {
        Get.offAllNamed('/home');
      } else {
        // Resume registration based on user type and step
        _resumeRegistration();
      }
    } else {
      Get.offAllNamed('/onboarding');
    }
  }

  void _resumeRegistration() {
    String step = PrefManager.registrationStep;
    String type = PrefManager.userType;

    if (step == 'extra_details') {
      switch (type) {
        case 'contractor': Get.offAllNamed('/reg_contractor'); break;
        case 'supplier': Get.offAllNamed('/reg_supplier'); break;
        case 'craftsman': Get.offAllNamed('/reg_craftsman'); break;
        case 'investor': Get.offAllNamed('/reg_investor'); break;
        case 'equipment_owner': Get.offAllNamed('/reg_equipment_owner'); break;
        default: Get.offAllNamed('/home');
      }
    } else if (step == 'files') {
      // Assuming only contractors have a separate files step for now
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
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
          child: Column(
            children: [
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(.08),
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(.12),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.08),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/logo.svg',
                      width: 90,
                      height: 90,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                "منصة تدقيق وعقود المقاولين",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "منصة رقمية موحدة للرقابة والمطابقة الفنية",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 36),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppTheme.accentOrange,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    const Text(
                      "AL MADAR BRIDGE",
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Digital Contractor Platform",
                      style: TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
