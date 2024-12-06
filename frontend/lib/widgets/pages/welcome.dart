import 'package:flutter/material.dart';
import 'package:frontend/widgets/pages/sign/register_page.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_svg/flutter_svg.dart';

import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../base/welcome_button.dart';
import '../../theme/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const routePath = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(children: [
          SvgPicture.asset(
            'assets/images/welcome_background.svg',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width >=
                    MediaQuery.of(context).size.height
                ? MediaQuery.of(context).size.width
                : null,
            height: MediaQuery.of(context).size.height >
                    MediaQuery.of(context).size.width
                ? MediaQuery.of(context).size.height
                : null,
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.125),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(85),
                    child: Image.asset(
                      'assets/images/welcome.gif',
                      height: 360,
                      fit: BoxFit.cover,
                    ),
                    //     SvgPicture.asset(
                    //   'assets/images/welcome2.svg',
                    //   height: 360,
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(
                        top: 40,
                        bottom: MediaQuery.of(context).size.height * 0.20,
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
                          incomingEffect:
                              WidgetTransitionEffects.incomingSlideInFromRight(
                                  duration: const Duration(milliseconds: 300)),
                        ),
                        TextAnimator(
                          'One click, one platform.',
                          initialDelay: const Duration(milliseconds: 200),
                          style: TextStyle(
                              fontSize: 21.0, color: colorScheme.primary),
                          incomingEffect:
                              WidgetTransitionEffects.incomingSlideInFromRight(
                                  duration: const Duration(milliseconds: 300)),
                        ),
                      ],
                    )),
                Row(
                  children: [
                    Expanded(
                      child: WelcomeButton(
                        buttonText: 'Sign in',
                        onTapRoute: SigninPage.routePath,
                        color: Colors.transparent,
                        textColor: colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: WelcomeButton(
                        buttonText: 'Register',
                        onTapRoute: RegisterPage.routePath,
                        color: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
