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
    List<String> _list_tmp = [];
    List<VisitDay> _list = [];
    for (var item in value) {
      _list_tmp.add(item["day"]);
    }
    for (String item in global.weekdays) {
      if (_list_tmp.contains(item)) {
        _list.add(VisitDay(item));
      }
    }
    return _list.reversed.toList();
  }
}
