import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PersistentImageManager {
  /// جلب مسار ملف الصورة محلياً بناءً على الرابط
  static Future<File> _getLocalFile(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    // تحويل الرابط إلى Hash ليكون اسم ملف فريد وآمن
    final fileName = md5.convert(utf8.encode(url)).toString();
    return File('${directory.path}/$fileName');
  }

  /// فحص وجود الصورة محلياً، إذا لم توجد يقوم بتحميلها
  static Future<File?> getImage(String url) async {
    if (url.isEmpty) return null;
    
    final file = await _getLocalFile(url);

    // إذا كانت الصورة موجودة مسبقاً، نرجعها فوراً
    if (await file.exists()) {
      return file;
    }

    // إذا لم تكن موجودة، نقوم بتحميلها
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      print("Error downloading persistent image: $e");
    }
    return null;
  }
}
