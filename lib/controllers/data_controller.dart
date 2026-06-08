import 'dart:io';

import 'package:al_madar_bridge/controllers/auth_controller.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/models/user_types.dart';
import 'package:al_madar_bridge/repositories/data_repository.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:get/get.dart';

class DataController extends GetxController {
  final DataRepository _repository = DataRepository();

  var userFiles = <UserFileDocument>[].obs;
  var newsList = <NewsDocument>[].obs;
  var userTypes = <UserTypeModel>[].obs;
  var contractorCategories = <String>[].obs;
  var contractorClasses = <String>[].obs;
  var supplierCategories = <Map<String, dynamic>>[].obs;
  var supplierSubcategories = <Map<String, dynamic>>[].obs;
  var craftsmanCategories = <String>[].obs;
  var investmentCategories = <String>[].obs;
  var equipmentCategories = <String>[].obs;
  var onboardingPages = <Map<String, dynamic>>[].obs;
  var dynamicFields = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    print('🚀 Starting Firestore data fetch...');
    try {
      // 1. Fetch public data
      await fetchNews();
      await fetchUserTypes();
      await fetchCategories();
      await fetchOnboarding();

      // 2. Fetch user-specific data if logged in
      final typeId = PrefManager.userType;
      if (typeId.isNotEmpty) {
        // Wait a small bit for Firebase Auth to stabilize if needed
        int retry = 0;
        final auth = Get.find<AuthController>();
        while (auth.currentUser == null && retry < 5) {
          await Future.delayed(const Duration(milliseconds: 500));
          retry++;
        }

        await auth.fetchUserProfile();
        await fetchDynamicFields(PrefManager.userType);
        print('⚙️ Dynamic fields (${PrefManager.userType}): ${dynamicFields.length}');
        await fetchUserFiles();
        print('📄 User files: ${userFiles.length}');
      }
      print('✅ Firestore data fetch completed.');
    } catch (e) {
      print('❌ Error during initial fetch: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserFiles() async {
    if (isLoading.value && userFiles.isNotEmpty) return; // Don't interrupt full load
    
    isLoading.value = true;
    try {
      // Ensure we have dynamic fields too, as Archive depends on them
      if (dynamicFields.isEmpty && PrefManager.userType.isNotEmpty) {
        await fetchDynamicFields(PrefManager.userType);
      }
      userFiles.value = await _repository.getUserFiles();
    } catch (e) {
      print('Error fetching user files: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDynamicFields(String userTypeId) async {
    try {
      dynamicFields.value = await _repository.getDynamicFields(userTypeId);
    } catch (e) {
      print('Error fetching dynamic fields: $e');
    }
  }

  Future<String> uploadFileWithMeta(
    File file,
    String name,
    String label,
    String fieldName,
  ) async {
    final url = await _repository.uploadUserFile(
      file: file,
      fileName: name,
      fieldLabel: label,
      fieldName: fieldName,
    );
    await fetchUserFiles(); // Refresh list
    return url;
  }

  Future<void> fetchNews() async {
    if (isLoading.value && newsList.isNotEmpty) return;

    isLoading.value = true;
    try {
      newsList.value = await _repository.getNews();
    } catch (e) {
      print('Error fetching news: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserTypes() async {
    try {
      final data = await _repository.getCollectionData('user_types');
      userTypes.value = data.map((e) => UserTypeModel.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching user types: $e');
    }
  }

  Future<void> fetchOnboarding() async {
    try {
      final data = await _repository.getCollectionData('onboarding');
      if (data.isNotEmpty) {
        data.sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
        onboardingPages.value = data;
      }
    } catch (e) {
      print('Error fetching onboarding: $e');
    }
  }

  Future<void> fetchCategories() async {
    final contCat = await _repository.getCollectionData(
      'contractor_categories',
    );
    contractorCategories.value = contCat
        .map((e) => e['name'] as String)
        .toList();

    final contClass = await _repository.getCollectionData('contractor_classes');
    contractorClasses.value = contClass
        .map((e) => e['name'] as String)
        .toList();

    final suppCat = await _repository.getCollectionData('supplier_categories');
    supplierCategories.value = suppCat;

    final suppSub = await _repository.getCollectionData(
      'supplier_subcategories',
    );
    supplierSubcategories.value = suppSub;

    final craftCat = await _repository.getCollectionData(
      'craftsman_categories',
    );
    craftsmanCategories.value = craftCat
        .map((e) => e['name'] as String)
        .toList();

    final investCat = await _repository.getCollectionData(
      'investment_categories',
    );
    investmentCategories.value = investCat
        .map((e) => e['name'] as String)
        .toList();

    final equipCat = await _repository.getCollectionData(
      'equipment_categories',
    );
    equipmentCategories.value = equipCat
        .map((e) => e['name'] as String)
        .toList();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await fetchUserFiles();
      await fetchNews();
    } finally {
      isLoading.value = false;
    }
  }
}
