import 'dart:developer';
import 'dart:io';

import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/repositories/auth_repository.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  final registrationData = <String, dynamic>{}.obs;
  final extraData = <String, dynamic>{}.obs;
  final selectedFiles = <String, List<File>>{}.obs;
  String registrationPassword = "";

  final RxnString emailError = RxnString();
  final RxnString passwordError = RxnString();
  final RxnString generalError = RxnString();

  User? get currentUser => _repository.currentUser;

  void clearErrors() {
    emailError.value = null;
    passwordError.value = null;
    generalError.value = null;
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    clearErrors();
    try {
      bool success = await _repository.login(email, password);
      isLoggedIn.value = success;
      return success;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      generalError.value = "فشل تسجيل الدخول. تأكد من اتصالك بالإنترنت";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registerFinal() async {
    isLoading.value = true;
    clearErrors();
    try {
      final userModel = UserDocumentModel(
        firstName: registrationData['firstName'] ?? "",
        lastName: registrationData['lastName'] ?? "",
        email: registrationData['email'] ?? "",
        phone: registrationData['phone'] ?? "",
        wilaya: registrationData['wilaya'] ?? "",
        commune: registrationData['commune'] ?? "",
        userTypeId: registrationData['userType'] ?? "",
        address: registrationData['address'] ?? "",
        data: Map<String, dynamic>.from(extraData),
        profileCompleted: true,
        registrationStep: 'completed',
      );

      bool success = await _repository.register(
        password: registrationPassword,
        userData: userModel,
      );

      if (success && currentUser != null) {
        final uid = currentUser!.uid;
        Map<String, dynamic> filesMap = {};

        if (selectedFiles.isNotEmpty) {
          final dataController = Get.find<DataController>();

          for (var entry in selectedFiles.entries) {
            final fieldName = entry.key;
            final files = entry.value;
            final List<String> urlsForField = [];

            final field = dataController.dynamicFields.firstWhereOrNull(
              (f) => f['fieldName'] == fieldName,
            );
            final fieldLabel =
                field?['fieldLabel_ar'] ?? field?['fieldLabel'] ?? fieldName;

            for (var file in files) {
              final fileName = file.path.split(Platform.pathSeparator).last;
              final String url = await _repository.uploadRegistrationFile(
                userId: uid,
                file: file,
                fieldName: fieldName,
                fileName: fileName,
              );
              urlsForField.add(url);
            }

            // New structured file data for the 'files' map inside user data
            filesMap[fieldName] = {
              'urls': urlsForField,
              'label': fieldLabel,
              'status': 'pending',
              'rejectionReason': '',
              'type': field?['fieldType'] ?? 'file',
              'lastUpdated': DateTime.now().toIso8601String(),
            };
          }
        }

        // Finalize profile with files included in the 'data' map
        await _repository.updateProfile(
          data: {'files': filesMap},
          isCompleted: true,
        );

        PrefManager.isProfileCompleted = true;
        PrefManager.registrationStep = 'completed';
        PrefManager.rememberLogin = true;
        isLoggedIn.value = true;
      }
      return success;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      print("Register Error: $e");
      generalError.value = "حدث خطأ غير متوقع أثناء إتمام التسجيل";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        emailError.value = "البريد الإلكتروني غير صحيح";
        break;
      case 'user-not-found':
        emailError.value = "المستخدم غير موجود";
        break;
      case 'wrong-password':
        passwordError.value = "كلمة المرور غير صحيحة";
        break;
      case 'email-already-in-use':
        emailError.value = "البريد الإلكتروني مستخدم بالفعل";
        break;
      case 'weak-password':
        passwordError.value = "كلمة المرور ضعيفة جداً";
        break;
      default:
        generalError.value = "حدث خطأ: ${e.message}";
    }
  }

  void logout() async {
    await _repository.logout();
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }

  Future<void> fetchUserProfile() async {
    try {
      await _repository.fetchUserProfile();
    } catch (e) {
      log("Profile Fetch Error: $e");
    }
  }

  Future<bool> updateProfile({
    required Map<String, dynamic> data,
    bool isCompleted = false,
    String? nextStep,
  }) async {
    isLoading.value = true;
    try {
      await _repository.updateProfile(
        data: data,
        isCompleted: isCompleted,
        nextStep: nextStep,
      );
      return true;
    } catch (e) {
      log("Update Profile Error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
