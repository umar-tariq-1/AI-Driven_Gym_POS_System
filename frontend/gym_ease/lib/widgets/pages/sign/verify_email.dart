import 'package:flutter/material.dart';
import 'package:gym_ease/widgets/compound/otp.dart';

// ignore: must_be_immutable
class VerifyEmailPage extends StatefulWidget {
  String email;
  VoidCallback onSuccess;
  VerifyEmailPage({super.key, required this.email, required this.onSuccess});

  static const routePath = '/verify-email';

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final String id = "VerifyEmail";
  final TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10 + statusBarHeight, left: 3),
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
              Container(
                margin: EdgeInsets.fromLTRB(0, statusBarHeight + 60, 0, 0),
                height: screenHeight,
                width: screenWidth,
                child: OTP(
                  email: widget.email,
                  id: id,
                  onSuccess: widget.onSuccess,
                ),
              )
            ],
          ),
        ));
  }
}
