
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'product_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({Key? key}) : super(key: key);

@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'تطبيق المنتجات',
theme: ThemeData(primarySwatch: Colors.blue),
home: const ProductsScreen(),
);
}
}

class ProductsScreen extends StatefulWidget {
const ProductsScreen({Key? key}) : super(key: key);

@override
_ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
final ApiService apiService = ApiService();
late Future<List<Product>> futureProducts;

// قائمة لحفظ معرفات (Ids) المنتجات المفضلة
List<String> favoriteIds = [];

@override
void initState() {
super.initState();
_loadFavorites(); // تحميل المفضلة عند فتح التطبيق
futureProducts = apiService.getProducts(); // بدء جلب المنتجات

}

// دالة لقراءة المنتجات المفضلة من التخزين المحلي
Future<void> _loadFavorites() async {
final prefs = await SharedPreferences.getInstance();
setState(() {
favoriteIds = prefs.getStringList('favorites') ?? [];
});
}

// دالة للتبديل بين إضافة وإزالة المنتج من المفضلة وحفظ التعديل فوراً
Future<void> _toggleFavorite(int id) async {
final prefs = await SharedPreferences.getInstance();
setState(() {
String idStr = id.toString();
if (favoriteIds.contains(idStr)) {
favoriteIds.remove(idStr); // إزالة إذا كان موجوداً
} else {
favoriteIds.add(idStr); // إضافة إذا لم يكن موجوداً
}
prefs.setStringList('favorites', favoriteIds); // حفظ التغيير محلياً
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('المنتجات'),
centerTitle: true,
),
body: FutureBuilder<List<Product>>(
future: futureProducts,
builder: (context, snapshot) {
// حالة التحميل (Loading)
if (snapshot.connectionState == ConnectionState.waiting) {
return const Center(child: CircularProgressIndicator());
}
// حالة وجود خطأ
else if (snapshot.hasError) {
return Center(child: Text('حدث خطأ: ${snapshot.error}'));
}
// حالة عدم وجود بيانات
else if (!snapshot.hasData || snapshot.data!.isEmpty) {
return const Center(child: Text('لا توجد بيانات للعرض'));
}

// حالة النجاح: عرض القائمة
return ListView.builder(
itemCount: snapshot.data!.length,
itemBuilder: (context, index) {
final product = snapshot.data![index];
// نتحقق مما إذا كان المنتج ضمن قائمة المفضلة
final isFavorite = favoriteIds.contains(product.id.toString());

return Card(
margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
elevation: 3,
child: ListTile(
// عرض الصورة، مع وضع أيقونة بديلة في حال كان المستخدم Offline وفشلت الصورة في التحميل
leading: Image.network(
product.image,
width: 50,
height: 50,
fit: BoxFit.cover,
errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
),
title: Text(
product.title,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(fontWeight: FontWeight.bold),
),
subtitle: Text('\$${product.price}'),
trailing: IconButton(
icon: Icon(
isFavorite ? Icons.favorite : Icons.favorite_border,
color: isFavorite ? Colors.red : Colors.grey,
),
onPressed: () => _toggleFavorite(product.id), // زر الإضافة للمفضلة
),
),
);
},
);
},
),
);
}
}
