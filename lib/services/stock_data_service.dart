import 'package:stockatlas/commons.dart';

class StockData {
  static final StockData _instance = StockData._internal();

  factory StockData() => _instance;

  StockData._internal();

  Map<String, List<String>> _data = {};

  static Future<void> init() async {
    final jsonString = await rootBundle.loadString('assets/data/stocks.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _instance._data = jsonMap.map((key, value) {
      return MapEntry(key, List<String>.from(value));
    });
  }

  List<String> get categories => _data.keys.toList();

  List<String> stocks(String category) => _data[category] ?? [];
}
