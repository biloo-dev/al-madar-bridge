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
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed('/onboarding');
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
            colors: [Color(0xFFD6EEF8), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
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
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset('assets/logo.png', width: 90, height: 90),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                "جســــر المـــدار",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF034D74),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "منصة تدقيق وتوثيق عقود المتعاملين",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "قطاع الأشغال العمومية",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppTheme.accentOrange,
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    const Text(
                      "AL MADAR BRIDGE",
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF034D74),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Digital",
                          style: TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 40),
                        Text(
                          "Platform",
                          style: TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "CONTRACTORS • SUPPLIERS • INVESTORS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF034D74),
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      "• PROFESSIONALS & CRAFTSMEN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF034D74),
                        fontSize: 11,
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
