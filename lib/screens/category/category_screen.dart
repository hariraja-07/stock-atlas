import 'package:stockatlas/commons.dart';

class CategoryScreen extends StatelessWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController(category), tag: category);
    final stocks = StockData().stocks(category);

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ListView.builder(
        itemCount: stocks.length,
        itemBuilder: (context, index) {
          final stock = stocks[index];

          return ListTile(
            title: Text(stock),
            trailing: Obx(() {
              // Only this part rebuilds
              final price = controller.stockPrices[stock];
              final info = controller.getStockChange(stock);

              final change = info["change"] as double;
              final percent = info["percent"] as double;
              final up = info["up"] as bool;

              final color = (price == null)
                  ? Colors.black
                  : up
                  ? Colors.green
                  : (change != 0 ? Colors.red : Colors.black);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price != null ? price.toStringAsFixed(2) : 'Loading...',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} (${percent.toStringAsFixed(2)}%)',
                    style: TextStyle(color: color, fontSize: 14),
                  ),
                ],
              );
            }),
            onTap: () {
              final price = controller.stockPrices[stock];
              debugPrint('Tapped $stock: $price');
            },
          );
        },
      ),
    );
  }
}
