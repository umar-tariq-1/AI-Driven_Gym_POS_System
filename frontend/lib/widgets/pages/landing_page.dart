import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/widgets/pages/home_page.dart';
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

    final secureStorage = SecureStorage();
    final isLoggedIn = await secureStorage.getItem('isLoggedIn');
    final auth = await secureStorage.getItem('authToken');
    final tokenExpirationTime =
        await secureStorage.getItem('tokenExpirationTime');

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (mounted) {
      if (isLoggedIn == "true" &&
          tokenExpirationTime != null &&
          int.parse(tokenExpirationTime) > currentTime) {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/signin.svg',
              height: 300,
            )
          ],
        ),
      ),
    );
  }
}
