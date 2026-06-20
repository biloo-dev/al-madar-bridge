import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/news/news_detail_screen.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewsTab extends StatelessWidget {
  const NewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.find<DataController>();

    return Obx(() {
      if (dataController.isLoading.value && dataController.newsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (dataController.newsList.isEmpty) {
        return const Center(child: Text("لا توجد أخبار حالياً"));
      }

      final newsItems = dataController.newsList.toList();
      // تأكيد الترتيب: الأحدث أولاً
      newsItems.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // حشو سفلي إضافي
        itemCount: newsItems.length,
        itemBuilder: (context, idx) {
          final item = newsItems[idx];
          return GestureDetector(
            onTap: () => Get.to(() => NewsDetailScreen(news: item)),
            child: Card(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.featuredImage.isNotEmpty)
                    Image.network(
                      item.featuredImage,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.authorName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              item.publishedAt != null
                                  ? DateFormat(
                                      'yyyy/MM/dd',
                                    ).format(item.publishedAt!)
                                  : "",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.summary.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            item.summary,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${item.viewsCount}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.favorite_border,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${item.likesCount}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              "اقرأ المزيد",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: AppTheme.primaryBlue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
