import 'package:stockatlas/commons.dart';

class CategoryController extends GetxController{
  final String category;
  CategoryController(this.category);

  var stockPrices = <String, double>{}.obs;
  var stockChanges = <String, double>{}.obs;
  var stockChangePercent = <String, double>{}.obs;
  var stockUp = <String, bool>{}.obs;

  final YahooFinanceDailyReader _reader = YahooFinanceDailyReader();
  Timer? _timer;

  /// NSE trading hours: 9:15 AM - 3:30 PM IST, Monday to Friday.
  /// (Exchange holidays are not handled yet.)
  static const int _marketOpenMinutes = 9 * 60 + 15;
  static const int _marketCloseMinutes = 15 * 60 + 30;

  static bool isMarketOpen(DateTime utc) {
    final ist = utc.add(const Duration(hours: 5, minutes: 30));

    if (ist.weekday == DateTime.saturday || ist.weekday == DateTime.sunday) {
      return false;
    }

    final minutesSinceMidnight = ist.hour * 60 + ist.minute;
    return minutesSinceMidnight >= _marketOpenMinutes &&
        minutesSinceMidnight < _marketCloseMinutes;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllPrices();
    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    _timer?.cancel();
    // The timer always runs; every tick checks whether the market is open, so
    // polling starts and stops automatically (and resumes after market close).
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (isMarketOpen(DateTime.now().toUtc())) {
        fetchAllPrices();
      }
    });
  }

  Future<void> fetchAllPrices() async {
    final stocks = StockData().stocks(category);

    await Future.wait(
      stocks.map((stock) async{
        try{
          final response = await _reader.getDailyDTOs("$stock.NS");
          if(response.candlesData.length >= 2){
            final latest = response.candlesData.last;
            final prev = response.candlesData[response.candlesData.length-2];

            final current = latest.close;
            final previous = prev.close;

            final change = current - previous;
            final percent = (change/previous)*100;

            stockPrices[stock] = current;
            stockChanges[stock] = change;
            stockChangePercent[stock] = percent;
            stockUp[stock] = change >= 0;
          }
        }catch (e){
          debugPrint("Error fetching $stock:$e");
        }
      })
    );
  }

  Map<String, dynamic> getStockChange(String stock){
    final change = stockChanges[stock];
    final percent = stockChangePercent[stock];
    final up = stockUp[stock];

    if(change == null || percent == null || up == null){
      return {
        "change": 0.0,
        "percent": 0.0,
        "up":true,
      };
    }

    return {
      "change": change,
      "percent": percent,
      "up": up,
    };
  } 

  @override 
  // ignore: unused_element
  void onClose(){
    _timer?.cancel();
    super.onClose();
  }
}