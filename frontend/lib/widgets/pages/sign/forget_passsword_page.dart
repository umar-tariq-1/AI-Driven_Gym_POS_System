import 'package:flutter/material.dart';
import 'package:frontend/widgets/base/pinput.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  static const routePath = '/forget-password';

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
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
              Center(child: RoundedWithCustomCursor())
            ],
          ),
        ));
  }
}
