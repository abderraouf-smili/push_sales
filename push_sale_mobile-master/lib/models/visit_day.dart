import 'package:push_sale/const/globals.dart' as global;

class VisitDay {
  final String day;
  VisitDay(this.day);

  static fromMap(Map<String, dynamic> value) {
    return VisitDay(
      value["day"],
    );
  }

  toMap() {
    return {
      "day": day,
    };
  }

  static fromListMapMap(List<dynamic> value) {
    List<String> listTmp = [];
    List<VisitDay> list = [];
    for (var item in value) {
      listTmp.add(item["day"]);
    }
    for (String item in global.weekdays) {
      if (listTmp.contains(item)) {
        list.add(VisitDay(item));
      }
    }
    return list.reversed.toList();
  }
}
