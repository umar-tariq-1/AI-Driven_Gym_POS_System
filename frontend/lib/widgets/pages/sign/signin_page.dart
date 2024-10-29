import 'package:flutter/material.dart';
import 'package:frontend/widgets/base/custom_scaffold.dart';
import 'package:frontend/widgets/pages/sign/signin.dart';
import 'package:frontend/widgets/pages/welcome.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  static const routePath = '/sign-in';

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.685,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: const Center(child: Signin()),
        ),
      ).then((_) {
        Navigator.of(context).popAndPushNamed(WelcomeScreen.routePath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(
      child: SizedBox(),
    );
  }
}
