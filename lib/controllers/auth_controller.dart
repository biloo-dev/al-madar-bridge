import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:al_madar_bridge/repositories/auth_repository.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';

class AuthController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  // Field specific errors
  var emailError = RxnString();
  var passwordError = RxnString();
  var generalError = RxnString();

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
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String wilaya,
    required String commune,
    required String userType,
    required String password,
  }) async {
    isLoading.value = true;
    clearErrors();
    try {
      final user = UserDocumentModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        wilaya: wilaya,
        commune: commune,
        userTypeId: userType,
      );
      bool success = await _repository.register(
        password: password,
        userData: user,
      );
      return success;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
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
      case 'invalid-credential':
        generalError.value = "بيانات الاعتماد غير صالحة";
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

  Future<void> updateProfile({
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
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    try {
      await _repository.fetchUserProfile();
      update(); // Trigger UI update if using GetBuilder
    } finally {
      isLoading.value = false;
    }
  }
}
