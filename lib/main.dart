import 'package:al_madar_bridge/bindings/initial_binding.dart';
import 'package:al_madar_bridge/firebase_options.dart';
import 'package:al_madar_bridge/screens/onboarding_screen.dart';
import 'package:al_madar_bridge/screens/registration/contractor_files_screen.dart';
import 'package:al_madar_bridge/screens/registration/extra_details_screen.dart';
import 'package:al_madar_bridge/screens/registration/verification_pending_screen.dart';
import 'package:al_madar_bridge/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'services/pref_manager.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // تهيئة الخدمات بشكل منفصل لضمان عدم توقف التطبيق عند حدوث خطأ في إحداها
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Initialization Error: $e');
  }

  try {
    await PrefManager.init();
    await NotificationService.init();
  } catch (e) {
    debugPrint('Local Services Error: $e');
  }

  // تهيئة Sentry وتشغيل التطبيق
  await SentryFlutter.init((options) {
    options.dsn =
        'https://205b0b8b04439c2dcc65700e3e9a78aa@o4511557858623488.ingest.de.sentry.io/4511557860786256';
    options.tracesSampleRate =
        0.2; // تقليل النسبة لتحسين الأداء في نسخة Release
    options.profilesSampleRate = 0.2;
  }, appRunner: () => runApp(SentryWidget(child: const ContractorPlatformApp())));
}

class ContractorPlatformApp extends StatelessWidget {
  const ContractorPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'منصة جسر المدار',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'DZ')],
      locale: const Locale('ar', 'DZ'),

      initialBinding: InitialBinding(),

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
        GetPage(
          name: '/verification_pending',
          page: () => const VerificationPendingScreen(),
        ),
      ],
      defaultTransition: Transition.cupertino,
    );
  }
}
