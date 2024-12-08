import 'package:frontend/widgets/pages/home_page.dart';
import 'package:frontend/widgets/pages/landing_page.dart';
import 'package:frontend/widgets/pages/sign/forget_passsword_page.dart';
import 'package:frontend/widgets/pages/sign/register_page.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';
import 'package:frontend/widgets/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './theme/theme.dart';

Color statusBarColor = /* Colors.black26 */ Colors.transparent;
Color appBarColor = colorScheme.shadow;
Color appBarTextColor = colorScheme.onPrimary;
Color backgroundColor = colorScheme.surface;

void main() {
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

    return MaterialApp(
        initialRoute: MyApp.routePath,
        routes: {
          WelcomePage.routePath: (context) => const WelcomePage(),
          RegisterPage.routePath: (context) => const RegisterPage(),
          SigninPage.routePath: (context) => const SigninPage(),
          ForgetPasswordPage.routePath: (context) => const ForgetPasswordPage(),
          HomePage.routePath: (context) => const HomePage(),
          LandingPage.routePath: (context) => const LandingPage(),
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
