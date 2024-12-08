import 'package:flutter/material.dart';
import 'package:frontend/data/local_storage.dart';
import 'package:frontend/widgets/pages/home_page.dart';
import 'package:frontend/widgets/pages/sign/register_page.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_svg/flutter_svg.dart';

import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../base/welcome_button.dart';
import '../../theme/theme.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  // Height: 972.1518987341772
  // Width: 437.46835443037975

  static const routePath = '/welcome';

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final GlobalKey _backgroundKey = GlobalKey();
  double _backgroundHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          _backgroundKey.currentContext?.findRenderObject() as RenderBox;
      setState(() {
        _backgroundHeight = renderBox.size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(children: [
          SvgPicture.asset(
            'assets/images/welcome_background.svg',
            key: _backgroundKey,
            fit: BoxFit.cover,
            width: screenWidth >= screenHeight ? screenWidth : null,
            height: screenHeight > screenWidth ? screenHeight : null,
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: _backgroundHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: _backgroundHeight * 0.11),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(85),
                        child: Image.asset(
                          'assets/images/welcome.gif',
                          width: screenWidth <= _backgroundHeight * 0.37
                              ? screenWidth - 40
                              : null,
                          height: _backgroundHeight * 0.37,
                          fit: BoxFit.cover,
                        ),
                        // child: SvgPicture.asset(
                        //   'assets/images/.svg',
                        //   width: screenWidth <= _backgroundHeight * 0.37
                        //       ? screenWidth - 40
                        //       : null,
                        //   height: _backgroundHeight * 0.37,
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(
                          bottom: _backgroundHeight * 0.14,
                          left: 22.5,
                          right: 22.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // WidgetAnimator(
                          //   incomingEffect:
                          //       WidgetTransitionEffects.incomingSlideInFromTop(
                          //           duration: const Duration(milliseconds: 800),
                          //           delay: const Duration(milliseconds: 200)),
                          //   child: Text("Welcome!",
                          //       style: TextStyle(
                          //           fontFamily: "RalewaySemiBold",
                          //           fontSize: 49.0,
                          //           color: colorScheme.primary)),
                          // ),
                          // const SizedBox(
                          //   height: 25,
                          // ),
                          TextAnimator(
                            'Simplify your fitness journey,',
                            initialDelay: const Duration(milliseconds: 200),
                            style: TextStyle(
                                fontSize: 21.0, color: colorScheme.primary),
                            incomingEffect: WidgetTransitionEffects
                                .incomingSlideInFromRight(
                                    duration:
                                        const Duration(milliseconds: 300)),
                          ),
                          TextAnimator(
                            'One click, one platform.',
                            initialDelay: const Duration(milliseconds: 200),
                            style: TextStyle(
                                fontSize: 21.0, color: colorScheme.primary),
                            incomingEffect: WidgetTransitionEffects
                                .incomingSlideInFromRight(
                                    duration:
                                        const Duration(milliseconds: 300)),
                          ),
                        ],
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: WelcomeButton(
                          buttonText: 'Sign in',
                          color: Colors.transparent,
                          textColor: colorScheme.primary,
                          onClick: () async {
                            final localStorage = LocalStorage();
                            final isLoggedIn =
                                await localStorage.getItem('isLoggedIn') ==
                                    true;
                            final tokenExpirationTime = await localStorage
                                .getItem('tokenExpirationTime');

                            final currentTime =
                                DateTime.now().millisecondsSinceEpoch;
                            if (isLoggedIn &&
                                tokenExpirationTime != null &&
                                tokenExpirationTime > currentTime) {
                              Navigator.of(context)
                                  .pushNamed(HomePage.routePath);
                            } else {
                              Navigator.of(context)
                                  .pushNamed(SigninPage.routePath);
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: WelcomeButton(
                          buttonText: 'Register',
                          color: colorScheme.primary,
                          textColor: colorScheme.onPrimary,
                          onClick: () {
                            Navigator.of(context)
                                .pushNamed(RegisterPage.routePath);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
