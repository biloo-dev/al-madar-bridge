import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContractorProjectTab extends StatelessWidget {
  const ContractorProjectTab({super.key});

  @override
  Widget build(BuildContext context) {
    final DataController dataController = Get.find<DataController>();

    return Obx(() {
      if (dataController.isLoading.value && dataController.projects.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (dataController.projects.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.engineering_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("لا توجد مشاريع مسجلة حالياً", style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dataController.projects.length,
        itemBuilder: (context, idx) {
          final project = dataController.projects[idx];
          final statusInfo = dataController.projectStatuses.firstWhereOrNull(
            (s) => s.id == project.status,
          );

          return Card(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _getColor(statusInfo?.color).withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIcon(statusInfo?.icon),
                        color: _getColor(statusInfo?.color),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusInfo?.nameAr ?? project.status,
                        style: TextStyle(
                          color: _getColor(statusInfo?.color),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "ID: ${project.id}",
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.projectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.layers_outlined, "الحصة:", project.part),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow(
                              Icons.calendar_today_outlined,
                              "البداية:",
                              project.dateStart,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoRow(
                              Icons.event_available_outlined,
                              "الاستلام:",
                              project.dateReceipt,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLocationChip(project.wilayaId, project.communeId, dataController),
                          Text(
                            "نهاية المشروع: ${project.dateEnd}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildLocationChip(String wilayaId, String communeId, DataController controller) {
    final wilaya = controller.wilayas.firstWhereOrNull((w) => w.id == wilayaId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 12, color: AppTheme.primaryBlue),
          const SizedBox(width: 4),
          Text(
            wilaya?.nameAr ?? "ولاية $wilayaId",
            style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }

  Color _getColor(String? colorStr) {
    switch (colorStr?.toLowerCase()) {
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      case 'blue': return Colors.blue;
      default: return Colors.blueGrey;
    }
  }

  IconData _getIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'account_balance': return Icons.account_balance;
      case 'pending': return Icons.hourglass_top;
      case 'active': return Icons.play_circle_outline;
      case 'completed': return Icons.task_alt;
      case 'rejected': return Icons.cancel_outlined;
      default: return Icons.engineering;
    }
  }
}
