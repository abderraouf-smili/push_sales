import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:push_sale/api/call_api.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:push_sale/models/stats_order.dart';

class StatController extends GetxController {
  List<LineChartPushSaleData> lineChartData = [];
  List<ProfitChartData> profitChartData = [];
  List<PieChartPushSaleData> pieCharData = [];
  List<BarChartPushSaleData> barCharData = [];
  List<StatsOrder> statsOrders = [];
  // List<Order> orders = [];
  double maxLineY = 0;
  double maxProfitY = 0;
  double minProfitY = 0;
  double maxYbar = 0;
  DateTime? ServerTime;
  DateTime profitMonth = DateTime(DateTime.now().year, DateTime.now().month);
  RxBool statsReady = false.obs;
  RxBool statsLoading = false.obs;
  RxString statsError = "".obs;
  RxBool deliveryStatsReady = false.obs;
  RxBool deliveryStatsLoading = false.obs;
  RxString deliveryStatsError = "".obs;
  RxBool profitStatsReady = false.obs;
  RxBool profitStatsLoading = false.obs;

  StatsDay? stats_day;
  StatsDeliveryDay? delivery_stats_day;
  ProfitStatsSummary? profitStatsSummary;

  final List<Color> _color = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.brown,
    Colors.lime,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.blueGrey,
    Colors.grey, // Peut être évité si besoin d'un fond blanc
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
  ];

  // delivery_stats_day =
  //     StatsDay.fromMap(response.data["delivery_today_stats"]);
  // cash_stats_day = StatsDay.fromMap(response.data["cash_stats_day"]);

  Future<void> getDeliveryStats() async {
    if (deliveryStatsLoading.value) {
      return;
    }
    deliveryStatsLoading.value = true;
    deliveryStatsReady.value = false;
    deliveryStatsError.value = "";
    try {
      ResponseHttpRequest response =
          await CallApi.RequestHttp(global.DeliveryStatsDay);
      if (response.status == "SUCCESS") {
        delivery_stats_day =
            StatsDeliveryDay.fromMap(response.data["today_stats"]);
        ServerTime = DateTime.tryParse(response.data["server_time"].toString());
        deliveryStatsReady.value = true;
      } else {
        deliveryStatsError.value = response.message.toString();
        print(response.message);
      }
    } catch (e) {
      deliveryStatsError.value = e.toString();
    } finally {
      deliveryStatsLoading.value = false;
    }
  }

  Future<void> getStats() async {
    if (statsLoading.value) {
      return;
    }
    statsLoading.value = true;
    statsReady.value = false;
    statsError.value = "";

    lineChartData = [];
    pieCharData = [];
    barCharData = [];
    statsOrders = [];
    maxLineY = 0;
    maxYbar = 0;
    int i = 0;

    // Get turn over by category
    try {
      ResponseHttpRequest response =
          await CallApi.RequestHttp(global.statscategory);
      if (response.status == "SUCCESS") {
        for (var item in response.data["categ"]) {
          pieCharData.add(PieChartPushSaleData(
              title_fr: item["short_description_fr"],
              title_ar: item["short_description_ar"],
              value: double.parse(item["total"].toString()),
              color: _color[i]));
          i++;
        }
        i = 0;
        double val;
        for (var item in response.data["line"]) {
          val = double.parse(item["total"].toString());
          if (i == 0) {
            lineChartData.add(LineChartPushSaleData(i * 1.00, 0));
            i++;
          }
          if (val >= maxLineY) {
            maxLineY = val;
          }
          lineChartData.add(LineChartPushSaleData(i * 1.00, val));
          i++;
        }

        for (var item in response.data["client_stats"]) {
          if (double.parse(item["count"].toString()) > maxYbar) {
            maxYbar = double.parse(item["count"].toString());
          }
          barCharData.add(
            BarChartPushSaleData(
              item["name_ar"],
              item["name"],
              double.parse(
                item["count"].toString(),
              ),
            ),
          );
        }

        for (var item in response.data["today_stats"]["orders_status"]) {
          statsOrders.add(StatsOrder.fromMap(item));
        }

        stats_day = StatsDay.fromMap(response.data["today_stats"]);
        ServerTime = DateTime.tryParse(response.data["server_time"].toString());
        statsReady.value = true;
      } else {
        statsError.value = response.message.toString();
        print(response.message);
      }
    } catch (e) {
      statsError.value = e.toString();
    } finally {
      statsLoading.value = false;
    }
  }

  Future<void> getProfitStats({DateTime? month}) async {
    if (profitStatsLoading.value) {
      return;
    }
    profitStatsLoading.value = true;
    profitStatsReady.value = false;
    if (month != null) {
      profitMonth = DateTime(month.year, month.month);
    }
    profitChartData = [];
    profitStatsSummary = null;
    maxProfitY = 0;
    minProfitY = 0;

    ResponseHttpRequest response = await CallApi.RequestHttp(
      global.ProfitStats,
      data: {"month": DateFormat("yyyy-MM").format(profitMonth)},
    );
    if (response.status == "SUCCESS") {
      profitStatsSummary = ProfitStatsSummary.fromMap(response.data["summary"]);
      for (var item in response.data["daily"]) {
        ProfitChartData row = ProfitChartData.fromMap(item);
        profitChartData.add(row);
        maxProfitY = [
          maxProfitY,
          row.sales,
          row.purchases,
          row.profit,
        ].reduce((a, b) => a > b ? a : b);
        minProfitY = [
          minProfitY,
          row.profit,
        ].reduce((a, b) => a < b ? a : b);
      }
      if (maxProfitY == 0) {
        maxProfitY = 1;
      }
      profitStatsReady.value = true;
    } else {
      print(response.message);
    }
    profitStatsLoading.value = false;
  }
}

class PieChartPushSaleData {
  final String title_fr;
  final String title_ar;
  final double value;
  final Color color;
  PieChartPushSaleData({
    required this.title_fr,
    required this.title_ar,
    required this.value,
    required this.color,
  });

  String getTitle(String locale) {
    switch (locale) {
      case "ar":
        return title_ar;
      default:
        return title_fr;
    }
  }
}

class LineChartPushSaleData {
  final double x;
  final double y;
  LineChartPushSaleData(
    this.x,
    this.y,
  );
}

class ProfitChartData {
  final DateTime date;
  final int day;
  final double sales;
  final double purchases;
  final double quantity;
  final double cashed;
  final double profit;

  ProfitChartData({
    required this.date,
    required this.day,
    required this.sales,
    required this.purchases,
    required this.quantity,
    required this.cashed,
    required this.profit,
  });

  static ProfitChartData fromMap(Map<String, dynamic> value) {
    return ProfitChartData(
      date: DateTime.parse(value["date"].toString()),
      day: int.parse(value["day"].toString()),
      sales: double.parse(value["sales"].toString()),
      purchases: double.parse(value["purchases"].toString()),
      quantity: double.parse(value["quantity"].toString()),
      cashed: double.parse(value["cashed"].toString()),
      profit: double.parse(value["profit"].toString()),
    );
  }
}

class ProfitStatsSummary {
  final double sales;
  final double purchases;
  final double quantity;
  final double cashed;
  final double profit;

  ProfitStatsSummary({
    required this.sales,
    required this.purchases,
    required this.quantity,
    required this.cashed,
    required this.profit,
  });

  static ProfitStatsSummary fromMap(Map<String, dynamic> value) {
    return ProfitStatsSummary(
      sales: double.parse(value["sales"].toString()),
      purchases: double.parse(value["purchases"].toString()),
      quantity: double.parse(value["quantity"].toString()),
      cashed: double.parse(value["cashed"].toString()),
      profit: double.parse(value["profit"].toString()),
    );
  }
}

class BarChartPushSaleData {
  final String title_ar;
  final String title;
  final double x;
  BarChartPushSaleData(
    this.title_ar,
    this.title,
    this.x,
  );

  String getTitle(String locale) {
    switch (locale) {
      case "ar":
        return title_ar;
      case "fr":
        return title;
      default:
        return title;
    }
  }
}

class StatsDay {
  final double total;
  final double average;
  final int client_count;
  final int visited;
  final int rest;
  StatsDay({
    required this.total,
    required this.average,
    required this.client_count,
    required this.visited,
    required this.rest,
  });
  static StatsDay fromMap(Map<String, dynamic> value) {
    return StatsDay(
        total: double.parse(value["total_amount"].toString()),
        average: double.parse(value["average_amount"].toString()),
        client_count: int.parse(value["total_visit"].toString()),
        visited: int.parse(value["client_ordered_count"].toString()),
        rest: int.parse(value["client_visit_missed"].toString()));
  }
}

class StatsDeliveryDay {
  final double total_cash;
  final double residual_amount;
  final int orders_total_delivery;
  final int orders_restant_delivery;
  StatsDeliveryDay({
    required this.total_cash,
    required this.residual_amount,
    required this.orders_total_delivery,
    required this.orders_restant_delivery,
  });
  static StatsDeliveryDay fromMap(Map<String, dynamic> value) {
    return StatsDeliveryDay(
      total_cash: value["total_cash"] != null
          ? double.parse(value["total_cash"].toString())
          : 0,
      residual_amount: value["residual_amount"] != null
          ? double.parse(value["residual_amount"].toString())
          : 0,
      orders_total_delivery: value["orders_total_delivery"] != null
          ? int.parse(value["orders_total_delivery"].toString())
          : 0,
      orders_restant_delivery: value["orders_restant_delivery"] != null
          ? int.parse(value["orders_restant_delivery"].toString())
          : 0,
    );
  }
}
