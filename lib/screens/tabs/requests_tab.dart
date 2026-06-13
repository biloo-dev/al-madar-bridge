import 'package:al_madar_bridge/Models_2/requests.dart';
import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  static void showCreateActionSheet(BuildContext context) {
    final userType = PrefManager.userType.toLowerCase();
    final DataController dataController = Get.find<DataController>();
    
    String title = "إضافة جديد";
    String typeLabel = "النوع";
    
    if (userType.contains('contractor') || userType.contains('مقاول')) {
      title = "إضافة طلب جديد";
    } else if (userType.contains('supplier') || userType.contains('مورد')) {
      title = "إضافة سلعة جديدة";
      typeLabel = "صنف السلعة";
    } else if (userType.contains('craftsman') || userType.contains('حرفي')) {
      title = "إضافة طلب عمل";
      typeLabel = "التخصص";
    }

    final titleController = TextEditingController();
    final descController = TextEditingController();
    String? selectedTypeId;
    String? selectedWilayaId;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: typeLabel, border: const OutlineInputBorder()),
                items: dataController.requestTypes.map((e) => DropdownMenuItem(value: e.id.toString(), child: Text(e.nameAr.toString()))).toList(),
                onChanged: (v) => selectedTypeId = v,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "العنوان", 
                  hintText: "مثلاً: مطلوب حفارة أو توفر اسمنت",
                  border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "التفاصيل", 
                  hintText: "اكتب تفاصيل طلبك أو عرضك هنا...",
                  border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "الولاية", border: OutlineInputBorder()),
                items: dataController.wilayas.map((e) => DropdownMenuItem(value: e.id.toString(), child: Text(e.nameAr.toString()))).toList(),
                onChanged: (v) => selectedWilayaId = v,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isEmpty || descController.text.isEmpty || selectedTypeId == null || selectedWilayaId == null) {
                      Get.snackbar("تنبيه", "يرجى ملء جميع الحقول", backgroundColor: Colors.orange, colorText: Colors.white);
                      return;
                    }

                    final request = RequestDocument(
                      id: '',
                      requestTypeId: selectedTypeId!,
                      createdBy: '', 
                      title: titleController.text,
                      description: descController.text,
                      wilayaId: selectedWilayaId!,
                      communeId: '',
                      status: 'pending',
                    );

                    final success = await dataController.createRequest(request, {});
                    if (success) {
                      Get.back();
                      Get.snackbar("تم بنجاح", "تم إرسال بياناتك للإدارة بنجاح", backgroundColor: Colors.green, colorText: Colors.white);
                    } else {
                      Get.snackbar("خطأ", "فشل في عملية الإرسال", backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("تأكيد الإضافة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  final DataController _dataController = Get.find<DataController>();

  @override
  void initState() {
    super.initState();
    _dataController.fetchMyRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Obx(() {
        if (_dataController.isLoading.value && _dataController.myRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_dataController.myRequests.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _dataController.fetchMyRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: _dataController.myRequests.length,
            itemBuilder: (context, index) {
              final request = _dataController.myRequests[index];
              return _buildRequestCard(request);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "لا توجد سجلات حالياً",
            style: TextStyle(fontSize: 18, color: Color(0xFF616161), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "يمكنك إضافة عنصر جديد من الزر أدناه",
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(RequestDocument request) {
    final type = _dataController.requestTypes.firstWhereOrNull((t) => t.id == request.requestTypeId);
    final statusStyle = _getStatusStyle(request.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BuildCard(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIconData(type?.icon), color: AppTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      type?.nameAr ?? "طلب",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(statusStyle),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    request.createdAt != null 
                        ? intl.DateFormat('yyyy/MM/dd').format(request.createdAt!)
                        : "قيد المعالجة",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _getWilayaName(request.wilayaId),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(Map<String, dynamic> style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style['bg'],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        style['label'],
        style: TextStyle(color: style['fg'], fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status) {
      case 'pending':
        return {'label': 'قيد المراجعة', 'bg': Colors.orange[50]!, 'fg': Colors.orange[700]!};
      case 'accepted':
        return {'label': 'مقبول', 'bg': Colors.green[50]!, 'fg': Colors.green[700]!};
      case 'rejected':
        return {'label': 'مرفوض', 'bg': Colors.red[50]!, 'fg': Colors.red[700]!};
      default:
        return {'label': status, 'bg': Colors.grey[100]!, 'fg': Colors.grey[700]!};
    }
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

  String _getWilayaName(String id) {
    final wilaya = _dataController.wilayas.firstWhereOrNull((w) => w.id == id);
    return wilaya?.nameAr ?? id;
  }
}
