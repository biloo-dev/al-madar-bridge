import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../data/mock_firestore.dart';

class DataRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<UserFileDocument>> getUserFiles() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _db
        .collection('user_files')
        .where('userId', isEqualTo: user.uid)
        .orderBy('uploadedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserFileDocument(
        fileName: data['fileName'] ?? '',
        fileCategory: data['fileLabel'] ?? '',
        fileExtension: data['extension'] ?? '',
        fileUrl: data['fileUrl'] ?? '',
        uploadedAt: _formatTimestamp(data['uploadedAt']),
        status: data['status'] ?? 'pending',
      );
    }).toList();
  }

  Future<List<NewsDocument>> getNews() async {
    try {
      final snapshot = await _db
          .collection('news')
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => _mapNews(doc)).toList();
    } catch (e) {
      print('Firestore News Query Error: $e');
      final snapshot = await _db
          .collection('news')
          .where('isPublished', isEqualTo: true)
          .get();

      var news = snapshot.docs.map((doc) => _mapNews(doc)).toList();
      news.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return news;
    }
  }

  NewsDocument _mapNews(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NewsDocument(
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      publishedBy: data['publishedBy'] ?? data['published_by'] ?? 'النظام',
      publishedAt: _formatTimestamp(data['createdAt']),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year}";
    }
    return "الآن";
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
      final String ext = fileName.split('.').last.toLowerCase();
      final String storagePath = 'users/${user.uid}/documents/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      print('📤 Uploading to Firebase Storage: $fileName');

      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(
        file, 
        SettableMetadata(contentType: _getContentType(ext))
      );
      
      final String downloadUrl = await uploadTask.ref.getDownloadURL();
      final int bytes = await file.length();

      print('✅ Firebase Storage Success: $downloadUrl');

      // Check for existing file for this field to override
      final existing = await _db
          .collection('user_files')
          .where('userId', isEqualTo: user.uid)
          .where('fieldName', isEqualTo: fieldName)
          .limit(1)
          .get();

      final fileData = {
        'userId': user.uid,
        'fieldName': fieldName,
        'fileName': fileName,
        'fileLabel': fieldLabel,
        'fileUrl': downloadUrl,
        'fileSize': bytes,
        'extension': ext,
        'uploadedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      if (existing.docs.isNotEmpty) {
        await _db
            .collection('user_files')
            .doc(existing.docs.first.id)
            .set(fileData, SetOptions(merge: true));
        print('✅ Overrode existing document in Firestore');
      } else {
        await _db.collection('user_files').add(fileData);
        print('✅ Created new file document in Firestore');
      }

      return downloadUrl;
    } catch (e) {
      print('❌ Firebase Storage Exception: $e');
      rethrow;
    }
  }

  String _getContentType(String ext) {
    switch (ext) {
      case 'pdf': return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      default: return 'application/octet-stream';
    }
  }

  Future<List<Map<String, dynamic>>> getCollectionData(
    String collectionName,
  ) async {
    final snapshot = await _db.collection(collectionName).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>?> getAppSettings() async {
    final doc = await _db.collection('config').doc('app_settings').get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getDynamicFields(String userTypeId) async {
    final snapshot = await _db
        .collection('dynamic_fields')
        .where('userTypeId', isEqualTo: userTypeId)
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
