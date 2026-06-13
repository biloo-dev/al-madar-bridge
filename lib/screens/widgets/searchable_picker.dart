import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchablePicker extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final List<dynamic> selectedIds;
  final bool isMultiSelect;
  final Function(dynamic) onSelect;

  const SearchablePicker({
    super.key,
    required this.title,
    required this.items,
    this.selectedIds = const [],
    this.isMultiSelect = false,
    required this.onSelect,
  });

  @override
  State<SearchablePicker> createState() => _SearchablePickerState();
}

class _SearchablePickerState extends State<SearchablePicker> {
  late List<dynamic> _tempSelectedIds;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // تحويل كل المعرفات إلى نصوص لتوحيد المقارنة
    _tempSelectedIds = widget.selectedIds.map((e) => e.toString()).toList();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_tempSelectedIds.contains(id)) {
        _tempSelectedIds.remove(id);
      } else {
        _tempSelectedIds.add(id);
      }
    });
    // تحديث الأب مباشرة ليعكس التغيير في الواجهة الخلفية
    widget.onSelect(List.from(_tempSelectedIds));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.isMultiSelect)
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("حفظ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                else
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: "بحث سريع...",
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: Builder(builder: (context) {
              final filteredItems = widget.items.where((item) {
                final String text = _getItemText(item).toLowerCase();
                return text.contains(_searchQuery.toLowerCase());
              }).toList();

              if (filteredItems.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text("لا توجد نتائج مطابقة"),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                itemCount: filteredItems.length,
                shrinkWrap: true,
                separatorBuilder: (c, i) =>
                    const Divider(height: 1, indent: 15, endIndent: 15),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final String id = _getItemId(item);
                  final String text = _getItemText(item);
                  final bool isSelected = _tempSelectedIds.contains(id);

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    visualDensity: VisualDensity.compact,
                    title: Text(text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color:
                              isSelected ? AppTheme.primaryBlue : Colors.black87,
                        )),
                    trailing: widget.isMultiSelect
                        ? IgnorePointer(
                            child: Checkbox(
                              value: isSelected,
                              activeColor: AppTheme.primaryBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              onChanged: (_) {}, // المعالجة تتم في ListTile.onTap
                            ),
                          )
                        : (isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppTheme.primaryBlue)
                            : null),
                    onTap: () {
                      if (widget.isMultiSelect) {
                        _toggleSelection(id);
                      } else {
                        widget.onSelect(id);
                        Get.back();
                      }
                    },
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 20),
        ],
      ),
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
