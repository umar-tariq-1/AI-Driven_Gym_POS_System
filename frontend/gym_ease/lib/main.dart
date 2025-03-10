import 'package:gym_ease/states/client.dart';
import 'package:gym_ease/states/manager.dart';
import 'package:gym_ease/states/owner.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/states/trainer.dart';
import 'widgets/pages/routes.dart';
import 'package:gym_ease/widgets/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import './theme/theme.dart';

Color statusBarColor = /* Colors.black26 */ Colors.transparent;
Color appBarColor = colorScheme.shadow;
Color appBarTextColor = colorScheme.onPrimary;
Color backgroundColor = colorScheme.surface;

void main() {
  Get.put(ServerAddressController());
  Get.put(ClientController());
  Get.put(TrainerController());
  Get.put(OwnerController());
  Get.put(ManagerController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const routePath = '/';

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: List.empty());
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return GetMaterialApp(
        initialRoute: MyApp.routePath,
        routes: appRoutes,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'RalewayMedium',
          primaryColor: colorScheme.primary,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: colorScheme.primary,
            onPrimary: colorScheme.onPrimary,
            secondary: colorScheme.primary,
            onSecondary: colorScheme.onSecondary,
            tertiary: colorScheme.tertiary,
            onTertiary: colorScheme.onTertiary,
            error: colorScheme.tertiary,
            onError: colorScheme.onError,
            onSurface: colorScheme.onSurface,
            onSurfaceVariant: colorScheme.onSurfaceVariant,
            outlineVariant: colorScheme.outlineVariant,
          ),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: statusBarColor,
            ),
          ),
        ),
        home: const LandingPage());
  }
}
