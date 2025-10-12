import 'package:stockatlas/commons.dart';

class CategoryScreen extends StatelessWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override   
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController(category), tag: category);
    final stocks = StockData().stocks(category);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];
  
          return ListTile(
            title: Text(stock),
            trailing: Obx(() {  // Only this part rebuilds
              final price = controller.stockPrices[stock];
              return price != null 
                ? Text(price.toStringAsFixed(2),style: TextStyle(fontSize: 14),) 
                : const Text('Loading...');
            }),
            onTap: () {
              final price = controller.stockPrices[stock];
              print('Tapped $stock: $price');
            },
          );
        },
      ),
    );
  }
}