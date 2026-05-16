import 'package:get/get.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/models/credit_client.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/receivable.dart';
import 'package:uuid/uuid.dart';

class CreditController extends GetxController {
  // États observables
  var isLoading = true.obs;
  var credits = <dynamic>[].obs;
  var tree = <String, YearNode>{}.obs;
  String? trackId;
  RxString saved = "".obs;

  @override
  void onInit() async {
    super.onInit();
    await loadData();
  }

  generateTrackId() {
    Uuid uuid = const Uuid();
    trackId = uuid.v1();
  }

  Future<bool> sendCash(List<ReceivaleLine> line) async {

    var data = {
      "data": line.map((e) => e.toMap()).toList(),
      "track_id": trackId!
    };
    // print("============>>>$data");
    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.sendCashForAll,
      data: data,
    );
    // return true;
    if (response.status == "SUCCESS") {
      return true;
    } else {
      saved.value = response.message;
      return false;
    }
  }



  // Charger les données depuis l'API
  Future<void> loadData() async {
    isLoading.value = true;
    credits.value = [];
    ResponseHttpRequest response =
        await CallApi.RequestHttp(global.receivaleByDate);
    if (response.status == "SUCCESS") {
      credits.value =
          response.data.map((json) => CreditClient.fromJson(json)).toList();
    } else {
      print(response.message);
    }

    // Construire l'arbre
    buildTree();

    isLoading.value = false;
  }

  // Construire l'arbre à partir des commandes
  void buildTree() {
    Map<String, YearNode> newTree = {};

    for (var credit in credits) {
      // Ajouter l'année si elle n'existe pas
      if (!newTree.containsKey(credit.year)) {
        newTree[credit.year] = YearNode(year: credit.year);
      }

      YearNode yearNode = newTree[credit.year]!;

      // Ajouter le mois s'il n'existe pas
      if (!yearNode.months.containsKey(credit.month)) {
        yearNode.months[credit.month] = MonthNode(month: credit.month);
      }

      MonthNode monthNode = yearNode.months[credit.month]!;

      // Ajouter la date si elle n'existe pas
      if (!monthNode.dates.containsKey(credit.date)) {
        monthNode.dates[credit.date] = DateNode(date: credit.date);
      }

      DateNode dateNode = monthNode.dates[credit.date]!;

      // Ajouter la commande
      dateNode.credits.add(credit);
    }

    tree.value = newTree;
  }

  // Obtenir les années triées
  List<String> getSortedYears() {
    return tree.keys.toList()..sort((a, b) => b.compareTo(a));
  }

// Obtenir les mois triés par ordre décroissant
  List<String> getSortedMonths(YearNode yearNode) {
    return yearNode.months.keys.toList()..sort((a, b) => b.compareTo(a));
  }

// Obtenir les dates triées par ordre décroissant
  List<String> getSortedDates(MonthNode monthNode) {
    return monthNode.dates.keys.toList()..sort((a, b) => b.compareTo(a));
  }

  // Obtenir le nom du mois en français
  String getMonthName(int month) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    return months[month - 1];
  }

  // Formater l'affichage du mois
  String formatMonth(String monthStr) {
    if (monthStr.contains('-')) {
      final parts = monthStr.split('-');
      if (parts.length == 2) {
        return '${getMonthName(int.parse(parts[0]))} ${parts[1]}';
      }
    }
    return monthStr;
  }

  int getYearOrderCount(YearNode yearNode) {
    int count = 0;
    for (var month in yearNode.months.values) {
      for (var date in month.dates.values) {
        count += date.credits.length;
      }
    }
    return count;
  }

// Compter le nombre total de commandes pour un mois
  int getMonthOrderCount(MonthNode monthNode) {
    int count = 0;
    for (var date in monthNode.dates.values) {
      count += date.credits.length;
    }
    return count;
  }

// Compter le nombre total de commandes pour une date
  int getDateOrderCount(DateNode dateNode) {
    return dateNode.credits.length;
  }

// Calculer le total du solde pour une année
double getYearTotalSolde(YearNode yearNode) {
  double total = 0;
  for (var month in yearNode.months.values) {
    for (var date in month.dates.values) {
      for (var credit in date.credits) {
        total += credit.solde;
      }
    }
  }
  return total; // Arrondir à l'entier
}

// Calculer le total du solde pour un mois
double getMonthTotalSolde(MonthNode monthNode) {
  double total = 0;
  for (var date in monthNode.dates.values) {
    for (var credit in date.credits) {
      total += credit.solde;
    }
  }
  return total;
}

// Calculer le total du solde pour une date
double getDateTotalSolde(DateNode dateNode) {
  double total = 0;
  for (var credit in dateNode.credits) {
    total += credit.solde;
  }
  return total;
}  
}
