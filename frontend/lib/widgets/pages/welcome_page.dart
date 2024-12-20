import 'package:flutter/material.dart';
import 'package:frontend/data/local_storage.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/states/server_address.dart';
import 'package:frontend/widgets/pages/client/home_page.dart';
import 'package:frontend/widgets/pages/sign/register_page.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
                    margin: EdgeInsets.only(top: _backgroundHeight * 0.12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(/* 80 */ 0),
                        child: GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ChangeServerIPDialog();
                              },
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/images/gym 6.svg',
                            width: screenWidth <= _backgroundHeight * 0.37
                                ? screenWidth - 40
                                : null,
                            height: _backgroundHeight * 0.37,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(
                          bottom: _backgroundHeight * 0.14,
                          left: 15,
                          right: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextAnimator(
                            'Transform your gym experience,',
                            textAlign: TextAlign.center,
                            initialDelay: const Duration(milliseconds: 250),
                            style: const TextStyle(
                                fontSize: 21.0,
                                color: Color.fromARGB(255, 11, 82, 168)),
                            incomingEffect:
                                WidgetTransitionEffects.outgoingScaleUp(
                                    duration:
                                        const Duration(milliseconds: 300)),
                          ),
                          TextAnimator(
                            'Everything you need, online and easy.',
                            textAlign: TextAlign.center,
                            initialDelay: const Duration(milliseconds: 250),
                            style: const TextStyle(
                                fontSize: 21.0,
                                color: Color.fromARGB(255, 11, 82, 168)),
                            incomingEffect:
                                WidgetTransitionEffects.outgoingScaleUp(
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
                            final secureStorage = SecureStorage();
                            final isLoggedIn =
                                await secureStorage.getItem('isLoggedIn') ==
                                    'true';
                            final tokenExpirationTime = await secureStorage
                                .getItem('tokenExpirationTime');

                            final currentTime =
                                DateTime.now().millisecondsSinceEpoch;
                            if (isLoggedIn &&
                                tokenExpirationTime != null &&
                                tokenExpirationTime > currentTime) {
                              Navigator.of(context)
                                  .pushNamed(ClientHomePage.routePath);
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

class ChangeServerIPDialog extends StatelessWidget {
  final serverAddressController = Get.find<ServerAddressController>();
  final TextEditingController controller = TextEditingController();

  ChangeServerIPDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    controller.text = serverAddressController.IP;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      backgroundColor: backgroundColor,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(18, 25, 18, 17.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Change Server\'s IP Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: controller,
                  decoration: InputDecoration(
                    label: const Text('IP Address'),
                    labelStyle:
                        const TextStyle(overflow: TextOverflow.ellipsis),
                    hintText: 'Enter IP Address',
                    hintStyle: const TextStyle(color: Colors.black26),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon:
                        const Icon(Icons.dns_outlined, color: Colors.black54),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextButton(
              child: const Text('Update', style: TextStyle(fontSize: 18)),
              onPressed: () {
                serverAddressController.setIP(controller.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
