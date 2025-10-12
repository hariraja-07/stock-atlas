import 'package:stockatlas/commons.dart';

class CategoryController extends GetxController{
  final String category;
  CategoryController(this.category);

  var stockPrices = <String, double>{}.obs;
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
          if(response.candlesData.isNotEmpty){
            final latest = response.candlesData.last;
            stockPrices[stock] = latest.close;
          }
        }catch (e){
          print("Error fetching $stock:$e");
        }
      })
    );
  }

  @override 
  // ignore: unused_element
  void onClose(){
    _timer?.cancel();
    super.onClose();
  }
}