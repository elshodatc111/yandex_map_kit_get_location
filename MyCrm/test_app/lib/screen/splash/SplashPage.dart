import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teskor_yunaltirish/screen/home/HomePage.dart';
import 'package:teskor_yunaltirish/screen/login/LoginPage.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 5),
      () {
        final box = GetStorage();
        String? token = box.read('token');
        if (token != null && token.isNotEmpty) {
          Get.off(() => HomePage());
        } else {
          Get.off(() => LoginPage());
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200.0,
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Respublika xududidan tashqariga chiqib ketmagan sud va tergov organlaridan qidruvda bo\'lgan '
                '(bedarak yo\'qolgan shaxslar va shaxsni noaniq murdalar) shaxslarning elektron bazasi bo\'lgan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'Tezkor yo‘naltirish',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'platformasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
