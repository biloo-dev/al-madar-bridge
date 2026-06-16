import 'dart:developer';
import 'dart:io';

import 'package:al_madar_bridge/controllers/data_controller.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/repositories/auth_repository.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      bool success = await _repository.login(email.trim(), password);
      if (success) {
        isLoggedIn.value = true;
        final user = currentUser;
        if (user != null && user.emailVerified) {
          await _repository.updateEmailVerificationStatus(user.uid, true);
        }
      }
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
        email: (registrationData['email'] ?? "").toString().trim(),
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
        // Send verification email immediately after registration
        await _repository.sendVerificationEmail();
        
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
        
        // Don't set isLoggedIn to true yet if we want them to verify first
        // or just let the UI handle the navigation to verification screen.
        isLoggedIn.value = currentUser?.emailVerified ?? false;
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

  Future<void> sendPasswordReset(String email) async {
    isLoading.value = true;
    try {
      final status = await _repository.getEmailStatus(email);
      
      if (status == null) {
        Get.snackbar(
          "تنبيه",
          "هذا البريد الإلكتروني غير مسجل في المنصة",
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
        return;
      }

      final bool isEmailVerified = status['isVerified'] == true;
      final bool isAdminApproved = status['status'] == 'approved';

      if (!isEmailVerified && !isAdminApproved) {
        Get.snackbar(
          "حساب غير مفعل",
          "هذا الحساب موجود ولكن لم يتم تفعيل البريد الإلكتروني أو اعتماده من الإدارة بعد. يرجى تفعيله أولاً.",
          backgroundColor: Colors.redAccent.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      await _repository.sendPasswordResetEmail(email);
      Get.snackbar(
        "تم الإرسال",
        "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني",
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("خطأ", "فشل إرسال البريد. تأكد من صحة العنوان");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _repository.sendVerificationEmail();
      Get.snackbar("نجاح", "تم إعادة إرسال رابط التحقق");
    } catch (e) {
      Get.snackbar("خطأ", "فشل إعادة الإرسال");
    }
  }

  Future<void> reloadUser() async {
    await _repository.reloadUser();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    isLoading.value = true;
    try {
      bool reAuth = await _repository.reauthenticate(currentPassword);
      if (!reAuth) {
        Get.snackbar("خطأ", "كلمة المرور الحالية غير صحيحة", backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
      bool success = await _repository.updatePassword(newPassword);
      if (success) {
        Get.snackbar("نجاح", "تم تغيير كلمة المرور بنجاح", backgroundColor: Colors.green, colorText: Colors.white);
      }
      return success;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePhone(String currentPassword, String newPhone) async {
    isLoading.value = true;
    try {
      bool reAuth = await _repository.reauthenticate(currentPassword);
      if (!reAuth) {
        Get.snackbar("خطأ", "كلمة المرور غير صحيحة", backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
      bool success = await _repository.updateAuthPhone(newPhone);
      if (success) {
        Get.snackbar("نجاح", "تم تحديث رقم الهاتف بنجاح", backgroundColor: Colors.green, colorText: Colors.white);
      }
      return success;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changeEmail(String currentPassword, String newEmail) async {
    isLoading.value = true;
    try {
      bool reAuth = await _repository.reauthenticate(currentPassword);
      if (!reAuth) {
        Get.snackbar("خطأ", "كلمة المرور غير صحيحة", backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
      bool success = await _repository.updateAuthEmail(newEmail.trim());
      if (success) {
        Get.snackbar(
          "تم تحديث البريد",
          "تم إرسال رابط تحقق إلى بريدك الجديد. يرجى تفعيله لتتمكن من الدخول للمنصة مجدداً.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
        // توجيه المستخدم لصفحة الانتظار لأن حسابه أصبح غير مفعل الآن
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed('/verification_pending');
        });
      } else {
        Get.snackbar("خطأ", "فشل تحديث البريد. قد يكون مستخدماً بالفعل", backgroundColor: Colors.red, colorText: Colors.white);
      }
      return success;
    } finally {
      isLoading.value = false;
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
