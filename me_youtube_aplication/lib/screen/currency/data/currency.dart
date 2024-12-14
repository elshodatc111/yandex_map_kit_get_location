class Currency{
  String title;
  String code;
  String cb_price;
  String data;

  Currency({
    required this.title,
    required this.code,
    required this.cb_price,
    required this.data,
  });

  factory Currency.fromJson(Map<String, dynamic> json){
    String title = json['title']??"No Title";
    String code = json['code']??"No code";
    String cb_price = json['cb_price']??"No cb_price";
    String data = json['data']??"No data";
    return Currency(title: title, code: code, cb_price: cb_price, data: data);
  }
}