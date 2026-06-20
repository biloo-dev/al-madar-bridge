import 'dart:io';
import 'dart:ui';
import 'package:al_madar_bridge/services/persistent_image_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> images;
  const ImageCarousel({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    
    return CarouselSlider.builder(
      itemCount: images.length,
      options: CarouselOptions(
        height: 320,
        viewportFraction: 0.9,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      itemBuilder: (context, index, realIndex) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: FutureBuilder<File?>(
            future: PersistentImageManager.getImage(images[index]),
            builder: (context, snapshot) {
              // أثناء التحميل أو الانتظار
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildPlaceholder();
              }

              // إذا تم العثور على الملف أو تحميله بنجاح
              if (snapshot.hasData && snapshot.data != null) {
                return Image.file(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              }

              // في حال الفشل (مثلاً لا يوجد إنترنت وأول مرة يفتح التطبيق)
              return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.grey.shade300),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: Colors.white.withOpacity(.1)),
        ),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
