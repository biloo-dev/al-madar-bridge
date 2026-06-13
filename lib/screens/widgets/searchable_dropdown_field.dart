import 'package:al_madar_bridge/screens/widgets/searchable_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchableDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final List<dynamic> items;
  final dynamic selectedValue; // String for single, List for multi
  final bool isMultiSelect;
  final Function(dynamic) onChanged;
  final bool isLoading;
  final String? errorText;

  const SearchableDropdownField({
    super.key,
    required this.label,
    this.hint = "",
    required this.icon,
    required this.items,
    this.selectedValue,
    this.isMultiSelect = false,
    required this.onChanged,
    this.isLoading = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
        InkWell(
          onTap: isLoading ? null : () => _showPicker(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: isLoading
                      ? const Text(
                          "جاري التحميل...",
                          style: TextStyle(color: Colors.grey),
                        )
                      : _buildValueDisplay(),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 16),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildValueDisplay() {
    if (isMultiSelect) {
      final List<dynamic> list = selectedValue is List ? selectedValue : [];
      if (list.isEmpty) {
        return Text(
          hint.isNotEmpty ? hint : "اختر...",
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        );
      }

      // Show only up to 2 chips then (+X others)
      const int maxVisible = 2;
      final visibleItems = list.take(maxVisible).toList();
      final extraCount = list.length - visibleItems.length;

      return Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...visibleItems.map((id) {
            final item = items.firstWhereOrNull(
              (e) => _getItemId(e) == id.toString(),
            );
            final text = item != null ? _getItemText(item) : id.toString();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
          if (extraCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "(+$extraCount أخرى)",
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      );
    } else {
      if (selectedValue == null || selectedValue.toString().isEmpty) {
        return Text(
          hint.isNotEmpty ? hint : "اختر...",
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        );
      }
      final item = items.firstWhereOrNull(
        (e) => _getItemId(e) == selectedValue.toString(),
      );
      final text = item != null ? _getItemText(item) : selectedValue.toString();
      return Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  void _showPicker(BuildContext context) {
    List<dynamic> currentSelection;
    if (isMultiSelect) {
      currentSelection = selectedValue is List ? selectedValue : [];
    } else {
      currentSelection = [selectedValue?.toString() ?? ""];
    }

    Get.bottomSheet(
      SearchablePicker(
        title: label,
        items: items,
        isMultiSelect: isMultiSelect,
        selectedIds: currentSelection,
        onSelect: onChanged,
      ),
      isScrollControlled: true,
    );
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
