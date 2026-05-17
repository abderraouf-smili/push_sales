library push_sale.globals;

import 'package:push_sale/config/app_config.dart';

// String urlAPI = "https://softstarter.dz/api/push_sale/public";
// String urlAPI = "https://google.com/api/push_sale/public";
String urlAPI = AppConfig.apiBaseUrl;

String version = "2.0.0";
String build = "18/05/2026";
String team = "Soft-Starter";

/* PREFERENCES APP */
bool force_cash_before_print = false;
bool PackingWithBox = false;
int alertQuantity = 1;
Duration timeOut = const Duration(seconds: 300);
bool delivery_proof = false;
List<String> weekend = ["friday"];
String maps_key = AppConfig.googleMapsApiKey;
/*------------------ */
String getTime = "timenow";

// Route API
String registerUser = "register";
String login = "login";

String checkUser = "userdetail";
String infoActor = "actorinfo";
String createActor = "createactor";
String updateActor = "updateactor";
String profileActor = "actorprofile";
String isActorProfiled = "isprofiled";
String actorsList = "actorslist";

String listClient = "clients";
String typePointVente = "typepointsvente";
String updateClient = "updateclient";
String createClient = "createclient";
String globalReceivable = "globalreceivable";
String detailReceivale = "detailreceivable";
String receivaleByDate = "receivablebydate";
String cities = "cities";
String wilayas = "states";

String reasonNoDeliverySale = "reasonlist";
String saveVisit = "createvisit";

String fullVariant = "variants";
String productsList = "products";
String fullPromotion = "promotions";

String catalogueRoute = "catalogue";

String saveOrder = "createorder";
String getCurrentOrders = "currentorders";
String getOrders = "currentorders";
String statscategory = "stats_month";
String DeliveryStatsDay = "deliverystats";
String ProfitStats = "profitstats";
String MainStatsOrders = "statustatsorders";

String listWarehouses = "warehouses";

String savePurchaseOrder = "createpurchaseorder";
String purchaseproductsList = "purchaseproducts";
String purchasevariantList = "purchasevariants";

String promotionsList = "listpromotions";
String savePromotion = "setpromotion";

String Permissions = "permissions";

String orderReadyToPack = "topackorders";
String PurchaseOrdersToShip = "toshiporders";
String shipOrder = "shiporder";
String cashOrder = "cashorder";
String sendCashForAll = "sendcashforall";
String url_PlannedDate = "changeplanneddate";
String statusOrder = "statusorder";

String saveTransfer = "createtransfer";
String getTransfer = "listtransfer";
String currentStock = "currentstock";
String confirmTransfer = "confirmtransfer";
String adjustement = "adjustement";

String sendMessageChat = "sendmessage";
String getMessageChat = "getmessage";

String CouponsList = "listcoupons";
String CreateCoupon = "createcoupons";
String checkCoupon = "checkcoupon";
String reNewOrder = "reneworder";

String pricelist = "pricelists";
//
//
//

//personal data
String deviceId = "";
String firstName = "";
String lastName = "";

List<String> weekdays = [
  "saturday",
  "sunday",
  "monday",
  "tuesday",
  "thursday",
  "wednesday",
  "friday"
];
