import 'dart:developer';

import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GenderSelectionField extends StatelessWidget {
  final String label;
  final List<dynamic> items;
  final dynamic selectedValue;
  final Function(dynamic) onChanged;

  const GenderSelectionField({
    super.key,
    required this.label,
    required this.items,
    this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        Row(
          children: items.map((item) {
            final String id = _getItemId(item);
            final String text = _getItemText(item);
            final bool isSelected = selectedValue?.toString() == id;
            final IconData icon = _getGenderIcon(id, text);

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(id),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 6),
                      Icon(
                        icon,
                        size: 28,
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : Colors.grey[400],
                      ),

                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  IconData _getGenderIcon(String id, String text) {
    final lowerId = id.toLowerCase();
    final lowerText = text.toLowerCase();
    log("lowerId: $lowerId, lowerText: $lowerText");

    // يجب التحقق من الأنثى أولاً لأن كلمة female تحتوي على كلمة male
    if (lowerId.contains('female') ||
        lowerText.contains('أنثى') ||
        lowerId == '2') {
      return Icons.female;
    } else if (lowerId.contains('male') ||
        lowerText.contains('ذكر') ||
        lowerId == '1') {
      return Icons.male;
    }
    return Icons.transgender;
  }

  String _getItemId(dynamic item) {
    if (item is String) return item;
    if (item is Map) return item['id']?.toString() ?? "";
    try {
      return item.id.toString();
    } catch (_) {
      return item.toString();
    }
  }

  String _getItemText(dynamic item) {
    if (item is String) return item;
    if (item is Map) {
      return item['nameAr'] ??
          item['name_ar'] ??
          item['arName'] ??
          item['ar_name'] ??
          item['name'] ??
          "";
    }
    try {
      return (item as dynamic).nameAr ??
          (item as dynamic).arName ??
          (item as dynamic).nameEn ??
          (item as dynamic).name ??
          "";
    } catch (_) {
      return item.toString();
    }
  }
}
