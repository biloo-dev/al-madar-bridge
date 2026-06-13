import 'dart:async';

import 'package:al_madar_bridge/Models_2/requests.dart';
import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/models/locations.dart';
import 'package:al_madar_bridge/models/user_types.dart';
import 'package:al_madar_bridge/repositories/data_repository.dart';
import 'package:al_madar_bridge/services/notification_service.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataController extends GetxController {
  final DataRepository _repository = DataRepository();

  // Observable Data
  final RxList<UserFileDocument> userFiles = <UserFileDocument>[].obs;
  final RxList<NewsDocument> newsList = <NewsDocument>[].obs;
  final RxList<UserTypeModel> userTypes = <UserTypeModel>[].obs;
  final RxList<WilayaModel> wilayas = <WilayaModel>[].obs;
  final RxList<CommuneModel> communes = <CommuneModel>[].obs;
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;
  final RxList<ProjectStatusModel> projectStatuses = <ProjectStatusModel>[].obs;
  final RxList<Map<String, dynamic>> dynamicFields =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> onboardingPages =
      <Map<String, dynamic>>[].obs;

  // Requests Data
  final RxList<RequestDocument> myRequests = <RequestDocument>[].obs;
  final RxList<RequestDocument> publicRequests = <RequestDocument>[].obs;
  final RxList<RequestType> requestTypes = <RequestType>[].obs;

  // Categories
  final RxList<Map<String, dynamic>> contractorCategories =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> contractorClasses =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> genders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> salaryRanges =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> educationLevels =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> crafts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> equipments = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> investmentTypes =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> supplierCategories =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> supplierSubcategories =
      <Map<String, dynamic>>[].obs;

  // Extra fields
  final RxList<Map<String, dynamic>> offerTypes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> equipmentConditions =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _deplomeDTP = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> investmentBudgetRanges =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> investmentDurations =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> riskLevels = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> returnTypes = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> skills = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> availabilities =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> languages = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> drivingLicenseTypes =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> metiers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> equipmentCategoriesList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> equipmentTransactionTypes =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> workLocationTypes =
      <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get deplomeDTPData => _deplomeDTP;

  List<String> get equipmentCategories => equipmentCategoriesList
      .map((e) => (e['name_ar'] ?? e['name'] ?? '').toString())
      .toList();

  List<String> get craftsmanCategories =>
      crafts.map((e) => (e['name_ar'] ?? e['name'] ?? '').toString()).toList();

  List<String> get investmentCategories => investmentTypes
      .map((e) => (e['name_ar'] ?? e['name'] ?? '').toString())
      .toList();

  List<String> get contractorCategoriesStrings => contractorCategories
      .map((e) => (e['nameAr'] ?? e['name'] ?? '').toString())
      .toList();

  List<String> get contractorClassesStrings => contractorClasses
      .map((e) => (e['nameAr'] ?? e['name'] ?? '').toString())
      .toList();

  final RxBool isLoading = false.obs;

  StreamSubscription? _projectsSubscription;
  StreamSubscription? _newsSubscription;
  StreamSubscription? _filesSubscription;

  final Map<String, String> _lastKnownProjectStatus = {};
  final Map<String, String> _lastKnownFileStatus = {};
  final Set<String> _notifiedNewsIds = {};

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchUserTypes(),
        fetchWilayas(),
        fetchAllCategories(),
        fetchProjectStatuses(),
        fetchOnboarding(),
        fetchRequestTypes(),
        fetchMyRequests(),
        fetchPublicRequests(),
      ]);

      listenToNews();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final authController = Get.find<AuthController>();
        await authController.fetchUserProfile();

        final uType = PrefManager.userType;
        if (uType.isNotEmpty) {
          await fetchDynamicFields("${uType}_fields");
        }

        listenToUserFiles();
        listenToProjects();
      }
    } catch (e) {
      print('Initial Fetch Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllCategories() async {
    final results = await Future.wait([
      _repository.getCollectionData('contractorCategories'),
      _repository.getCollectionData('contractorClasses'),
      _repository.getCollectionData('genders'),
      _repository.getCollectionData('educationLevels'),
      _repository.getCollectionData('crafts'),
      _repository.getCollectionData('equipments'),
      _repository.getCollectionData('investmentTypes'),
      _repository.getCollectionData('supplierCategories'),
      _repository.getCollectionData('supplierSubCategories'),
      _repository.getCollectionData('offerTypes'),
      _repository.getCollectionData('equipmentConditions'),
      _repository.getCollectionData('deplomeDTP'),
      _repository.getCollectionData('investmentBudgetRanges'),
      _repository.getCollectionData('investmentDurations'),
      _repository.getCollectionData('riskLevels'),
      _repository.getCollectionData('returnTypes'),
      _repository.getCollectionData('skills'),
      _repository.getCollectionData('availabilities'),
      _repository.getCollectionData('languages'),
      _repository.getCollectionData('drivingLicenseTypes'),
      _repository.getCollectionData('metiers'),
      _repository.getCollectionData('equipmentCategories'),
      _repository.getCollectionData('equipmentTransactionTypes'),
      _repository.getCollectionData('workLocationTypes'),
    ]);

    contractorCategories.assignAll(results[0]);
    contractorClasses.assignAll(results[1]);
    genders.assignAll(results[2]);
    educationLevels.assignAll(results[3]);
    crafts.assignAll(results[4]);
    equipments.assignAll(results[5]);
    investmentTypes.assignAll(results[6]);
    supplierCategories.assignAll(results[7]);
    supplierSubcategories.assignAll(results[8]);
    offerTypes.assignAll(results[9]);
    equipmentConditions.assignAll(results[10]);
    _deplomeDTP.assignAll(results[11]);
    investmentBudgetRanges.assignAll(results[12]);
    investmentDurations.assignAll(results[13]);
    riskLevels.assignAll(results[14]);
    returnTypes.assignAll(results[15]);
    skills.assignAll(results[16]);
    availabilities.assignAll(results[17]);
    languages.assignAll(results[18]);
    drivingLicenseTypes.assignAll(results[19]);
    metiers.assignAll(results[20]);
    equipmentCategoriesList.assignAll(results[21]);
    equipmentTransactionTypes.assignAll(results[22]);
    workLocationTypes.assignAll(results[23]);
  }

  void listenToUserFiles() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _filesSubscription?.cancel();
    _filesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((docSnapshot) {
          if (!docSnapshot.exists) return;

          final data =
              docSnapshot.data()?['data']?['files'] as Map<String, dynamic>?;
          if (data == null) {
            userFiles.clear();
            return;
          }

          final List<UserFileDocument> updatedFiles = [];
          data.forEach((fieldName, fileInfo) {
            final List<dynamic> urls = fileInfo['urls'] ?? [];
            final status = fileInfo['status'] ?? 'pending';
            // تعريب التسمية: محاولة الجلب من الحقول الديناميكية أولاً
            final dynamicField = dynamicFields.firstWhereOrNull(
              (f) => f['fieldName'] == fieldName,
            );
            final label =
                dynamicField?['fieldLabel_ar'] ??
                dynamicField?['fieldLabel'] ??
                fileInfo['label'] ??
                fieldName;
            final rejectionReason = fileInfo['rejectionReason'] ?? '';

            final lastStatus = _lastKnownFileStatus[fieldName];
            if (lastStatus != null && lastStatus != status) {
              String message = "";
              if (status == 'approved') {
                message = "تمت الموافقة على مستند: $label";
              } else if (status == 'rejected') {
                message = "تم رفض مستند: $label. السبب: $rejectionReason";
              }

              if (message.isNotEmpty) {
                NotificationService.showNotification(
                  id: fieldName.hashCode,
                  title: "تحديث حالة الأرشيف",
                  body: message,
                );
              }
            }
            _lastKnownFileStatus[fieldName] = status;

            for (var url in urls) {
              updatedFiles.add(
                UserFileDocument(
                  fileName: url.toString().split('?').first.split('%2F').last,
                  fileCategory: label,
                  fileExtension: url.toString().contains('.pdf')
                      ? 'pdf'
                      : 'jpg',
                  fileUrl: url.toString(),
                  rejectionReason: rejectionReason,
                  uploadedAt: fileInfo['lastUpdated'] ?? 'الآن',
                  status: status,
                  fieldName: fieldName,
                ),
              );
            }
          });

          userFiles.assignAll(updatedFiles);
        });
  }

  Future<void> fetchDynamicFields(String userTypeId) async {
    try {
      dynamicFields.assignAll(await _repository.getDynamicFields(userTypeId));
    } catch (e) {
      print('Dynamic Fields Fetch Error: $e');
    }
  }

  Future<void> fetchWilayas() async {
    final data = await _repository.getCollectionData('wilaya');
    final list = data.map((e) => WilayaModel.fromJson(e)).toList();
    list.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));
    wilayas.assignAll(list);
  }

  Future<void> fetchCommunes(String wilayaId) async {
    final data = await _repository.getCommunesByWilaya(wilayaId);
    final list = data.map((e) => CommuneModel.fromJson(e)).toList();
    list.sort((a, b) => a.nameAr.compareTo(b.nameAr));
    communes.assignAll(list);
  }

  Future<List<CommuneModel>> getCommunesForWilaya(String wilayaId) async {
    final data = await _repository.getCommunesByWilaya(wilayaId);
    final list = data.map((e) => CommuneModel.fromJson(e)).toList();
    list.sort((a, b) => a.nameAr.compareTo(b.nameAr));
    return list;
  }

  Future<void> fetchUserTypes() async {
    final data = await _repository.getCollectionData('user_types');
    userTypes.assignAll(data.map((e) => UserTypeModel.fromJson(e)).toList());
  }

  Future<void> fetchOnboarding() async {
    final data = await _repository.getCollectionData('onboarding');
    data.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
    onboardingPages.assignAll(data);
  }

  Future<void> fetchProjectStatuses() async {
    final data = await _repository.getCollectionData('projectsStatus');
    projectStatuses.assignAll(
      data.map((e) => ProjectStatusModel.fromMap(e, e['id'])).toList(),
    );
  }

  Future<void> fetchUserFiles() async {
    try {
      userFiles.assignAll(await _repository.getUserFiles());
    } catch (e) {
      print('User Files Fetch Error: $e');
    }
  }

  Future<void> fetchMyRequests() async {
    try {
      myRequests.assignAll(await _repository.getMyRequests());
    } catch (e) {
      print('My Requests Fetch Error: $e');
    }
  }

  Future<void> fetchPublicRequests() async {
    try {
      publicRequests.assignAll(await _repository.getPublicRequests());
    } catch (e) {
      print('Public Requests Fetch Error: $e');
    }
  }

  Future<void> fetchRequestTypes() async {
    try {
      final types = await _repository.getRequestTypes();
      if (types.isEmpty) {
        // Fallback or seeding logic if Firestore is empty
        requestTypes.assignAll([
          RequestType(id: 'worker_request', nameAr: 'طلب عمال', nameFr: 'Demande de main-d\'œuvre', icon: 'groups'),
          RequestType(id: 'equipment_request', nameAr: 'طلب معدات', nameFr: 'Demande d\'équipement', icon: 'construction'),
          RequestType(id: 'supplier_request', nameAr: 'طلب مواد أو خدمات', nameFr: 'Demande de fournitures', icon: 'inventory'),
          RequestType(id: 'investment_request', nameAr: 'طلب استثمار', nameFr: 'Demande d\'investissement', icon: 'trending_up'),
          RequestType(id: 'transport_request', nameAr: 'طلب نقل', nameFr: 'Demande de transport', icon: 'local_shipping'),
          RequestType(id: 'accommodation_request', nameAr: 'طلب إقامة', nameFr: 'Demande d\'hébergement', icon: 'hotel'),
          RequestType(id: 'real_estate_request', nameAr: 'طلب عقار', nameFr: 'Demande immobilière', icon: 'home_work'),
        ]);
      } else {
        requestTypes.assignAll(types);
      }
    } catch (e) {
      print('Request Types Fetch Error: $e');
    }
  }

  Future<bool> createRequest(RequestDocument request, Map<String, dynamic> attributes) async {
    isLoading.value = true;
    try {
      await _repository.createRequest(request, attributes);
      await fetchMyRequests();
      return true;
    } catch (e) {
      print('Create Request Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> uploadFileWithMeta(
    dynamic file,
    String name,
    String label,
    String fieldName,
  ) async {
    return await _repository.uploadUserFile(
      file: file,
      fileName: name,
      fieldLabel: label,
      fieldName: fieldName,
    );
  }

  void listenToNews() {
    _newsSubscription?.cancel();
    _newsSubscription = FirebaseFirestore.instance
        .collection('news')
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          final updatedNews = snapshot.docs
              .map((doc) => NewsDocument.fromMap(doc.data(), doc.id))
              .toList();

          if (newsList.isNotEmpty) {
            for (var news in updatedNews) {
              if (!newsList.any((existing) => existing.id == news.id) &&
                  !_notifiedNewsIds.contains(news.id)) {
                NotificationService.showNotification(
                  id: news.id.hashCode,
                  title: news.title,
                  body: news.summary.isNotEmpty
                      ? news.summary
                      : "خبر جديد من المدار",
                  imageUrl: news.featuredImage,
                );
                _notifiedNewsIds.add(news.id);
              }
            }
          } else {
            for (var news in updatedNews) _notifiedNewsIds.add(news.id);
          }
          newsList.assignAll(updatedNews);
        });
  }

  void listenToProjects() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _projectsSubscription?.cancel();
    _projectsSubscription = FirebaseFirestore.instance
        .collection('projects')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          final updatedProjects = snapshot.docs
              .map((doc) => ProjectModel.fromMap(doc.data(), doc.id))
              .toList();

          for (var project in updatedProjects) {
            final lastStatus = _lastKnownProjectStatus[project.id];
            if (lastStatus != null && lastStatus != project.status) {
              final statusInfo = projectStatuses.firstWhereOrNull(
                (s) => s.id == project.status,
              );
              NotificationService.showNotification(
                id: project.id.hashCode,
                title: "تحديث في المشروع",
                body:
                    "المشروع '${project.projectName}' أصبح بحالة: ${statusInfo?.nameAr ?? project.status}",
              );
            }
            _lastKnownProjectStatus[project.id] = project.status;
          }
          projects.assignAll(updatedProjects);
        });
  }

  Future<void> incrementNewsViews(String newsId) async =>
      await _repository.incrementNewsViews(newsId);

  Future<bool> toggleNewsLike(String newsId) async =>
      await _repository.toggleNewsLike(newsId);

  Future<bool> isNewsLiked(String newsId) async =>
      await _repository.isNewsLiked(newsId);

  Future<void> deleteUserFile(String fieldName, String fileUrl) async {
    isLoading.value = true;
    try {
      await _repository.deleteUserFile(fieldName: fieldName, fileUrl: fileUrl);
      Get.snackbar(
        "نجاح",
        "تم حذف الملف بنجاح",
        backgroundColor: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "فشل حذف الملف: $e",
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _projectsSubscription?.cancel();
    _newsSubscription?.cancel();
    _filesSubscription?.cancel();
    super.onClose();
  }
}
