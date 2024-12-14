import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';  // Import this package

class HomeShowPage extends StatefulWidget {
  final int id;

  const HomeShowPage({super.key, required this.id});

  @override
  State<HomeShowPage> createState() => _HomeShowPageState();
}

class _HomeShowPageState extends State<HomeShowPage> {
  final String baseUrl = 'https://mobile-app.atko.tech/api/show/';
  final String imageUrlBase = 'https://mobile-app.atko.tech/uploads/';
  final box = GetStorage();
  bool isLoading = true;
  Map<String, dynamic>? item;

  @override
  void initState() {
    super.initState();
    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    final token = box.read('token');
    if (token == null) {
      Get.snackbar('Xatolik', 'Token topilmadi');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl${widget.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          item = json.decode(response.body);
          isLoading = false;
        });
      } else {
        Get.snackbar('Xatolik', 'Ma\'lumotlarni olib kelishda muammo yuz berdi.');
      }
    } catch (e) {
      Get.snackbar('Xatolik', 'Tarmoqda muammo yuz berdi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ma\'lumot tafsilotlari',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : item == null
          ? const Center(child: Text('Ma\'lumot topilmadi.'))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                '$imageUrlBase${item!['image']}',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 100);
                },
              ),
              const SizedBox(height: 16.0),
              Text(
                item!['title'] ?? 'Noma\'lum',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Hudud: ${item!['refion'] ?? 'Noma\'lum'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tur: ${item!['type'] ?? 'Noma\'lum'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Tavsif:',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              HtmlWidget(  // Using HtmlWidget here
                item!['description'] ?? 'Tavsif mavjud emas',
                textStyle: const TextStyle(fontSize: 16),  // Optional custom styling for HTML content
              ),
              const SizedBox(height: 16.0),
              Text(
                'Yaratilgan vaqti: ${item!['created_at'] ?? 'Noma\'lum'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
