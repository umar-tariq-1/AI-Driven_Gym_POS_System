import 'package:flutter/material.dart';
import 'package:frontend/widgets/pages/sign/register_page.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';

import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../base/custom_scaffold.dart';
import '../base/welcome_button.dart';
import '../../theme/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const routePath = '/welcome';

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
              flex: 8,
              child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 22.5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WidgetAnimator(
                        incomingEffect:
                            WidgetTransitionEffects.incomingSlideInFromTop(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 200)),
                        child: Text("Welcome!",
                            style: TextStyle(
                                fontFamily: "RalewaySemiBold",
                                fontSize: 49.0,
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      TextAnimator(
                        'Simplify your fitness journey,',
                        initialDelay: const Duration(milliseconds: 1000),
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Theme.of(context).colorScheme.secondary),
                        incomingEffect:
                            WidgetTransitionEffects.incomingSlideInFromRight(
                                duration: const Duration(milliseconds: 300)),
                      ),
                      TextAnimator(
                        'One click, one platform.',
                        initialDelay: const Duration(milliseconds: 1000),
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Theme.of(context).colorScheme.secondary),
                        incomingEffect:
                            WidgetTransitionEffects.incomingSlideInFromRight(
                                duration: const Duration(milliseconds: 300)),
                      ),
                    ],
                  ))),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  const Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTapRoute: SigninPage.routePath,
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Register',
                      onTapRoute: RegisterPage.routePath,
                      color: Colors.white,
                      textColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
