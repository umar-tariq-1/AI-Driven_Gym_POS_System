import 'package:flutter/material.dart';
import 'package:frontend/widgets/pages/sign/signin.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  static const routePath = '/sign-in';

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 70),
              SvgPicture.asset(
                'assets/images/signin.svg',
                height: 300,
              ),
              const SizedBox(height: 35),
              const Signin(),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
