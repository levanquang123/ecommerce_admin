import 'package:get/get.dart';
import '../../screens/main/main_screen.dart';

class AppPages {
  static const HOME = '/';

  static final routes = [
    GetPage(name: HOME, fullscreenDialog: true, page: () => MainScreen()),
  ];
}
