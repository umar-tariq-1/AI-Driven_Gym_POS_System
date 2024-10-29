import 'package:frontend/widgets/pages/sign/register_page.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';
import 'package:frontend/widgets/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:frontend/widgets/pages/attempt_quiz.dart';
import 'package:frontend/widgets/pages/edit_quiz.dart';
import 'package:frontend/widgets/pages/new_quiz.dart';

Color statusBarColor = /* Colors.black26 */ Colors.transparent;
Color appBarColor = const Color.fromARGB(255, 38, 38, 38);
Color appBarTextColor = const Color.fromARGB(255, 255, 255, 255);
Color backgroundColor = const Color.fromARGB(255, 255, 255, 255);
Color primaryColor = const Color.fromARGB(255, 38, 38, 38);
Color secondaryColor = const Color.fromARGB(255, 255, 255, 255);
Color tertiaryColor = const Color.fromARGB(255, 255, 0, 0);
Color tertiaryDarkColor = const Color.fromARGB(255, 191, 0, 0);

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
  String currentPage = "Home Page";

  void _changePage(String page) {
    setState(() {
      currentPage = page;
    });
  }

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
        NewQuiz.routePath: (context) => const NewQuiz(),
        AttemptQuiz.routePath: (context) =>
            AttemptQuiz(mainContext: context, changePage: _changePage),
        EditQuiz.routePath: (context) => const EditQuiz(),
        WelcomeScreen.routePath: (context) => const WelcomeScreen(),
        RegisterPage.routePath: (context) => const RegisterPage(),
        SigninPage.routePath: (context) => const SigninPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'RalewayMedium',
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: secondaryColor,
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
                    "Quiz App",
                    style: TextStyle(
                      fontFamily: 'BeautifulPeople',
                      fontSize: 25.25,
                      letterSpacing: 0.6,
                      wordSpacing: 0.6,
                    ),
                  ),
                  backgroundColor: appBarColor,
                  foregroundColor: appBarTextColor,
                ))),
        drawer: CustomNavigationDrawer(
          active: 'Home Page',
          changePage: _changePage,
        ),
        backgroundColor: backgroundColor,
        body: Container(
          child: CustomElevatedButton(buttonText: 'Submit', onClick: (_) {}),
        ),
      ),
    );
  }
}
