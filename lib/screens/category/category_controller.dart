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

  final int marketOpenHour = 9;
  final int marketCloseHour = 16;

  @override  
  void onInit(){
    super.onInit();
    _fetchAndSchedule();
  }

  void _fetchAndSchedule() async {
    final now = DateTime.now();

    bool marketOpen = now.hour >= marketOpenHour && now.hour < marketCloseHour;

    await fetchAllPrices();

    if(marketOpen){
      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 15), (_) async {
        await fetchAllPrices();
      });
    }
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
          print("Error fetching $stock:$e");
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