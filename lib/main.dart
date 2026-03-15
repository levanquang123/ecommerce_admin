import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/data/data_provider.dart';
import 'core/routes/app_pages.dart';
import 'screens/brands/provider/brand_provider.dart';
import 'screens/category/provider/category_provider.dart';
import 'screens/coupon_code/provider/coupon_code_provider.dart';
import 'screens/dashboard/provider/dash_board_provider.dart';
import 'screens/login/provider/login_provider.dart';
import 'screens/main/main_screen.dart';
import 'screens/main/provider/main_screen_provider.dart';
import 'screens/notification/provider/notification_provider.dart';
import 'screens/order/provider/order_provider.dart';
import 'screens/posters/provider/poster_provider.dart';
import 'screens/sub_category/provider/sub_category_provider.dart';
import 'screens/variants/provider/variant_provider.dart';
import 'screens/variants_type/provider/variant_type_provider.dart';
import 'utility/constants.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(
    ChangeNotifierProvider(
      create: (context) => DataProvider()..init(),
      child: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => MainScreenProvider()),
              ChangeNotifierProvider(
                  create: (context) => LoginProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => CategoryProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => SubCategoryProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => BrandProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => VariantsTypeProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => VariantsProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => DashBoardProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => CouponCodeProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => PosterProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => OrderProvider(dataProvider)),
              ChangeNotifierProvider(
                  create: (context) => NotificationProvider(dataProvider)),
            ],
            child: MyApp(),
          );
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final String? token = box.read('token');
    
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      title: 'Flutter Admin Panel',
      theme: ThemeData.dark().copyWith(
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      initialRoute: (token != null && token.isNotEmpty) ? AppPages.HOME : AppPages.LOGIN,
      unknownRoute: GetPage(name: '/notFound', page: () => MainScreen()),
      defaultTransition: Transition.cupertino,
      getPages: AppPages.routes,
    );
  }
}
