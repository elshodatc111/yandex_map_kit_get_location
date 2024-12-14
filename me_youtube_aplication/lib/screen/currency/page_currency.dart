import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../data/currency.dart';

class PageCurrency extends StatefulWidget {
  const PageCurrency({super.key});

  @override
  State<PageCurrency> createState() => _PageCurrencyState();
}

class _PageCurrencyState extends State<PageCurrency> {
  getDataFromApi() async{
    var response = await Dio().get('https://nbu.uz/en/exchange-rates/json/');
    List currencies = response.data.map((current_currency)=>Currency.fromJson(current_currency)).toList();
    return currencies;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: FutureBuilder(
            future: getDataFromApi(),
            builder: (context, snapshot){
              return const Text("xxx");
            },
          )
      ),
    );
  }
}
