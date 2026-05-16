class LineTextPrinter {
  static int LEFT = 0;
  static int CENTER = 1;
  static int RIGHT = 2;
  static String TYPE_TEXT = "Text";
  static String TYPE_CODE_QR = "Code_Qr";
  String? format;

  String type;
  final String text1;
  String? text2;
  String? text3;
  String? text4;
  int align;
  bool isSubTitle;

  final int size;
  LineTextPrinter(
      {required this.text1,
      this.text2,
      this.text3,
      this.text4,
      required this.size,
      this.align = 1,
      required this.type,
      this.format,
      this.isSubTitle = false});
}

String FormatDateTime(DateTime d) {
  int yy = d.year;
  String mm = d.month < 10 ? "0${d.month}" : "${d.month}";
  String dd = d.day < 10 ? "0${d.day}" : "${d.day}";
  String h = d.hour < 10 ? "0${d.hour}" : "${d.hour}";
  String m = d.minute < 10 ? "0${d.minute}" : "${d.minute}";
  return "$dd/$mm/$yy - $h:$m";
}
