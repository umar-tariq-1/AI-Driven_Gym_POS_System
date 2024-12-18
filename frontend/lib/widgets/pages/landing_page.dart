import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/widgets/pages/client/home_page.dart';
import 'package:frontend/widgets/pages/trainer/dashboard_page.dart';
import 'package:frontend/widgets/pages/welcome_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  static const routePath = '/landing-page';

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final SecureStorage _secureStorage = SecureStorage();
  String _isLoggedIn = "false";
  String _tokenExpirationTime = "0";
  final currentTime = DateTime.now().millisecondsSinceEpoch;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    if (mounted) {
      _isLoggedIn = await _secureStorage.getItem('isLoggedIn');
      _tokenExpirationTime =
          await _secureStorage.getItem('tokenExpirationTime');
      userData = await _secureStorage.getItem('userData');
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
              'assets/images/gym 2.svg',
              width: MediaQuery.of(context).size.width * 0.8,
            ),
            const SizedBox(height: 50),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Simplify your fitness journey,',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 21.0, color: Color.fromARGB(255, 11, 82, 168)),
                ),
                Text(
                  'One click, one platform.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21.0,
                    color: Color.fromARGB(255, 11, 82, 168),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 2000),
                onEnd: () async {
                  if (_isLoggedIn == "true" &&
                      int.parse(_tokenExpirationTime) > currentTime) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        userData['accType'] == "Trainer"
                            ? TrainerDashboardPage.routePath
                            : ClientHomePage.routePath,
                        (route) => false);
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        WelcomePage.routePath, (route) => false);
                  }
                },
                builder: (context, value, _) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[300],
                      color: const Color.fromARGB(255, 11, 82, 168),
                      minHeight: 5,
                    ),
                  );
                }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
