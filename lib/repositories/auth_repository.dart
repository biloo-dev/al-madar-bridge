import 'package:al_madar_bridge/data/mock_firestore.dart';
import 'package:al_madar_bridge/services/pref_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  Future<bool> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final doc = await _db.collection('users').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          _updateLocalPrefsFromMap(doc.data()!);
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
        final uid = userCredential.user!.uid;
        userData.userId = uid;
        await _db.collection('users').doc(uid).set(userData.toMap());
        _updateLocalPrefsFromModel(userData);
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
      final String step = isCompleted ? 'completed' : (nextStep ?? PrefManager.registrationStep);
      
      // We merge the data into the existing 'data' map in Firestore
      final Map<String, dynamic> updateData = {
        'profileCompleted': isCompleted,
        'registrationStep': step,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Dot notation to update nested 'data' fields without overwriting everything
      data.forEach((key, value) {
        updateData['data.$key'] = value;
      });

      await _db.collection('users').doc(user.uid).update(updateData);

      PrefManager.isProfileCompleted = isCompleted;
      PrefManager.registrationStep = step;
      
      // Update local PrefManager data by merging
      final currentData = PrefManager.customProfileData;
      currentData.addAll(data);
      PrefManager.customProfileData = currentData;
    }
  }

  Future<String> uploadRegistrationFile({
    required String userId,
    required File file,
    required String fieldName,
    required String fileName,
  }) async {
    final String uniqueName = "${DateTime.now().millisecondsSinceEpoch}_$fileName";
    final ref = _storage.ref().child('users/$userId/docs/$fieldName/$uniqueName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _updateLocalPrefsFromMap(doc.data()!);
      }
    }
  }

  void _updateLocalPrefsFromMap(Map<String, dynamic> data) {
    PrefManager.userFirstName = data['firstName'] ?? '';
    PrefManager.userLastName = data['lastName'] ?? '';
    PrefManager.userPhone = data['phone'] ?? '';
    PrefManager.userAddress = data['address'] ?? '';
    PrefManager.wilayaId = data['wilayaId']?.toString() ?? '';
    PrefManager.communeId = data['communeId']?.toString() ?? '';
    PrefManager.userType = data['userTypeId'] ?? '';
    PrefManager.isProfileCompleted = data['profileCompleted'] ?? false;
    PrefManager.registrationStep = data['registrationStep'] ?? 'basic';
    PrefManager.userStatus = data['status'] ?? 'pending';

    if (data['data'] != null && data['data'] is Map) {
      PrefManager.customProfileData = Map<String, dynamic>.from(data['data']);
    }
  }

  void _updateLocalPrefsFromModel(UserDocumentModel model) {
    PrefManager.userFirstName = model.firstName;
    PrefManager.userLastName = model.lastName;
    PrefManager.userPhone = model.phone;
    PrefManager.userEmail = model.email;
    PrefManager.userType = model.userTypeId;
    PrefManager.isProfileCompleted = model.profileCompleted;
    PrefManager.registrationStep = model.registrationStep;
    PrefManager.customProfileData = model.data;
  }
}
