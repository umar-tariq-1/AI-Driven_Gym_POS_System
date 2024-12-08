import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import './register.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const routePath = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12 + statusBarHeight, left: 3),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 27,
                      ),
                    )),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Container(
                  //   margin: EdgeInsets.only(top: 20 + statusBarHeight, left: 3),
                  //   child: Align(
                  //       alignment: Alignment.topLeft,
                  //       child: IconButton(
                  //         onPressed: () {
                  //           Navigator.of(context).pop();
                  //         },
                  //         icon: const Icon(
                  //           Icons.arrow_back_rounded,
                  //           size: 27,
                  //         ),
                  //       )),
                  // ),
                  const SizedBox(height: 60),
                  SvgPicture.asset(
                    'assets/images/register.svg',
                    height: 270,
                  ),
                  const SizedBox(height: 25),
                  const Register(),
                  const SizedBox(height: 35),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
