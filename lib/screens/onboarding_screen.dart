import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/image_carousel.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_tutorial/flutter_sliding_tutorial.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<double> _notifier = ValueNotifier(0);
  int _currentIndex = 0;
  final DataController _dataController = Get.find<DataController>();

  static const List<Color> _bgColors = [
    AppTheme.primaryBlue,
    Color(0xFF1A237E),
    Color(0xFF00695C),
    Color(0xFF4A148C),
    Color(0xFFBF360C),
    Color(0xFF1B5E20),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    _notifier.value = _pageController.page ?? 0;
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _notifier.dispose();
    super.dispose();
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
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.orange,
                  ),
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
          final int pageCount = pages.length;
          final List<Color> colors = List.generate(
            pageCount,
            (i) => _bgColors[i % _bgColors.length],
          );

          return Stack(
            children: [
              AnimatedBackgroundColor(
                pageController: _pageController,
                pageCount: pageCount,
                colors: colors,
                child: const SizedBox.expand(),
              ),
              PageView.builder(
                controller: _pageController,
                itemCount: pageCount,
                onPageChanged: (idx) {
                  setState(() => _currentIndex = idx);
                },
                itemBuilder: (context, idx) {
                  final page = pages[idx];
                  return SlidingPage(
                    page: idx,
                    notifier: _notifier,
                    child: _OnboardingPageContent(
                      index: idx,
                      id: page['id']?.toString() ?? '',
                      images: List<String>.from(page['image'] ?? []),
                      title: (page['title'] ?? '').toString(),
                      description: (page['desc'] ?? '').toString(),
                    ),
                  );
                },
              ),
              // 3. Skip button (top-right) - Hide on first page
              if (_currentIndex != 0)
                Positioned(
                  top: 8,
                  right: 16,
                  child: TextButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    child: const Text(
                      "تخطي",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              // 4. Center Start Button for the first page ONLY
              if (_currentIndex == 0)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colors[0],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                        ),
                        child: const Text(
                          "ابدأ الآن",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // 5. Standard Bottom bar (Previous, Dots, Next) - Hide on first page
              if (_currentIndex != 0)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _currentIndex == 0
                            ? null
                            : () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _currentIndex == 0
                                ? Colors.grey[200]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 16,
                                color: _currentIndex == 0
                                    ? Colors.grey
                                    : colors[_currentIndex],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "السابق",
                                style: TextStyle(
                                  color: _currentIndex == 0
                                      ? Colors.grey
                                      : colors[_currentIndex],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SlidingIndicator(
                        indicatorCount: pageCount,
                        notifier: _notifier,
                        activeIndicator: Container(
                          width: 24,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        inActiveIndicator: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white38,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        activeIndicatorSize: 24,
                        inactiveIndicatorSize: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_currentIndex < pageCount - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Get.offAllNamed('/login');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentIndex == pageCount - 1 ? "البدء" : "التالي",
                                style: TextStyle(
                                  color: colors[_currentIndex],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentIndex == pageCount - 1 
                                    ? Icons.check_circle_outline_rounded 
                                    : Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: colors[_currentIndex],
                              ),
                            ],
                          ),
                        ),
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

class _OnboardingPageContent extends StatelessWidget {
  final int index;
  final String id;
  final List<String> images;
  final String title;
  final String description;

  const _OnboardingPageContent({
    required this.index,
    required this.id,
    required this.images,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlidingContainer(offset: 150, child: ImageCarousel(images: images)),
          const SizedBox(height: 32),
          SlidingContainer(
            offset: 250,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          SlidingContainer(
            offset: 350,
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Hide registration buttons on first page
          if (index != 0)
            SlidingContainer(
              offset: 450,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed('/register', arguments: id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "إنشاء حساب جديد",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Get.toNamed('/login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "الدخول إلى المنصة",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
