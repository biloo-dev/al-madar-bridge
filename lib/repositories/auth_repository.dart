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
      UserCredential? userCredential;

      // Check if user is already logged in (case where Auth succeeded but Firestore failed on previous attempt)
      if (_auth.currentUser != null && _auth.currentUser!.email == userData.email) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: userData.email,
          password: password,
        );
      } else {
        try {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: userData.email,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            try {
              // Attempt to sign in if the account was created but not finalized
              userCredential = await _auth.signInWithEmailAndPassword(
                email: userData.email,
                password: password,
              );
            } on FirebaseAuthException catch (inner) {
              if (inner.code == 'wrong-password') {
                throw Exception("هذا البريد مسجل مسبقاً بكلمة مرور مختلفة. يرجى تسجيل الدخول أولاً.");
              } else if (inner.code == 'invalid-credential' || inner.message!.contains('Recaptcha')) {
                throw Exception("فشل التحقق من الأمان. يرجى إضافة مفاتيح SHA لمشروع Firebase الخاص بك.");
              }
              rethrow;
            }
          } else {
            rethrow;
          }
        }
      }

      if (userCredential?.user != null) {
        final uid = userCredential!.user!.uid;
        userData.userId = uid;
        final userDataMap = userData.toMap();
        userDataMap['emailVerified'] = userCredential.user!.emailVerified;
        
        // Save/Update Firestore document
        await _db.collection('users').doc(uid).set(userDataMap, SetOptions(merge: true));
        
        _updateLocalPrefsFromModel(userData);
        PrefManager.rememberLogin = true;
        PrefManager.userEmail = userData.email;
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

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getEmailStatus(String email) async {
    final snapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    return {
      'exists': true,
      'isVerified': data['emailVerified'] ?? false,
      'status': data['status'] ?? 'pending',
    };
  }

  Future<void> updateEmailVerificationStatus(String uid, bool status) async {
    await _db.collection('users').doc(uid).update({'emailVerified': status});
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<bool> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;
    
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      print("Re-auth Error: $e");
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      return true;
    } catch (e) {
      print("Update Password Error: $e");
      return false;
    }
  }

  Future<bool> updateAuthPhone(String newPhone) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      // تحديث في Firestore أولاً
      await _db.collection('users').doc(user.uid).update({'phone': newPhone});
      PrefManager.userPhone = newPhone;
      return true;
    } catch (e) {
      print("Update Phone Error: $e");
      return false;
    }
  }

  Future<bool> updateAuthEmail(String newEmail) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await user.verifyBeforeUpdateEmail(newEmail); // يرسل رابط تحقق للبريد الجديد قبل التغيير النهائي أو يغيره ويرسل تحقق
      // ملاحظة: في النسخ الحديثة من Firebase يفضل استخدام verifyBeforeUpdateEmail
      // إذا كنت تستخدم updateEmail فإنه يغير البريد فوراً
      
      await _db.collection('users').doc(user.uid).update({
        'email': newEmail,
        'emailVerified': false,
      });

      PrefManager.userEmail = newEmail;
      return true;
    } catch (e) {
      print("Update Email Error: $e");
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
