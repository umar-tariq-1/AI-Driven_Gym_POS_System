import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/data/local_storage.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/widgets/base/custom_outlined_button.dart';
import 'package:frontend/widgets/base/timer.dart';
import "../../theme/theme.dart";
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
  int triesLeft = 3;
  bool _enabled = true;
  bool _isVerifyDisabled = true;
  String IP = "10.7.241.15";
  int timeLeft = 0;
  bool showTimer = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    checkOTPInfo();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void checkOTPInfo() async {
    var otpInfo = await LocalStorage().getItem("otpInfo");
    triesLeft = await LocalStorage().getItem("otpTriesLeft") ?? 3;

    setState(() {
      if ((otpInfo == null ||
              DateTime.now().millisecondsSinceEpoch ~/ 1000 >=
                  otpInfo["validTill"]) ||
          (triesLeft <= 0)) {
        _isVerifyDisabled = true;
        showTimer = false;
        timeLeft = 0;
      } else {
        _isVerifyDisabled = false;
        showTimer = true;
        timeLeft = (otpInfo["validTill"] -
            (DateTime.now().millisecondsSinceEpoch ~/ 1000) as int);
        showTimer = true;
      }
    });
  }

  void sendOtpRequest() async {
    setState(() {
      _isVerifyDisabled = false;
      _enabled = false;
      triesLeft = 3;
      errorText = null;
    });
    formKey.currentState?.validate();
    pinController.clear();

    try {
      final response = await http.post(
        Uri.parse('http://$IP:3001/otp/send'),
        body: {'email': 'umart823@gmail.com'},
      );

      if (response.statusCode == 200) {
        String hashedOTP = jsonDecode(response.body)["hashedOTP"];
        LocalStorage().setItem("otpInfo", {
          "gotOTP": true,
          "validTill": (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 90,
          "hashedOTP": hashedOTP
        });
        LocalStorage().setItem("otpTriesLeft", triesLeft);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)["message"])),
        );
        setState(() {
          showTimer = true;
          timeLeft = 89;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)["message"])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Unable to send OTP')),
      );
    }
    setState(() {
      _enabled = true;
    });
  }

  void verifyOTPRequest() async {
    if (pinController.text.length == 6 && showTimer) {
      setState(() {
        _enabled = false;
        _isVerifyDisabled = true;
      });

      try {
        var otpInfo = await LocalStorage().getItem("otpInfo");
        final response = await http.post(
          Uri.parse('http://$IP:3001/otp/verify'),
          body: {
            'hashedOTP': otpInfo["hashedOTP"],
            'enteredOTP': pinController.text
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonDecode(response.body)["message"])),
          );

          setState(() {
            _isVerifyDisabled = false;
            _enabled = true;
            errorText = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonDecode(response.body)["message"])),
          );
          if (jsonDecode(response.body)["message"] == "Invalid OTP") {
            setState(() {
              if (triesLeft > 1) {
                _isVerifyDisabled = false;
                _enabled = true;
              }
              triesLeft--;
              if (triesLeft > 1) {
                errorText = "Invalid OTP. Tries left: $triesLeft";
              } else if (triesLeft == 1) {
                errorText = "Invalid OTP. Only $triesLeft try left";
              } else if (triesLeft <= 0) {
                errorText = "No tries left. Request OTP again";
              }
            });
            formKey.currentState?.validate();
            await LocalStorage().setItem("otpTriesLeft", triesLeft);
          }
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
    } else {
      setState(() {
        errorText = !(pinController.text.length == 6)
            ? "Enter complete 6-digit OTP"
            : "OTP expired";
      });
      formKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color.fromARGB(255, 0, 60, 133);
    Color fillColor = Colors.grey.shade100;
    Color submittedFillColor = /* Colors.grey.shade200 */ fillColor;
    Color focusedBorderColor = colorScheme.primary;

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
              closeKeyboardWhenCompleted: true,
              keyboardType: TextInputType.number,
              length: 6,
              controller: pinController,
              focusNode: focusNode,
              defaultPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: borderColor),
                ),
              ),
              errorBuilder: (errorText, pin) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                      child: Text(
                    errorText ?? "",
                    style: TextStyle(color: colorScheme.error),
                  )),
                );
              },
              onChanged: (value) {
                setState(() {
                  errorText = null;
                });
              },
              validator: (value) {
                return errorText;
              },
              hapticFeedbackType: HapticFeedbackType.lightImpact,
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
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: submittedFillColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: colorScheme.error),
              ),
              enabled: _enabled,
            ),
          ),
          showTimer
              ? TimerWidget(
                  durationInSeconds: timeLeft,
                  beforeText: "OTP valid till: ",
                  onTimerComplete: () {
                    setState(() {
                      timeLeft = 0;
                      showTimer = false;
                    });
                  })
              : const SizedBox(),
          CustomOutlinedButton(
            buttonText: "Request OTP",
            onClick: sendOtpRequest,
            disabled: showTimer,
          ),
          CustomOutlinedButton(
            buttonText: "Verify",
            onClick: verifyOTPRequest,
            disabled: (_isVerifyDisabled && !_enabled) || !showTimer,
          ),
        ],
      ),
    );
  }
}
