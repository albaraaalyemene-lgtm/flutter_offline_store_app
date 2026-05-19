import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';

class ApiService {
// رابط الـ API لجلب المنتجات بصيغة JSON
static const String apiUrl = 'https://fakestoreapi.com/products';
static const String cachedDataKey = 'cached_products';

Future<List<Product>> getProducts() async {
  final prefs = await SharedPreferences.getInstance();

  try {
    // 1. محاولة الاتصال بالإنترنت وجلب البيانات
    // وضعنا مهلة (timeout) حتى لا ينتظر التطبيق طويلاً إذا كان النت ضعيفاً أو مقطوعاً
    final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      // 2. إذا نجح الاتصال: نحفظ النص (JSON) في التخزين المحلي لدعم الـ Offline
      prefs.setString(cachedDataKey, response.body);

      // تحويل النص إلى قائمة منتجات
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromson(json)).toList();
    } else {
  throw Exception('فشل تحميل البيانات من الخادم');
  }
  } catch (e) {
  // 3. وضع الـ Offline: إذا فشل الاتصال (لا يوجد نت)، نقرأ البيانات المحفوظة مسبقاً
  final cachedData = prefs.getString(cachedDataKey);
  if (cachedData != null) {
  List<dynamic> data = json.decode(cachedData);
  return data.map((json) => Product.fromson(json)).toList();
  } else {
  throw Exception('لا يوجد اتصال بالإنترنت، ولا توجد بيانات محفوظة مسبقاً.');
  }
  }
}
}
