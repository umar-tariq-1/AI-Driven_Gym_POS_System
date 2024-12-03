import 'package:flutter/material.dart';
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
              const SizedBox(height: 57.5),
              SvgPicture.asset(
                'assets/images/register.svg',
                height: 280,
              ),
              const SizedBox(height: 30),
              const Register(),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
