import 'dart:io';

import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/screens/widgets/BuildCard.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Approval status enum — maps to the `status` field in UserFileDocument
// Expected Firestore values: "approved" | "rejected" | "pending" (or null)
// ─────────────────────────────────────────────────────────────────────────────
enum FileApprovalStatus { approved, rejected, pending }

extension FileApprovalStatusX on String? {
  FileApprovalStatus toApprovalStatus() {
    switch (this?.toLowerCase()) {
      case 'approved':
        return FileApprovalStatus.approved;
      case 'rejected':
        return FileApprovalStatus.rejected;
      default:
        return FileApprovalStatus.pending;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper: derive the card-level approval status from a list of files.
//   • All approved           → approved
//   • Any rejected           → rejected
//   • Mix of approved+pending → pending
//   • All pending / empty    → pending
// ─────────────────────────────────────────────────────────────────────────────
FileApprovalStatus _cardStatus(List<UserFileDocument> files) {
  if (files.isEmpty) return FileApprovalStatus.pending;
  final statuses = files.map((f) => (f.status).toApprovalStatus()).toSet();
  if (statuses.contains(FileApprovalStatus.rejected)) {
    return FileApprovalStatus.rejected;
  }
  if (statuses.every((s) => s == FileApprovalStatus.approved)) {
    return FileApprovalStatus.approved;
  }
  return FileApprovalStatus.pending;
}

// ─────────────────────────────────────────────────────────────────────────────
// Styling helpers per status
// ─────────────────────────────────────────────────────────────────────────────
class _StatusStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  final String label;

  const _StatusStyle({
    required this.bg,
    required this.fg,
    required this.icon,
    required this.label,
  });
}

_StatusStyle _statusStyle(FileApprovalStatus s) {
  switch (s) {
    case FileApprovalStatus.approved:
      return const _StatusStyle(
        bg: Color(0xFFE8F5E9),
        fg: Color(0xFF2E7D32),
        icon: Icons.verified_rounded,
        label: 'تمت الموافقة',
      );
    case FileApprovalStatus.rejected:
      return const _StatusStyle(
        bg: Color(0xFFFFEBEE),
        fg: Color(0xFFC62828),
        icon: Icons.cancel_rounded,
        label: 'مرفوض',
      );
    case FileApprovalStatus.pending:
      return const _StatusStyle(
        bg: Color(0xFFFFF8E1),
        fg: Color(0xFFF57F17),
        icon: Icons.hourglass_top_rounded,
        label: 'قيد المراجعة',
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main widget
// ─────────────────────────────────────────────────────────────────────────────
class ArchiveTab extends StatefulWidget {
  const ArchiveTab({super.key});

  @override
  State<ArchiveTab> createState() => _ArchiveTabState();
}

class _ArchiveTabState extends State<ArchiveTab> {
  final DataController _dataController = Get.find<DataController>();
  final ImagePicker _picker = ImagePicker();
  final Map<String, bool> _uploadingStates = {};

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_dataController.isLoading.value &&
          _dataController.dynamicFields.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      final fileFields = _dataController.dynamicFields
          .where((f) => ["file", "multi_file"].contains(f['fieldType']))
          .toList();

      if (fileFields.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "لا توجد متطلبات ملفات لهذا النوع",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        color: Colors.grey[200],
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          // حشو سفلي لمنع تداخل شريط التنقل مع المحتوى
          child: Column(
            children: fileFields.map((field) {
              final fieldName = field['fieldName'];
              final bool isMulti = field['fieldType'] == 'multi_file';
              final uploadedFiles = _dataController.userFiles
                  .where(
                    (f) =>
                        f.fieldName == fieldName ||
                        f.fileCategory == field['fieldLabel_ar'] ||
                        f.fileCategory == field['fieldLabel'],
                  )
                  .toList();

              final isUploading = _uploadingStates[fieldName] ?? false;
              final bool hasFile = uploadedFiles.isNotEmpty;
              final bool isSingle = !isMulti;
              final cardStatus = _cardStatus(uploadedFiles);
              final style = _statusStyle(
                hasFile ? cardStatus : FileApprovalStatus.pending,
              );

              // When approved → lock uploads (can't replace an approved doc)
              final bool isApproved = cardStatus == FileApprovalStatus.approved;

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _ApprovalBorderWrap(
                  status: hasFile ? cardStatus : null,
                  child: BuildCard(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // ── Header row ───────────────────────────────────────────
                      Row(
                        children: [
                          // Status icon
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: style.bg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(style.icon, color: style.fg, size: 22),
                          ),
                          const SizedBox(width: 14),
                          // Title + badges row
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  field['fieldLabel_ar'] ??
                                      field['fieldLabel'] ??
                                      "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    // Type badge
                                    _Pill(
                                      label: isMulti ? 'متعدد' : 'ملف واحد',
                                      bg: isMulti
                                          ? AppTheme.accentOrange.withOpacity(
                                              0.1,
                                            )
                                          : AppTheme.primaryBlue.withOpacity(
                                              0.1,
                                            ),
                                      fg: isMulti
                                          ? AppTheme.accentOrange
                                          : AppTheme.primaryBlue,
                                    ),
                                    // Approval status badge (only when files exist)
                                    if (hasFile)
                                      _Pill(
                                        label: style.label,
                                        bg: style.bg,
                                        fg: style.fg,
                                        icon: style.icon,
                                      ),
                                    // File count
                                    if (hasFile)
                                      Text(
                                        '${uploadedFiles.length} ملف',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    else
                                      Text(
                                        'بانتظار الرفع',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[400],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // ── Action buttons ──────────────────────────────────
                          if (isUploading)
                            const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (isApproved)
                            // Approved → show only preview, no upload
                            _ActionIconButton(
                              icon: Icons.preview_rounded,
                              color: const Color(0xFF2E7D32),
                              tooltip: 'معاينة',
                              onTap: () => _openFile(uploadedFiles.first),
                            )
                          else if (!hasFile)
                            _ActionIconButton(
                              icon: Icons.add_photo_alternate_rounded,
                              color: AppTheme.primaryBlue,
                              tooltip: 'إضافة ملف',
                              onTap: () => _handleUpload(field),
                            )
                          else if (isSingle)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ActionIconButton(
                                  icon: Icons.preview_rounded,
                                  color: AppTheme.primaryBlue,
                                  tooltip: 'معاينة',
                                  onTap: () => _openFile(uploadedFiles.first),
                                ),
                                const SizedBox(width: 6),
                                _ActionIconButton(
                                  icon: Icons.refresh_rounded,
                                  color: AppTheme.accentOrange,
                                  tooltip: 'استبدال الملف',
                                  onTap: () => _handleUpload(field),
                                ),
                              ],
                            )
                          else
                            _ActionIconButton(
                              icon: Icons.add_photo_alternate_rounded,
                              color: AppTheme.accentOrange,
                              tooltip: 'إضافة ملفات',
                              onTap: () => _handleUpload(field),
                            ),
                        ],
                      ),

                      // ── Rejection reason banner ──────────────────────────────
                      if (cardStatus == FileApprovalStatus.rejected) ...[
                        const SizedBox(height: 14),
                        _RejectionBanner(files: uploadedFiles),
                      ],

                      // ── File grid ────────────────────────────────────────────
                      if (hasFile) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF0F0F0)),
                        const SizedBox(height: 12),
                        GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                        itemCount: uploadedFiles.length,
                        itemBuilder: (context, fIdx) {
                          final file = uploadedFiles[fIdx];
                          return _FileGridItem(
                            file: file,
                            onTap: () => _openFile(file),
                            onDelete: () => _confirmDelete(file),
                          );
                        },
                      ),
                      ] else ...[
                        const SizedBox(height: 18),
                        _EmptyFilePlaceholder(
                          isMulti: isMulti,
                          onTap: () => _handleUpload(field),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Future<void> _handleUpload(Map<String, dynamic> field) async {
    final bool isMulti = field['fieldType'] == 'multi_file';

    final source = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _BottomSheetTile(
                icon: Icons.camera_alt_rounded,
                label: 'التقاط صورة',
                color: AppTheme.primaryBlue,
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              _BottomSheetTile(
                icon: Icons.photo_library_rounded,
                label: isMulti ? 'المعرض (اختيار متعدد)' : 'المعرض',
                color: AppTheme.primaryBlue,
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              _BottomSheetTile(
                icon: Icons.picture_as_pdf_rounded,
                label: 'مستندات PDF',
                color: Colors.redAccent,
                onTap: () => Navigator.pop(context, 'pdf'),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    List<File> filesToUpload = [];

    if (source == 'camera') {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) filesToUpload.add(File(image.path));
    } else if (source == 'gallery') {
      if (isMulti) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
        );
        if (result != null) {
          filesToUpload.addAll(
            result.paths.where((p) => p != null).map((p) => File(p!)),
          );
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) filesToUpload.add(File(image.path));
      }
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: isMulti,
      );
      if (result != null) {
        filesToUpload.addAll(
          result.paths.where((p) => p != null).map((p) => File(p!)),
        );
      }
    }

    if (filesToUpload.isNotEmpty) {
      setState(() => _uploadingStates[field['fieldName']] = true);
      try {
        for (var file in filesToUpload) {
          final fileName = file.path.split(Platform.pathSeparator).last;
          await _dataController.uploadFileWithMeta(
            file,
            fileName,
            field['fieldLabel_ar'] ?? field['fieldLabel'] ?? "",
            field['fieldName'],
          );
        }
        Get.snackbar(
          "نجاح",
          "تم التحديث بنجاح",
          backgroundColor: Colors.white,
          colorText: const Color(0xFF1A1A2E),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF43A047),
          ),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
        );
        await _dataController.fetchUserFiles();
      } catch (e) {
        Get.snackbar(
          "خطأ",
          "فشل الرفع: $e",
          backgroundColor: Colors.white,
          colorText: const Color(0xFF1A1A2E),
          icon: const Icon(Icons.error_rounded, color: Colors.redAccent),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
        );
      } finally {
        setState(() => _uploadingStates[field['fieldName']] = false);
      }
    }
  }

  void _openFile(UserFileDocument file) {
    final ext = file.fileExtension.toLowerCase();
    if (ext == 'pdf') {
      Get.to(
        () => Scaffold(
          appBar: AppBar(
            title: Text(file.fileCategory),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
          ),
          body: const PDF().cachedFromUrl(file.fileUrl),
        ),
      );
    } else {
      Get.to(
        () => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(file.fileCategory),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                file.fileUrl,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const CircularProgressIndicator(color: Colors.white);
                },
              ),
            ),
          ),
        ),
      );
    }
  }

  void _confirmDelete(UserFileDocument file) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("تأكيد الحذف", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("هل أنت متأكد من رغبتك في حذف هذا الملف نهائياً من النظام؟"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _dataController.deleteUserFile(file.fieldName ?? "", file.fileUrl);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("تأكيد الحذف"),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ApprovalBorderWrap — wraps the card with a colored left-border accent
// when a status is present
// ─────────────────────────────────────────────────────────────────────────────
class _ApprovalBorderWrap extends StatelessWidget {
  const _ApprovalBorderWrap({required this.child, required this.status});

  final Widget child;
  final FileApprovalStatus? status;

  @override
  Widget build(BuildContext context) {
    if (status == null) return child;
    Color borderColor;
    switch (status!) {
      case FileApprovalStatus.approved:
        borderColor = const Color(0xFF43A047);
        break;
      case FileApprovalStatus.rejected:
        borderColor = const Color(0xFFC62828);
        break;
      case FileApprovalStatus.pending:
        borderColor = const Color(0xFFFFA000);
        break;
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: borderColor, width: 4)),
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RejectionBanner — shown inside the card when status == rejected
// ─────────────────────────────────────────────────────────────────────────────
class _RejectionBanner extends StatelessWidget {
  const _RejectionBanner({required this.files});

  final List<UserFileDocument> files;

  @override
  Widget build(BuildContext context) {
    // Collect unique rejection reasons from all rejected files
    final reasons = files
        .where((f) => f.status?.toLowerCase() == 'rejected')
        .map((f) => f.rejectionReason)
        .where((r) => r != null && r.isNotEmpty)
        .toSet()
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF9A9A), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFC62828),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'سبب الرفض',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC62828),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reasons.isNotEmpty
                      ? reasons.join(' • ')
                      : 'يرجى مراجعة الملف وإعادة رفعه',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7B1B1B),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FileGridItem — thumbnail with approval badge overlay per file
// ─────────────────────────────────────────────────────────────────────────────
class _FileGridItem extends StatelessWidget {
  const _FileGridItem({required this.file, required this.onTap, required this.onDelete});

  final UserFileDocument file;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isImage = [
      'jpg',
      'jpeg',
      'png',
    ].contains(file.fileExtension.toLowerCase());
    final fileStatus = (file.status).toApprovalStatus();

    // Per-file status badge color
    Color badgeBg;
    Color badgeFg;
    IconData badgeIcon;
    switch (fileStatus) {
      case FileApprovalStatus.approved:
        badgeBg = const Color(0xFF43A047);
        badgeFg = Colors.white;
        badgeIcon = Icons.check_rounded;
        break;
      case FileApprovalStatus.rejected:
        badgeBg = const Color(0xFFC62828);
        badgeFg = Colors.white;
        badgeIcon = Icons.close_rounded;
        break;
      case FileApprovalStatus.pending:
        badgeBg = const Color(0xFFFFA000);
        badgeFg = Colors.white;
        badgeIcon = Icons.hourglass_top_rounded;
        break;
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail background
                if (isImage)
                  Image.network(
                    file.fileUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    color: const Color(0xFFFFF3F3),
                    child: const Center(
                      child: Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                    ),
                  ),

                // Bottom overlay: preview label
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    color: Colors.black.withOpacity(0.38),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.open_in_full_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'معاينة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top-left: approval status badge
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(badgeIcon, color: badgeFg, size: 11)],
                    ),
                  ),
                ),

                // Border overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Delete button floating at top-right
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.redAccent,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Pill — small badge chip
// ─────────────────────────────────────────────────────────────────────────────
class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });

  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 11),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ActionIconButton
// ─────────────────────────────────────────────────────────────────────────────
class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyFilePlaceholder
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyFilePlaceholder extends StatelessWidget {
  const _EmptyFilePlaceholder({required this.isMulti, required this.onTap});

  final bool isMulti;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DashedBorderContainer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_photo_alternate_rounded,
              size: 36,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              isMulti ? 'اضغط لإضافة صور أو ملفات' : 'اضغط لإضافة ملف',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isMulti) ...[
              const SizedBox(height: 4),
              Text(
                'يمكن رفع أكثر من ملف',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DashedBorderContainer
// ─────────────────────────────────────────────────────────────────────────────
class DashedBorderContainer extends StatelessWidget {
  const DashedBorderContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 6;
    const double dashSpace = 5;
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(14),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomSheetTile
// ─────────────────────────────────────────────────────────────────────────────
class _BottomSheetTile extends StatelessWidget {
  const _BottomSheetTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
