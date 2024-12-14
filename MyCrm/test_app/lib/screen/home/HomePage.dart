import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:teskor_yunaltirish/screen/home/HomeShowPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiUrl = 'https://mobile-app.atko.tech/api/home';
  final String imageUrlBase = 'https://mobile-app.atko.tech/uploads/';
  final box = GetStorage();
  bool isLoading = true;
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final token = box.read('token');
    if (token == null) {
      Get.snackbar('Xatolik', 'Token topilmadi');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
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
          'Tezkor yo‘naltirish',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchItems,
        child: SingleChildScrollView(  // Bu yerda SingleChildScrollView qo'shildi
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,  // ListView heightga mos bo'lishi uchun
                physics: NeverScrollableScrollPhysics(),  // ListView aylantirishni o'chiradi
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: Image.network(
                        '$imageUrlBase${item['image']}',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                      title: Text(item['title'] ?? 'Noma\'lum'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hudud: ${item['region'] ?? 'Noma\'lum'}'),
                          Text('Tur: ${item['type'] ?? 'Noma\'lum'}'),
                        ],
                      ),
                      onTap: () {
                        Get.to(() => HomeShowPage(id: item['id']));
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
