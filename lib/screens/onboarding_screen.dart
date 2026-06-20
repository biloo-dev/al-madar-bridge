import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final DataController _dataController = Get.find<DataController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Top Background Image
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              'assets/background/background.png',
              fit: BoxFit.contain,
            ),
          ),

          // 2. Bottom Background Image
          // Positioned(
          //   bottom: 0,
          //   right: 0,
          //   left: 0,
          //   child: Image.asset('assets/background/3.png', fit: BoxFit.cover),
          // ),

          // 3. Main Content
          SafeArea(
            child: Obx(() {
              if (_dataController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_dataController.onboardingPages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("عذراً، لم نتمكن من جلب البيانات"),
                      TextButton(
                        onPressed: () => _dataController.fetchInitialData(),
                        child: const Text("إعادة المحاولة"),
                      ),
                    ],
                  ),
                );
              }

              // جلب البيانات من مجموعة onboarding
              final onboardingFirstPage =
                  _dataController.onboardingPages.firstWhereOrNull(
                    (e) => e["id"] == "start_page",
                  ) ??
                  {};
              final onboardingPages = _dataController.onboardingPages
                  .where((e) => e["id"] != "start_page")
                  .toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final double screenHeight = constraints.maxHeight;
                  final bool isSmallScreen = screenHeight < 700;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: isSmallScreen ? 10 : 20),
                            Center(
                              child: SvgPicture.asset(
                                'assets/logo.svg',
                                height: isSmallScreen ? 100 : 120,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                      'assets/logo.png',
                                      height: isSmallScreen ? 80 : 100,
                                    ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 5 : 10),
                            Text(
                              (onboardingFirstPage["name"] ?? '').toString(),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A2E40),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isSmallScreen ? 4 : 8),
                            Text(
                              (onboardingFirstPage["title"] ?? '').toString(),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 15,
                                color: Colors.black54,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isSmallScreen ? 10 : 20),
                            _buildSelectionDivider(),
                          ],
                        ),

                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: onboardingPages.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final page = onboardingPages[index];
                                final String id = page['id']?.toString() ?? '';
                                return _buildUserTypeCard(
                                  id: id,
                                  index: index,
                                  title: (page['name'] ?? '').toString(),
                                  subtitle: (page['title'] ?? '').toString(),
                                  imagePath: "assets/userType/$id.png",
                                  color: _getColorForId(id),
                                  isSmall: isSmallScreen,
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 5 : 20),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppTheme.accentOrange, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "اختر نوع المستخدم",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E40),
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accentOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Divider(color: AppTheme.accentOrange, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required String id,
    required int index,
    required String title,
    required String subtitle,
    required String imagePath,
    required Color color,
    required bool isSmall,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 10 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed('/onboarding_detail', arguments: index),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Container(
                width: isSmall ? 60 : 70,
                height: isSmall ? 60 : 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      size: isSmall ? 30 : 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmall ? 15 : 17,
                        fontWeight: FontWeight.bold,
                        color: color.darken(0.2),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmall ? 11 : 12,
                        color: Colors.grey,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppTheme.accentOrange,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForId(String id) {
    switch (id.toLowerCase()) {
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
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
