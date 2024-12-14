import 'package:flutter/material.dart';
import 'package:frontend/data/local_storage.dart';
import 'package:frontend/widgets/pages/home_page.dart';
import 'package:frontend/widgets/pages/sign/forget_passsword_page.dart';
import 'package:frontend/widgets/pages/welcome_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  static const routePath = '/landing-page';

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Simulate a delay to show the loading screen
    await Future.delayed(const Duration(milliseconds: 2000));

    final localStorage = LocalStorage();
    final isLoggedIn = await localStorage.getItem('isLoggedIn') == true;
    final tokenExpirationTime =
        await localStorage.getItem('tokenExpirationTime');

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (mounted) {
      if (isLoggedIn &&
          tokenExpirationTime != null &&
          tokenExpirationTime > currentTime) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(HomePage.routePath, (route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            WelcomePage.routePath /* ForgetPasswordPage.routePath */,
            (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          "Loading...",
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
