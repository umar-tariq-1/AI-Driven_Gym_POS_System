import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:frontend/data/local_storage.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/custom_outlined_button.dart';
import 'package:frontend/widgets/base/timer.dart';
import "../../theme/theme.dart";
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

class OTP extends StatefulWidget {
  final String email;
  final String id;
  const OTP({super.key, this.email = "No Email Entered", this.id = ""});

  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  int _triesLeft = 3;
  bool _enabled = true;
  bool _isVerifyDisabled = true;
  String IP = "10.7.240.185";
  int _timeLeft = 0;
  bool _showTimer = false;
  String? _errorText;
  bool _showEmailSentText = false;
  bool _otpVerified = false;

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
    var otpInfo = await SecureStorage().getItem("${widget.id}otpInfo");
    _triesLeft = int.tryParse(
            await SecureStorage().getItem("${widget.id}otp_triesLeft") ??
                '3') ??
        3;
    var lastEmail = await SecureStorage().getItem("${widget.id}otpEmail");

    setState(() {
      if ((otpInfo == null ||
              DateTime.now().millisecondsSinceEpoch ~/ 1000 >=
                  otpInfo["validTill"]) ||
          (_triesLeft <= 0) ||
          lastEmail != widget.email) {
        _isVerifyDisabled = true;
        _showTimer = false;
        _timeLeft = 0;
        sendOtpRequest();
      } else {
        _isVerifyDisabled = false;
        _showTimer = true;
        _timeLeft = otpInfo["validTill"] -
            (DateTime.now().millisecondsSinceEpoch ~/ 1000);
        _showTimer = true;
      }
    });
  }

  void sendOtpRequest() async {
    setState(() {
      _isVerifyDisabled = false;
      _enabled = false;
      _triesLeft = 3;
      _errorText = null;
      _otpVerified = false;
    });
    formKey.currentState?.validate();
    pinController.clear();

    try {
      final response = await http.post(
        Uri.parse('http://$IP:3001/otp/send'),
        body: {'email': widget.email},
      );

      if (response.statusCode == 200) {
        String hashedOTP = jsonDecode(response.body)["hashedOTP"];
        SecureStorage().setItem("${widget.id}otpInfo", {
          "gotOTP": true,
          "validTill": (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 90,
          "hashedOTP": hashedOTP
        });
        SecureStorage().setItem("${widget.id}otp_triesLeft", _triesLeft);
        SecureStorage().setItem("${widget.id}otpEmail", widget.email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonDecode(response.body)["message"])),
        );
        setState(() {
          _showTimer = true;
          _showEmailSentText = true;
          _timeLeft = 89;
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
    if (pinController.text.length == 6 && _showTimer) {
      setState(() {
        _enabled = false;
        _isVerifyDisabled = true;
      });

      try {
        var otpInfo = await SecureStorage().getItem("${widget.id}otpInfo");
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
          SecureStorage().deleteItem("${widget.id}otpEmail");
          setState(() {
            _isVerifyDisabled = false;
            _enabled = true;
            _errorText = null;
            _otpVerified = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonDecode(response.body)["message"])),
          );
          if (jsonDecode(response.body)["message"] == "Invalid OTP") {
            setState(() {
              if (_triesLeft > 1) {
                _isVerifyDisabled = false;
                _enabled = true;
              }
              _triesLeft--;
              if (_triesLeft > 1) {
                _errorText = "Invalid OTP. Tries left: $_triesLeft";
              } else if (_triesLeft == 1) {
                _errorText = "Invalid OTP. Only $_triesLeft try left";
              } else if (_triesLeft <= 0) {
                _errorText = "No tries left. Request OTP again";
              }
            });
            formKey.currentState?.validate();
            await SecureStorage()
                .setItem("${widget.id}otp_triesLeft", _triesLeft);
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
        _errorText = !(pinController.text.length == 6)
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
    final screenWidth = MediaQuery.of(context).size.width;

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

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          SvgPicture.asset(
            'assets/images/OTP.svg',
            height: 250,
          ),
          const SizedBox(
            height: 75,
          ),
          _showEmailSentText
              ? const Text(
                  "Enter the OTP sent to Email",
                  style: TextStyle(
                      color: Color.fromARGB(255, 138, 138, 138),
                      fontSize: 19.25,
                      letterSpacing: 0.5),
                )
              : const SizedBox(),
          _showEmailSentText
              ? const SizedBox(
                  height: 2,
                )
              : const SizedBox(),
          _showEmailSentText
              ? Text(
                  widget.email,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 19,
                      fontWeight: FontWeight.bold),
                )
              : const SizedBox(),
          _showEmailSentText
              ? const SizedBox(
                  height: 60,
                )
              : const SizedBox(),
          Form(
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
                        color: /* fillColor */ Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: /* borderColor */ Colors.transparent),
                      ),
                    ),
                    errorBuilder: (_errorText, pin) {
                      return Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 6),
                        child: Center(
                            child: Text(
                          _errorText ?? "",
                          style: TextStyle(color: colorScheme.error),
                        )),
                      );
                    },
                    onChanged: (value) {
                      setState(() {
                        _errorText = null;
                      });
                    },
                    validator: (value) {
                      return _errorText;
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
                        border: Border.all(color: borderColor),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: /* submittedFillColor */ Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: /* focusedBorderColor */ Colors.transparent),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyBorderWith(
                      border: Border.all(color: colorScheme.error),
                    ),
                    enabled: _enabled,
                  ),
                ),
                _showTimer
                    ? Column(
                        children: [
                          const SizedBox(height: 20),
                          TimerWidget(
                              durationInSeconds: _timeLeft,
                              beforeText: "OTP valid till: ",
                              onTimerComplete: () {
                                setState(() {
                                  _timeLeft = 0;
                                  _showTimer = false;
                                });
                              }),
                        ],
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'OTP Expired. Request again',
                            style: TextStyle(
                              color: colorScheme.error,
                              fontFamily: "RalewayMedium",
                              fontSize: 14,
                            ),
                          )
                        ],
                      ),
                const SizedBox(height: 70),
                SizedBox(
                  width: screenWidth * 0.9,
                  child: CustomElevatedButton(
                    buttonText: "Request OTP",
                    onClick: sendOtpRequest,
                    disabled: _showTimer,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                    width: screenWidth * 0.9,
                    child: CustomOutlinedButton(
                      buttonText: "Verify",
                      onClick: verifyOTPRequest,
                      transitionColor: true,
                      maxWidthScreenFactor: 1,
                      disabled: (_isVerifyDisabled && !_enabled) || !_showTimer,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
