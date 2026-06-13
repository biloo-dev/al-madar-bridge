import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsDocument news;
  const NewsDetailScreen({super.key, required this.news});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final DataController _dataController = Get.find<DataController>();
  final RxBool _isLiked = false.obs;
  final RxInt _likesCount = 0.obs;

  @override
  void initState() {
    super.initState();
    _likesCount.value = widget.news.likesCount;
    _checkLikeStatus();
    // Increment view count securely (only once per user)
    _dataController.incrementNewsViews(widget.news.id);
  }

  void _checkLikeStatus() async {
    _isLiked.value = await _dataController.isNewsLiked(widget.news.id);
  }

  void _handleLikeToggle() async {
    final bool newStatus = await _dataController.toggleNewsLike(widget.news.id);
    _isLiked.value = newStatus;
    if (newStatus) {
      _likesCount.value++;
    } else {
      _likesCount.value--;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تفاصيل الخبر", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              _isLiked.value ? Icons.favorite : Icons.favorite_border,
              color: _isLiked.value ? Colors.red : Colors.black54,
            ),
            onPressed: _handleLikeToggle,
          )),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.news.featuredImage.isNotEmpty)
              Image.network(
                widget.news.featuredImage,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.news.authorName,
                          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.news.publishedAt != null 
                            ? DateFormat('yyyy/MM/dd HH:mm').format(widget.news.publishedAt!) 
                            : "",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.news.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text("${widget.news.viewsCount} مشاهدة", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 20),
                      Obx(() => Row(
                        children: [
                          Icon(
                            _isLiked.value ? Icons.favorite : Icons.favorite_border, 
                            size: 16, 
                            color: _isLiked.value ? Colors.red : Colors.grey
                          ),
                          const SizedBox(width: 6),
                          Text("${_likesCount.value} إعجاب", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      )),
                    ],
                  ),
                  const Divider(height: 40),
                  Text(
                    widget.news.content,
                    style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  if (widget.news.tags.isNotEmpty) ...[
                    const Text("الوسوم:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: widget.news.tags.map((tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey[100],
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (widget.news.sourceName.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.source, color: Colors.grey),
                          const SizedBox(width: 10),
                          const Text("المصدر: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(widget.news.sourceName),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
