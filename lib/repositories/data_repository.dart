import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../Models_2/requests.dart';
import '../data/mock_firestore.dart';

class DataRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Now extracting from the user document's data field
  Future<List<UserFileDocument>> getUserFiles() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final doc = await _db.collection('users').doc(user.uid).get();
    final root = doc.data();
    if (root == null || root['data'] is! Map) return [];

    final filesData = root['data']['files'];
    if (filesData is! Map) return [];

    final Map<String, dynamic> data = Map<String, dynamic>.from(filesData);
    final List<UserFileDocument> files = [];

    data.forEach((fieldName, fileInfo) {
      if (fileInfo is! Map) return;

      final List<dynamic> urls = fileInfo['urls'] ?? [];
      for (var url in urls) {
        files.add(
          UserFileDocument(
            fileName: url.toString().split('?').first.split('%2F').last,
            fileCategory:
                fileInfo['label_ar'] ?? fileInfo['label'] ?? fieldName,
            fileExtension: url.toString().contains('.pdf') ? 'pdf' : 'jpg',
            fileUrl: url.toString(),
            rejectionReason: fileInfo['rejectionReason'] ?? '',
            uploadedAt: fileInfo['lastUpdated'] ?? 'الآن',
            status: fileInfo['status'] ?? 'pending',
            fieldName: fieldName,
          ),
        );
      }
    });

    return files;
  }

  Future<List<NewsDocument>> getNews() async {
    try {
      final snapshot = await _db
          .collection('news')
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NewsDocument.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Firestore News Query Error: $e');
      final snapshot = await _db
          .collection('news')
          .where('isPublished', isEqualTo: true)
          .get();

      var news = snapshot.docs
          .map((doc) => NewsDocument.fromMap(doc.data(), doc.id))
          .toList();
      news.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
      return news;
    }
  }

  Future<void> incrementNewsViews(String newsId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final viewRef = _db
          .collection('news')
          .doc(newsId)
          .collection('views')
          .doc(user.uid);
      final viewDoc = await viewRef.get();

      if (!viewDoc.exists) {
        // إذا لم يشاهد المستخدم الخبر من قبل، نزيد العداد ونسجل مشاهدته
        await _db.runTransaction((transaction) async {
          transaction.set(viewRef, {'viewedAt': FieldValue.serverTimestamp()});
          transaction.update(_db.collection('news').doc(newsId), {
            'viewsCount': FieldValue.increment(1),
          });
        });
      }
    } catch (e) {
      print('Error incrementing news views: $e');
    }
  }

  Future<bool> toggleNewsLike(String newsId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final likeRef = _db
          .collection('news')
          .doc(newsId)
          .collection('likes')
          .doc(user.uid);
      final likeDoc = await likeRef.get();
      final bool isCurrentlyLiked = likeDoc.exists;

      await _db.runTransaction((transaction) async {
        if (isCurrentlyLiked) {
          transaction.delete(likeRef);
          transaction.update(_db.collection('news').doc(newsId), {
            'likesCount': FieldValue.increment(-1),
          });
        } else {
          transaction.set(likeRef, {'likedAt': FieldValue.serverTimestamp()});
          transaction.update(_db.collection('news').doc(newsId), {
            'likesCount': FieldValue.increment(1),
          });
        }
      });

      return !isCurrentlyLiked;
    } catch (e) {
      print('Error toggling like: $e');
      return false;
    }
  }

  Future<bool> isNewsLiked(String newsId) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _db
        .collection('news')
        .doc(newsId)
        .collection('likes')
        .doc(user.uid)
        .get();
    return doc.exists;
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year}";
    }
    return timestamp?.toString() ?? "الآن";
  }

  Future<String> uploadUserFile({
    required File file,
    required String fileName,
    required String fieldLabel,
    required String fieldName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    try {
      final String uniqueName =
          "${DateTime.now().millisecondsSinceEpoch}_$fileName";
      final String storagePath =
          'users/${user.uid}/documents/$fieldName/$uniqueName';

      final ref = _storage.ref().child(storagePath);
      await ref.putFile(file);
      final String downloadUrl = await ref.getDownloadURL();

      // Update the 'data.files' map in the user document
      final userDoc = _db.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      Map<String, dynamic> filesMap =
          docSnapshot.data()?['data']?['files'] ?? {};
      Map<String, dynamic> currentField =
          filesMap[fieldName] ??
          {
            'urls': [],
            'label': fieldLabel,
            'status': 'pending',
            'rejectionReason': '',
          };

      // Update field info
      List<dynamic> urls = List.from(currentField['urls'] ?? []);
      urls.add(downloadUrl);

      currentField['urls'] = urls;
      currentField['lastUpdated'] = DateTime.now().toIso8601String();
      currentField['status'] = 'pending'; // Reset to pending for re-approval
      currentField['rejectionReason'] = '';

      await userDoc.update({'data.files.$fieldName': currentField});

      return downloadUrl;
    } catch (e) {
      print('File Upload Error: $e');
      rethrow;
    }
  }

  Future<void> deleteUserFile({
    required String fieldName,
    required String fileUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Delete from Firebase Storage
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      print('✅ Deleted from Storage: $fileUrl');

      // 2. Update Firestore document
      final userDoc = _db.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data()!['data'] ?? {};
        Map<String, dynamic> filesMap = data['files'] ?? {};

        if (filesMap.containsKey(fieldName)) {
          Map<String, dynamic> fieldInfo = Map<String, dynamic>.from(
            filesMap[fieldName],
          );
          List<dynamic> urls = List.from(fieldInfo['urls'] ?? []);

          urls.remove(fileUrl);
          fieldInfo['urls'] = urls;
          fieldInfo['lastUpdated'] = DateTime.now().toIso8601String();

          if (urls.isEmpty) {
            fieldInfo['status'] = 'pending';
            fieldInfo['rejectionReason'] = '';
          }

          await userDoc.update({'data.files.$fieldName': fieldInfo});
          print('✅ Updated Firestore: Removed URL from $fieldName');
        }
      }
    } catch (e) {
      print('❌ Error deleting file: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCollectionData(
    String collectionName,
  ) async {
    final snapshot = await _db.collection(collectionName).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      if (!data.containsKey('id')) data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getDynamicFields(String userTypeId) async {
    try {
      final doc = await _db.collection('dynamic_fields').doc('default').get();
      if (!doc.exists) {
        print('❌ Document dynamic_fields/default not found');
        return [];
      }

      final rootData = doc.data();
      if (rootData == null) return [];

      // تنظيف المعرف للبحث
      String id = userTypeId.trim().toLowerCase().replaceAll('_onboarding', '');
      List<String> fieldKeys = [id, "${id}_fields"];

      // وظيفة داخلية للبحث عن القائمة في خريطة معينة
      dynamic findInMap(Map<String, dynamic> map) {
        for (String key in fieldKeys) {
          // جلب المفاتيح ومقارنتها بدون حساسية للحالة أو الفراغات
          final match = map.keys.firstWhereOrNull(
            (k) =>
                k.trim().toLowerCase() == key ||
                k.trim().toLowerCase() == key.replaceAll('_', ''),
          );
          if (match != null && map[match] is List) return map[match];
        }
        return null;
      }

      // 1. البحث في الجذر
      dynamic rawFields = findInMap(rootData);

      // 2. إذا لم يجد، يبحث داخل default (المستوى الأول)
      if (rawFields == null && rootData['default'] is Map) {
        rawFields = findInMap(Map<String, dynamic>.from(rootData['default']));
      }

      // 3. إذا لم يجد، يبحث داخل default -> default (المستوى الثاني كما في الـ JSON المرسل)
      if (rawFields == null &&
          rootData['default'] is Map &&
          rootData['default']['default'] is Map) {
        rawFields = findInMap(
          Map<String, dynamic>.from(rootData['default']['default']),
        );
      }

      if (rawFields == null) {
        print(
          '⚠️ Could not find fields for $id in any level. Keys tried: $fieldKeys',
        );
        return [];
      }

      return List<Map<String, dynamic>>.from(
        (rawFields as List).map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      print('❌ Error in getDynamicFields: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCommunesByWilaya(
    String wilayaId,
  ) async {
    var snapshot = await _db
        .collection('communes')
        .where('wilaya_id', isEqualTo: wilayaId)
        .get();
    if (snapshot.docs.isEmpty && int.tryParse(wilayaId) != null) {
      snapshot = await _db
          .collection('communes')
          .where('wilaya_id', isEqualTo: int.parse(wilayaId))
          .get();
    }
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<RequestDocument>> getMyRequests() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('requests')
        .where('createdBy', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => RequestDocument.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> createRequest(
    RequestDocument request,
    Map<String, dynamic> attributes,
  ) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    final docRef = _db.collection('requests').doc();
    final requestId = docRef.id;

    final requestData = request.toMap();
    requestData['createdBy'] = user.uid;

    await _db.runTransaction((transaction) async {
      transaction.set(docRef, requestData);
      transaction.set(
        _db.collection('request_attributes').doc(requestId),
        attributes,
      );
    });
  }

  Future<List<RequestType>> getRequestTypes() async {
    final snapshot = await _db.collection('request_types').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return RequestType.fromMap(data);
    }).toList();
  }

  Future<List<RequestDocument>> getPublicRequests() async {
    try {
      final snapshot = await _db
          .collection('requests')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => RequestDocument.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching public requests: $e');
      return [];
    }
  }
}
