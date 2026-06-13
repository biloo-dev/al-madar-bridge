import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatelessWidget {
  ImageCarousel({super.key, required this.images});

  List<String> images;

  @override
  Widget build(BuildContext context) {
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
          child: CachedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.cover,

            placeholder: (context, url) {
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
            },

            errorWidget: (_, __, ___) => const Center(child: Icon(Icons.error)),
          ),
        );
      },
    );
  }
}
