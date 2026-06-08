import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final DataController _dataController = Get.find<DataController>();

  IconData _getIcon(String name) {
    switch (name) {
      case "business_center": return Icons.business_center;
      case "handshake": return Icons.handshake;
      case "assignment_turned_in": return Icons.assignment_turned_in;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (_dataController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (_dataController.onboardingPages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text("قاعدة البيانات فارغة"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    child: const Text("تخطي إلى تسجيل الدخول"),
                  ),
                ],
              ),
            );
          }
          final pages = _dataController.onboardingPages;
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (idx) => setState(() => _currentIndex = idx),
                  itemBuilder: (context, idx) {
                    final page = pages[idx];
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 240,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(_getIcon(page['icon_path'] ?? ''), size: 100, color: Colors.white),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            page['title'] ?? '',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page['desc'] ?? '',
                            style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                      (idx) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentIndex == idx ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == idx ? AppTheme.primaryBlue : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Get.offAllNamed('/login'),
                      child: const Text("تخطي"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentIndex < pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Get.offAllNamed('/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedCornerShape(12),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(_currentIndex == pages.length - 1 ? "البدء" : "التالي"),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

RoundedCornerShape(double val) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(val));


