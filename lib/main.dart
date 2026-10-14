import 'package:stockatlas/commons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StockData.init();
  runApp(const App());
}
