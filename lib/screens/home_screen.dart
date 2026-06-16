import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/tabs/contractor_project_tab.dart';
import 'package:al_madar_bridge/screens/tabs/home_tab.dart';
import 'package:al_madar_bridge/screens/tabs/news_tab.dart';
import 'package:al_madar_bridge/screens/tabs/profile_edit_tab.dart';
import 'package:al_madar_bridge/screens/tabs/requests_tab.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthController _authController = Get.find<AuthController>();
  final DataController _dataController = Get.find<DataController>();

  final List<Widget> _pages = [
    const ProfileEditTab(),
    const RequestsTab(),
    const HomeTab(),
    const NewsTab(),
    const ContractorProjectTab(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2);

    // Refresh data in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dataController.fetchInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          SystemNavigator.pop(); // Exit the app
        }
      },
      child: Scaffold(
        extendBody: true,
        // Crucial for ConvexAppBar to look good
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          title: _buildAppBarTitle(),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => _showLogoutConfirmation(),
            ),
          ],
        ),
        drawer: _buildDrawer(),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          // Prevent swipe to avoid accidental tab changes
          children: _pages,
        ),
        floatingActionButton: _buildFAB(),
        bottomNavigationBar: ConvexAppBar(
          controller: _tabController,
          backgroundColor: AppTheme.primaryBlue,
          color: Colors.white70,
          activeColor: AppTheme.accentOrange,
          style: TabStyle.flip,
          curveSize: 80,
          top: -20,
          items: const [
            TabItem(icon: Icons.person_outline_rounded, title: "معلوماتي"),
            TabItem(icon: Icons.assignment_outlined, title: "طلباتي"),
            TabItem(icon: Icons.home_rounded, title: "الرئيسية"),
            TabItem(icon: Icons.newspaper_rounded, title: "الأخبار"),
            TabItem(
              icon: Icons.assignment_turned_in_outlined,
              title: "المشاريع",
            ),
          ],
          onTap: (index) {
            if (index == 2) _dataController.fetchInitialData();
            if (index == 4) _dataController.listenToProjects();
          },
        ),
      ),
    );
  }

  void _showChangeEmailDialog() {
    final currentPwdController = TextEditingController();
    final newEmailController = TextEditingController(
      text: PrefManager.userEmail,
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "تغيير البريد الإلكتروني",
          textAlign: TextAlign.right,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPwdController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "تأكيد كلمة المرور",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "البريد الإلكتروني الجديد",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (currentPwdController.text.isNotEmpty &&
                  newEmailController.text.isNotEmpty) {
                bool ok = await _authController.changeEmail(
                  currentPwdController.text,
                  newEmailController.text,
                );
                if (ok) Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text("تحديث", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPwdController = TextEditingController();
    final newPwdController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تغيير كلمة المرور", textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPwdController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "كلمة المرور الحالية",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPwdController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "كلمة المرور الجديدة",
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (currentPwdController.text.isNotEmpty &&
                  newPwdController.text.length >= 6) {
                bool ok = await _authController.changePassword(
                  currentPwdController.text,
                  newPwdController.text,
                );
                if (ok) Get.back();
              } else {
                Get.snackbar(
                  "تنبيه",
                  "يجب أن تكون كلمة المرور 6 أحرف على الأقل",
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text("تحديث", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePhoneDialog() {
    final currentPwdController = TextEditingController();
    final newPhoneController = TextEditingController(
      text: PrefManager.userPhone,
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تغيير رقم الهاتف", textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPwdController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "تأكيد كلمة المرور",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "رقم الهاتف الجديد",
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              if (currentPwdController.text.isNotEmpty &&
                  newPhoneController.text.isNotEmpty) {
                bool ok = await _authController.changePhone(
                  currentPwdController.text,
                  newPhoneController.text,
                );
                if (ok) Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text("تحديث", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تسجيل الخروج', textAlign: TextAlign.right),
        content: const Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('خروج', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      _authController.logout();
    }
  }

  Widget? _buildFAB() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        // يظهر الزر فقط في تبويب "طلباتي" (Index 1)
        if (_tabController.index != 1) return const SizedBox.shrink();

        String label = "إضافة جديد";
        final userType = PrefManager.userType.toLowerCase();
        if (userType.contains('contractor') || userType.contains('مقاول')) {
          label = "إضافة طلب";
        } else if (userType.contains('supplier') || userType.contains('مورد')) {
          label = "إضافة سلعة";
        } else if (userType.contains('craftsman') ||
            userType.contains('حرفي')) {
          label = "إضافة طلب عمل";
        } else if (userType.contains('equipment') ||
            userType.contains('عتاد')) {
          label = "إضافة عرض عتاد";
        }

        return FloatingActionButton.extended(
          onPressed: () {
            // الوصول إلى وظيفة الإضافة الموجودة في RequestsTab
            final requestsTabState = _pages[1] as RequestsTab;
            // بما أننا لا نستطيع الوصول للـ State مباشرة بسهولة هنا،
            // سنقوم باستدعاء الـ BottomSheet مباشرة.
            RequestsTab.showCreateActionSheet(context);
          },
          backgroundColor: AppTheme.primaryBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarTitle() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        String title = "جسر المدار";
        switch (_tabController.index) {
          case 0:
            title = "تعديل البيانات";
            break;
          case 1:
            title = "طلباتي ومستحقاتي";
            break;
          case 2:
            title = "الرئيسية";
            break;
          case 3:
            title = "المستجدات";
            break;
          case 4:
            title = "المشاريع";
            break;
        }
        return Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              "${PrefManager.userFirstName} ${PrefManager.userLastName}",
            ),
            accountEmail: Text(PrefManager.userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                PrefManager.userFirstName.isNotEmpty
                    ? PrefManager.userFirstName[0]
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            decoration: const BoxDecoration(color: AppTheme.primaryBlue),
          ),
          ListTile(
            leading: const Icon(
              Icons.lock_reset_rounded,
              color: AppTheme.primaryBlue,
            ),
            title: const Text("تغيير كلمة المرور"),
            onTap: () {
              Navigator.pop(context);
              _showChangePasswordDialog();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.email_rounded,
              color: AppTheme.primaryBlue,
            ),
            title: const Text("تغيير البريد الإلكتروني"),
            onTap: () {
              Navigator.pop(context);
              _showChangeEmailDialog();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.phone_android_rounded,
              color: AppTheme.primaryBlue,
            ),
            title: const Text("تغيير رقم الهاتف"),
            onTap: () {
              Navigator.pop(context);
              _showChangePhoneDialog();
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text(
              "تسجيل الخروج",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () => _showLogoutConfirmation(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
