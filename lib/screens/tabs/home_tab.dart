import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/news/news_detail_screen.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.find<DataController>();

    return RefreshIndicator(
      onRefresh: () => dataController.fetchInitialData(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Obx(() => _buildStatusCard(dataController.userStatus.value)),
          const SizedBox(height: 24),
          
          // Latest News Section
          _buildSectionHeader("آخر الأخبار", () => Get.toNamed('/news')),
          const SizedBox(height: 12),
          _buildNewsList(dataController),
          
          const SizedBox(height: 24),
          
          // Latest Announcements Section
          _buildSectionHeader("آخر الإعلانات والطلبات", () => Get.toNamed('/requests')),
          const SizedBox(height: 12),
          _buildAnnouncementsList(dataController),
          
          const SizedBox(height: 24),
          
          const Text("إحصائيات المتابعة الفنية",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "المستندات المودعة", 
                  "${dataController.userFiles.length}", 
                  Icons.folder_shared_rounded,
                  AppTheme.primaryBlue
                )
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "المشاريع الحالية", 
                  "${dataController.projects.length}", 
                  Icons.engineering_rounded,
                  AppTheme.accentOrange
                )
              ),
            ],
          )),
          const SizedBox(height: 24),
          const Text("خدمات سريعة",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildUtilityRow("تحميل كتالوج ضوابط الجودة", Icons.menu_book_rounded),
          const SizedBox(height: 12),
          _buildUtilityRow("مراجعة ميثاق النزاهة", Icons.verified_user_rounded),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        TextButton(
          onPressed: onTap,
          child: const Text("عرض الكل", style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildNewsList(DataController controller) {
    return Obx(() {
      if (controller.newsList.isEmpty) {
        return const SizedBox(
          height: 150,
          child: Center(child: Text("لا توجد أخبار حالياً", style: TextStyle(color: Colors.grey))),
        );
      }
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.newsList.length > 5 ? 5 : controller.newsList.length,
          itemBuilder: (context, index) {
            final news = controller.newsList[index];
            return GestureDetector(
              onTap: () => Get.to(() => NewsDetailScreen(news: news)),
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(news.featuredImage),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        news.authorName,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildAnnouncementsList(DataController controller) {
    return Obx(() {
      if (controller.publicRequests.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGray),
          ),
          child: const Center(child: Text("لا توجد إعلانات حالياً", style: TextStyle(color: Colors.grey))),
        );
      }
      return Column(
        children: controller.publicRequests.take(3).map((request) {
          final type = controller.requestTypes.firstWhereOrNull((t) => t.id == request.requestTypeId);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGray),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getIconData(type?.icon), color: AppTheme.primaryBlue, size: 20),
              ),
              title: Text(request.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(
                "${type?.nameAr ?? ''} • ${_getWilayaName(controller, request.wilayaId)}",
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Text(
                request.createdAt != null ? intl.DateFormat('MM/dd').format(request.createdAt!) : '',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              onTap: () {},
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildStatusCard(String status) {
    final bool isApproved = status == "approved";
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isApproved 
              ? [AppTheme.primaryBlue, AppTheme.primaryBlueDark] 
              : [AppTheme.accentOrange, AppTheme.accentOrangeDark],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isApproved ? AppTheme.primaryBlue : AppTheme.accentOrange).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("حالة تدقيق الحساب", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    isApproved ? "نشط ومعتمد" : "موافقة معلقة", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isApproved
                      ? "تم التحقق من كافة الأوراق الثبوتية."
                      : "تصفح ومطابقة الوثائق جارية حالياً.",
                    style: const TextStyle(fontSize: 12, color: Colors.white70)
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
              child: Icon(isApproved ? Icons.check_circle_rounded : Icons.pending_rounded, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textMedium)),
        ],
      ),
    );
  }

  Widget _buildUtilityRow(String t, IconData i) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray)
      ),
      child: ListTile(
        leading: Icon(i, color: AppTheme.primaryBlue),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.borderGray),
        onTap: () {},
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'groups': return Icons.groups;
      case 'construction': return Icons.construction;
      case 'inventory': return Icons.inventory;
      case 'trending_up': return Icons.trending_up;
      case 'local_shipping': return Icons.local_shipping;
      case 'hotel': return Icons.hotel;
      case 'home_work': return Icons.home_work;
      default: return Icons.assignment;
    }
  }

  String _getWilayaName(DataController controller, String id) {
    final wilaya = controller.wilayas.firstWhereOrNull((w) => w.id == id);
    return wilaya?.nameAr ?? id;
  }
}
