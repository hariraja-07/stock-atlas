import 'package:stockatlas/commons.dart';

class Home extends StatelessWidget{
  Home({super.key});

  final _data = StockData();

  @override
  Widget build(BuildContext context) {
    final categories = _data.categories;
    return Scaffold(
      appBar: AppBar(
        title: Text("StockAtlas"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(vertical: 20,horizontal: 20),
        child: Column(
          children: [
            const Text('Stocks Categories',style: TextStyle(color: Colors.blueGrey,fontSize: 18),),

            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder:(context, index) {
                  final category = categories[index];
              
                  return ListTile(
                    title: Text(category),
                    onTap: (){
                      Get.to(()=> CategoryScreen(category: category));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}