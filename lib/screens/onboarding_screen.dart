import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/image_carousel.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                // 4. Side Buttons (Previous / Next) - Icons only, transparent
                if (_currentIndex != 0) ...[
                  // Left Button -> Previous
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          ),
                          borderRadius: BorderRadius.circular(50),
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white70,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Right Button -> Next
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
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
                          borderRadius: BorderRadius.circular(50),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              _currentIndex == pageCount - 1
                                  ? Icons.check_circle_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // 5. Center Start Button for the first page ONLY
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
                // 6. Dots Indicator - Hide on first page
                if (_currentIndex != 0)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SlidingIndicator(
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
                    ),
                  ),
              ],
            );
          }),
        ),
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
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 20),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlidingContainer(
                  offset: 150,
                  child: ImageCarousel(images: images),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 10),
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
              ],
            ),
          ),
          // Registration buttons at the very bottom edge
          if (index != 0)
            SlidingContainer(
              offset: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed('/register', arguments: id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "إنشاء حساب جديد",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
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
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // مسافة بسيطة من الحافة
                ],
              ),
            ),
        ],
      ),
    );
  }
}
