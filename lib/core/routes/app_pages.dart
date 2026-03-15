import 'package:get/get.dart';
import '../../screens/main/main_screen.dart';
import '../../screens/login/login_screen.dart';

class AppPages {
  static const HOME = '/';
  static const LOGIN = '/login';

  static final routes = [
    GetPage(name: HOME, page: () => MainScreen()),
    GetPage(name: LOGIN, page: () => const LoginScreen()),
  ];
}
