import 'package:al_madar_bridge/models/user_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // تسجيل الدخول
  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Fetch user data from Firestore
        final doc = await _db.collection('users').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          PrefManager.userFirstName = data['firstName'] ?? '';
          PrefManager.userLastName = data['lastName'] ?? '';
          PrefManager.userPhone = data['phone'] ?? '';
          PrefManager.userType = data['userTypeId'] ?? '';
          PrefManager.isProfileCompleted = data['profileCompleted'] ?? false;
          PrefManager.registrationStep = data['registrationStep'] ?? 'basic';
          PrefManager.userStatus = data['status'] ?? 'pending';

          // Store extra registration data
          Map<String, dynamic> extraData = {};
          data.forEach((key, value) {
            if (!['firstName', 'lastName', 'email', 'phone', 'wilayaId', 'communeId', 'userTypeId', 'status', 'profileCompleted', 'registrationStep', 'createdAt', 'role', 'updatedAt'].contains(key)) {
              extraData[key] = value;
            }
          });
          PrefManager.customProfileData = extraData;
        }
        
        PrefManager.rememberLogin = true;
        PrefManager.userEmail = email;
        return true;
      }
      return false;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  // إنشاء حساب
  Future<bool> register({
    required String password,
    required UserDocumentModel userData,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: userData.email,
        password: password,
      );

      if (userCredential.user != null) {
        // Store user data in Firestore
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'firstName': userData.firstName,
          'lastName': userData.lastName,
          'email': userData.email,
          'phone': userData.phone,
          'wilayaId': userData.wilaya,
          'communeId': userData.commune,
          'userTypeId': userData.userTypeId,
          'status': 'pending',
          'profileCompleted': false,
          'registrationStep': 'extra_details', // After basic info, we need extra details
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });

        PrefManager.userFirstName = userData.firstName;
        PrefManager.userLastName = userData.lastName;
        PrefManager.userPhone = userData.phone;
        PrefManager.userEmail = userData.email;
        PrefManager.userType = userData.userTypeId;
        PrefManager.isProfileCompleted = false;
        PrefManager.registrationStep = 'extra_details';
        PrefManager.rememberLogin = true;
        
        return true;
      }
      return false;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      print("Registration Error: $e");
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await _auth.signOut();
    PrefManager.clear();
  }

  Future<void> updateProfile({
    required Map<String, dynamic> data,
    bool isCompleted = false,
    String? nextStep,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final updateData = {
        ...data,
        'profileCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (nextStep != null) {
        updateData['registrationStep'] = nextStep;
      }
      await _db.collection('users').doc(user.uid).update(updateData);
      
      // Update local prefs
      PrefManager.isProfileCompleted = isCompleted;
      if (nextStep != null) {
        PrefManager.registrationStep = nextStep;
      }

      // Update custom profile data locally
      var existing = PrefManager.customProfileData;
      existing.addAll(data);
      PrefManager.customProfileData = existing;
    }
  }

  Future<void> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        PrefManager.userFirstName = data['firstName'] ?? '';
        PrefManager.userLastName = data['lastName'] ?? '';
        PrefManager.userPhone = data['phone'] ?? '';
        PrefManager.userType = data['userTypeId'] ?? '';
        PrefManager.userEmail = data['email'] ?? PrefManager.userEmail;
        PrefManager.isProfileCompleted = data['profileCompleted'] ?? false;
        PrefManager.registrationStep = data['registrationStep'] ?? 'basic';
        PrefManager.userStatus = data['status'] ?? 'pending';

        // Store extra registration data
        Map<String, dynamic> extraData = {};
        data.forEach((key, value) {
          if (!['firstName', 'lastName', 'email', 'phone', 'wilayaId', 'communeId', 'userTypeId', 'status', 'profileCompleted', 'registrationStep', 'createdAt', 'role', 'updatedAt'].contains(key)) {
            extraData[key] = value;
          }
        });
        PrefManager.customProfileData = extraData;
      }
    }
  }
}
