import 'package:gym_ease/states/client.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/states/trainer.dart';
import 'package:gym_ease/widgets/pages/client/book%20classes/book_classes.dart';
import 'package:gym_ease/widgets/pages/client/ai_buddy/ai_buddy_page.dart';
import 'package:gym_ease/widgets/pages/client/home_page.dart';
import 'package:gym_ease/widgets/pages/client/live_classes/live_classes.dart';
import 'package:gym_ease/widgets/pages/landing_page.dart';
import 'package:gym_ease/widgets/pages/sign/forget_passsword_page.dart';
import 'package:gym_ease/widgets/pages/sign/register_page.dart';
import 'package:gym_ease/widgets/pages/sign/signin_page.dart';
import 'package:gym_ease/widgets/pages/trainer/live_classes/live_classes.dart';
import 'package:gym_ease/widgets/pages/trainer/manage%20classes/create_class.dart';
import 'package:gym_ease/widgets/pages/trainer/dashboard_page.dart';
import 'package:gym_ease/widgets/pages/trainer/manage%20classes/manage_classes_page.dart';
import 'package:gym_ease/widgets/pages/welcome_page.dart';
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
        routes: {
          WelcomePage.routePath: (context) => const WelcomePage(),
          RegisterPage.routePath: (context) => const RegisterPage(),
          SigninPage.routePath: (context) => const SigninPage(),
          ForgetPasswordPage.routePath: (context) =>
              ForgetPasswordPage(email: "No Email Entered"),
          ClientHomePage.routePath: (context) => const ClientHomePage(),
          LandingPage.routePath: (context) => const LandingPage(),
          CreateClassPage.routePath: (context) => const CreateClassPage(),
          ManageClassesPage.routePath: (context) => const ManageClassesPage(),
          TrainerDashboardPage.routePath: (context) =>
              const TrainerDashboardPage(),
          BookClassesPage.routePath: (context) => const BookClassesPage(),
          AIBuddyPage.routePath: (context) => const AIBuddyPage(),
          ClientLiveClassesPage.routePath: (context) =>
              const ClientLiveClassesPage(),
          TrainerLiveClassesPage.routePath: (context) =>
              const TrainerLiveClassesPage(),
        },
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
