import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/data/local_storage.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/widgets/base/custom_outlined_button.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

class RoundedWithCustomCursor extends StatefulWidget {
  const RoundedWithCustomCursor({Key? key}) : super(key: key);

  @override
  _RoundedWithCustomCursorState createState() =>
      _RoundedWithCustomCursorState();
}

class _RoundedWithCustomCursorState extends State<RoundedWithCustomCursor> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool error = false;
  int tries = 0;
  bool _enabled = true;
  String IP = "10.7.240.56";

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void verifyOTPRequest() async {
    setState(() {
      _enabled = false;
    });

    try {
      String? hashedOTP = await LocalStorage().getItem("hashedOTP") as String?;
      final response = await http.post(
        Uri.parse('http://$IP:3001/otp/verify'),
        body: {'hashedOTP': hashedOTP, 'enteredOTP': pinController.text},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)["message"])),
        );

        setState(() {
          _enabled = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)["message"])),
        );
      }
    } catch (e) {
      setState(() {
        _enabled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Unable to Send Verification Request')),
      );
    }
  }

  Future<void> sendOtpRequest() async {
    setState(() {
      _enabled = false;
    });

    try {
      final response = await http.post(
        Uri.parse('http://$IP:3001/otp/send'),
        body: {'email': 'umart823@gmail.com'},
      );

      if (response.statusCode == 200) {
        String hashedOTP = jsonDecode(response.body)["hashedOTP"];
        LocalStorage().setItem("hashedOTP", hashedOTP);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)["message"])),
        );

        setState(() {
          _enabled = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)["message"])),
        );
      }
    } catch (e) {
      setState(() {
        _enabled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to send OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              controller: pinController,
              focusNode: focusNode,
              defaultPinTheme: defaultPinTheme,
              validator: (value) {
                // return value == '222222' ? null : 'Pin is incorrect';
                if (value != null) {}
              },
              // onTap: () {
              //   if ((pinController.text).length == 6) {
              //     pinController.clear();
              //   }
              // },
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) async {
                tries++;
                if (tries >= 3) {
                  setState(() {
                    _enabled = false;
                  });
                }
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: focusedBorderColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: Colors.redAccent),
              ),
              enabled: _enabled,
            ),
          ),
          CustomOutlinedButton(buttonText: "Send OTP", onClick: sendOtpRequest),
          CustomOutlinedButton(buttonText: "Verify", onClick: verifyOTPRequest),
        ],
      ),
    );
  }
}
