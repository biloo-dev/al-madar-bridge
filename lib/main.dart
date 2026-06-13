import 'package:al_madar_bridge/bindings/initial_binding.dart';
import 'package:al_madar_bridge/firebase_options.dart';
import 'package:al_madar_bridge/screens/onboarding_screen.dart';
import 'package:al_madar_bridge/screens/registration/contractor_files_screen.dart';
import 'package:al_madar_bridge/screens/registration/extra_details_screen.dart';
import 'package:al_madar_bridge/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'services/pref_manager.dart';
import 'theme/app_theme.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Lock orientation to portrait for a more consistent UI experience
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Initialize core services in parallel to save time
    await Future.wait([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      PrefManager.init(),
      NotificationService.init(),
    ]);

    runApp(const ContractorPlatformApp());
  } catch (e) {
    debugPrint('Fatal Initialization Error: $e');
    // You could show a specialized error app here if needed
  }
}

class ContractorPlatformApp extends StatelessWidget {
  const ContractorPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'منصة جسر المدار',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      // Default to light for consistency with logo colors

      // Localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'DZ')],
      locale: const Locale('ar', 'DZ'),

      // Dependency Injection
      initialBinding: InitialBinding(),

      // Routing
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/reg_extra_details',
          page: () => const ExtraDetailsScreen(),
        ),
        GetPage(
          name: '/files_contractor',
          page: () => const ContractorFilesScreen(),
        ),

        // Aliases for dynamic routes
        GetPage(
          name: '/reg_contractor',
          page: () => const ExtraDetailsScreen(),
        ),
        GetPage(name: '/reg_supplier', page: () => const ExtraDetailsScreen()),
        GetPage(name: '/reg_craftsman', page: () => const ExtraDetailsScreen()),
        GetPage(name: '/reg_investor', page: () => const ExtraDetailsScreen()),
        GetPage(
          name: '/reg_equipment_owner',
          page: () => const ExtraDetailsScreen(),
        ),
      ],

      // Performance Optimization
      defaultTransition: Transition.cupertino,
    );
  }
}
