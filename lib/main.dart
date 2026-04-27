import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
import 'services/auth_session_service.dart';
import 'utility/constants.dart';

final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String _sentryDsn = String.fromEnvironment('SENTRY_DSN');
const String _sentryEnv =
    String.fromEnvironment('SENTRY_ENV', defaultValue: 'development');

bool _isSensitiveKey(String key) {
  final lower = key.toLowerCase();
  return lower.contains('password') ||
      lower.contains('token') ||
      lower.contains('refreshtoken') ||
      lower.contains('authorization') ||
      lower.contains('cookie') ||
      lower.contains('payment') ||
      lower.contains('card') ||
      lower.contains('cvv') ||
      lower.contains('address');
}

dynamic _scrubSensitiveData(dynamic value, {String? keyHint}) {
  if (keyHint != null && _isSensitiveKey(keyHint)) {
    return '[Filtered]';
  }

  if (value is Map) {
    final scrubbed = <String, dynamic>{};
    value.forEach((key, val) {
      final keyString = key.toString();
      scrubbed[keyString] =
          _scrubSensitiveData(val, keyHint: keyString.toLowerCase());
    });
    return scrubbed;
  }

  if (value is List) {
    return value.map((item) => _scrubSensitiveData(item)).toList();
  }

  return value;
}

SentryRequest? _scrubRequest(SentryRequest? request) {
  if (request == null) {
    return null;
  }

  final scrubbedHeaders = <String, String>{};
  request.headers.forEach((key, value) {
    scrubbedHeaders[key] = _isSensitiveKey(key) ? '[Filtered]' : value;
  });

  return request.copyWith(
    headers: scrubbedHeaders,
    data: _scrubSensitiveData(request.data),
    removeCookies: true,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final packageInfo = await PackageInfo.fromPlatform();
  final release = 'admin-web@${packageInfo.version}+${packageInfo.buildNumber}';
  final bool isProduction = _sentryEnv.toLowerCase() == 'production';

  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = _sentryEnv;
      options.release = release;
      options.tracesSampleRate = isProduction ? 0.1 : 1.0;
      options.profilesSampleRate = isProduction ? 0.0 : 0.1;
      options.beforeSend = (event, hint) {
        final scrubbedContexts = Contexts.fromJson(
          _scrubSensitiveData(event.contexts.toJson()) as Map<String, dynamic>,
        );

        return event.copyWith(
          request: _scrubRequest(event.request),
          contexts: scrubbedContexts,
          user: event.user?.copyWith(ipAddress: null),
        );
      };
    },
    appRunner: () async {
      FlutterError.onError = (details) async {
        FlutterError.presentError(details);
        await Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
          withScope: (scope) {
            scope.setTag('error_source', 'flutter_error');
          },
        );
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        Sentry.captureException(
          error,
          stackTrace: stackTrace,
          withScope: (scope) {
            scope.setTag('error_source', 'platform_dispatcher');
          },
        );
        return true;
      };

      final bool isAuthenticated =
          await AuthSessionService.instance.bootstrapSession();

      runApp(
        ChangeNotifierProvider(
          create: (context) => DataProvider()..init(),
          child: Consumer<DataProvider>(
            builder: (context, dataProvider, child) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                      create: (context) => MainScreenProvider()),
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
                child: MyApp(initialAuthenticated: isAuthenticated),
              );
            },
          ),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  final bool initialAuthenticated;

  const MyApp({super.key, required this.initialAuthenticated});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      title: 'Flutter Admin Panel',
      navigatorObservers: [SentryNavigatorObserver()],
      theme: ThemeData.dark().copyWith(
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      initialRoute: initialAuthenticated ? AppPages.HOME : AppPages.LOGIN,
      unknownRoute: GetPage(name: '/notFound', page: () => MainScreen()),
      defaultTransition: Transition.cupertino,
      getPages: AppPages.routes,
    );
  }
}
