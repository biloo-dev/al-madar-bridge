import 'package:al_madar_bridge/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:al_madar_bridge/models/user_file.dart';
import 'package:al_madar_bridge/screens/registration/contractor_files_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'services/pref_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registration/contractor_reg_screen.dart';
import 'screens/registration/supplier_reg_screen.dart';
import 'screens/registration/craftsman_reg_screen.dart';
import 'screens/registration/investor_reg_screen.dart';
import 'screens/registration/equipment_owner_reg_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/data_controller.dart';
import 'services/firestore_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PrefManager.init();
  
  // 1. Seed the data first (Uncomment to run)
  // print('Target Firebase Project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  // await FirestoreSeeder.seedAll();

  // 2. Then initialize Controllers
  Get.put(DataController());
  Get.put(AuthController());

  runApp(const ContractorPlatformApp());
}

class ContractorPlatformApp extends StatelessWidget {
  const ContractorPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'منصة مطابقة وعقود المقاولين',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // توطين واجهات التطبيق للغة العربية RTL بشكل أصيل
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'DZ'), // العربية - الجزائر
      ],
      locale: const Locale('ar', 'DZ'),

      // إدارة المسارات والانتقال التلقائي
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/reg_contractor': (context) => const ContractorRegScreen(),
        '/files_contractor': (context) => const ContractorFilesScreen(),
        '/reg_supplier': (context) => const SupplierRegScreen(),
        '/reg_craftsman': (context) => const CraftsmanRegScreen(),
        '/reg_investor': (context) => const InvestorRegScreen(),
        '/reg_equipment_owner': (context) => const EquipmentOwnerRegScreen(),
      },
    );
  }
}