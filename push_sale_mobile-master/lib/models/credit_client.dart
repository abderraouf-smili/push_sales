import 'package:push_sale/const/globals.dart' as global;

// Modèle pour les données de l'API
class CreditClient {
  final String purchaseorderId;
  final String year;
  final String month;
  final String date;
  final String name;
  final String image;
  final String code;
  final double totalAmount;
  final double solde;

  CreditClient({
    required this.purchaseorderId,
    required this.year,
    required this.month,
    required this.date,
    required this.name,
    required this.image,
    required this.code,
    required this.totalAmount,
    required this.solde,
  });

  factory CreditClient.fromJson(Map<String, dynamic> json) {
    return CreditClient(
      purchaseorderId: json['purchaseorder_id'],
      year: json['year'],
      month: json['month'],
      date: json['date'],
      name: json['name'],
      image: json['image'] == null ? "${global.urlAPI}/storage/clients/no_image.png": "${global.urlAPI}${json['image']}",
      code: json['code'],
      totalAmount: double.parse(json['total_amount'].toString()),
      solde: double.parse(json['solde'].toString()),
    );
  }
}

// Structure de l'arbre
class YearNode {
  final String year;
  final Map<String, MonthNode> months = {};

  YearNode({required this.year});
}

class MonthNode {
  final String month;
  final Map<String, DateNode> dates = {};

  MonthNode({required this.month});
}

class DateNode {
  final String date;
  final List<CreditClient> credits = [];

  DateNode({required this.date});
}
