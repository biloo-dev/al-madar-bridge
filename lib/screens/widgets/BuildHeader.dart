import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildHeader extends StatelessWidget {
  const BuildHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showBackButton)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryBlue),
            ),
          ),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryBlue.withOpacity(.12),
          ),
          child: Icon(
            icon,
            size: 42,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textMedium,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
