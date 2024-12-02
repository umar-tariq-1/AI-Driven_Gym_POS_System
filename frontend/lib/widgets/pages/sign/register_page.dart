import 'package:flutter/material.dart';
import 'package:frontend/widgets/base/custom_scaffold.dart';
import 'package:frontend/widgets/pages/welcome.dart';
import './register.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const routePath = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
            child: const Center(child: Register()),
          ),
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
