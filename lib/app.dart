import 'package:stockatlas/commons.dart';

class App extends StatelessWidget{
    const App({super.key});

    @override  
    Widget build(BuildContext context){
        return GetMaterialApp(
            debugShowCheckedModeBanner:false,
            title: 'StockAtlas',
            home: Home(),
        );
    }
}