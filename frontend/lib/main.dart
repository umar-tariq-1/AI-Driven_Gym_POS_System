import 'package:frontend/widgets/base/custom_outlined_button.dart';
import 'package:frontend/widgets/pages/sign/register_page.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';
import 'package:frontend/widgets/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
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
        WelcomeScreen.routePath: (context) => const WelcomeScreen(),
        RegisterPage.routePath: (context) => const RegisterPage(),
        SigninPage.routePath: (context) => const SigninPage(),
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
      home: Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3.5),
                  ),
                ]),
                child: AppBar(
                  toolbarHeight: 68,
                  centerTitle: true,
                  leading: Builder(
                    builder: (context) {
                      return Container(
                          margin: const EdgeInsets.only(left: 5),
                          child: IconButton(
                            icon: const Icon(Icons.menu_rounded),
                            color: appBarTextColor,
                            iconSize: 29,
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          ));
                    },
                  ),
                  title: const Text(
                    " Gym Partner",
                    style: TextStyle(
                      fontFamily: 'BeautifulPeople',
                      fontSize: 25,
                      letterSpacing: 0.9,
                      wordSpacing: 0.6,
                    ),
                  ),
                  backgroundColor: appBarColor,
                  foregroundColor: appBarTextColor,
                ))),
        drawer: const CustomNavigationDrawer(
          active: 'Home Page',
        ),
        backgroundColor: backgroundColor,
        body: Container(
          child: Row(
            children: [
              CustomElevatedButton(
                  buttonText: 'Submit', onClick: () {}, active: false),
              CustomOutlinedButton(
                buttonText: 'Submit',
                onClick: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
