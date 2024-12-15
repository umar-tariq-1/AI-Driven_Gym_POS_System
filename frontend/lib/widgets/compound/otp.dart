import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:frontend/data/local_storage.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/states/server_address.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/custom_outlined_button.dart';
import 'package:frontend/widgets/base/snackbar.dart';
import 'package:frontend/widgets/base/timer.dart';
import 'package:frontend/widgets/pages/sign/register.dart';
import 'package:get/get.dart';
import "../../theme/theme.dart";
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

class OTP extends StatefulWidget {
  final String email;
  final String id;
  final VoidCallback? onSuccess;
  const OTP({super.key, required this.email, required this.id, this.onSuccess});

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
  int _timeLeft = 0;
  bool _showTimer = false;
  String? _errorText;
  bool _showEmailSentText = false;
  // bool _otpVerified = false;
  final serverAddressController = Get.find<ServerAddressController>();

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
      // _otpVerified = false;
    });
    formKey.currentState?.validate();
    pinController.clear();
    String subRoute = widget.id == 'ForgetPassword'
        ? 'otp'
        : widget.id == 'VerifyEmail'
            ? 'register/otp'
            : 'no-id-specified';
    try {
      final response = await http.post(
        Uri.parse('http://${serverAddressController.IP}:3001/$subRoute'),
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
        CustomSnackbar.showSuccessSnackbar(
            context, "Success!", jsonDecode(response.body)["message"]);
        setState(() {
          _showTimer = true;
          _showEmailSentText = true;
          _timeLeft = 89;
        });
      } else {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", jsonDecode(response.body)["message"]);
      }
    } catch (e) {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Sorry, couldn't request to server");
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
          Uri.parse('http://${serverAddressController.IP}:3001/otp/verify'),
          body: {
            'hashedOTP': otpInfo["hashedOTP"],
            'enteredOTP': pinController.text
          },
        );

        if (response.statusCode == 200) {
          CustomSnackbar.showSuccessSnackbar(
              context, "Success!", jsonDecode(response.body)["message"]);
          // SecureStorage().deleteItem("${widget.id}otpEmail");
          setState(() {
            _isVerifyDisabled = false;
            _enabled = true;
            _errorText = null;
            // _otpVerified = true;
          });
          widget.onSuccess == null
              ? showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ChangePasswordDialog(
                      id: widget.id,
                    );
                  },
                )
              : widget.onSuccess!();
        } else {
          CustomSnackbar.showFailureSnackbar(
              context, "Oops!", jsonDecode(response.body)["message"]);

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
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", "Sorry, couldn't request to server");
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
    const Color focusedBorderColor = Color.fromARGB(255, 0, 60, 133);
    Color fillColor = Colors.grey.shade200;
    Color submittedFillColor = fillColor;
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
        border: Border.all(color: focusedBorderColor),
      ),
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 35),
          SvgPicture.asset(
            'assets/images/OTP.svg',
            height: 240,
          ),
          const SizedBox(
            height: 75,
          ),
          Text(
            _showEmailSentText
                ? "Enter the OTP sent to Email"
                : "Couldn't send OTP to Email",
            style: const TextStyle(
                color: Color.fromARGB(255, 138, 138, 138),
                fontSize: 19.25,
                letterSpacing: 0.5),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            widget.email,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 19,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 60,
          ),
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
                        color: fillColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: /* borderColor */ Colors.grey.shade300),
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
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: submittedFillColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: /* focusedBorderColor */
                                Colors.grey.shade300),
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
                    : _showEmailSentText
                        ? Column(
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'OTP Expired. Request again',
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontFamily: "RalewayMedium",
                                  fontSize: 15,
                                ),
                              )
                            ],
                          )
                        : const SizedBox(),
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
                      maxWidthScreenFactor: 1,
                      disabled: (_isVerifyDisabled && !_enabled) || !_showTimer,
                    )),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  String id;
  ChangePasswordDialog({super.key, required this.id});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final Map controllers = {
    'password': TextEditingController(),
    'confirmPassword': TextEditingController()
  };
  final FocusNode _focusNode = FocusNode();
  final _passwordFormKey = GlobalKey<FormState>();
  bool _passwordHasFocus = false;
  bool _obscureText = true;
  final serverAddressController = Get.find<ServerAddressController>();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _passwordHasFocus = true;
        });
      } else {
        _passwordHasFocus = false;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      backgroundColor: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(18, 25, 18, 17.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Enter New Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Form(
              key: _passwordFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    focusNode: _focusNode,
                    keyboardType: TextInputType.visiblePassword,
                    controller: controllers['password'],
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      label: const Text('Password'),
                      labelStyle: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black45,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Password must contain at least one uppercase letter';
                      }
                      if (!RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Password must contain at least one number';
                      }
                      return null;
                    },
                    onTap: () {
                      if (!_passwordHasFocus) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const PasswordRequirementsDialog();
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15.0),
                  TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: controllers['confirmPassword'],
                    obscureText: true,
                    decoration: InputDecoration(
                      label: const Text('Confirm Password'),
                      labelStyle: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                      hintText: 'Enter Password',
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                      ),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm Password is required';
                      }
                      if (value != controllers['password'].text) {
                        return 'Passwords donot match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              child:
                  const Text('Change Password', style: TextStyle(fontSize: 18)),
              onPressed: () async {
                String email =
                    await SecureStorage().getItem("${widget.id}otpEmail");
                try {
                  if (_passwordFormKey.currentState?.validate() ?? false) {
                    var url = Uri.parse(
                        'http://${serverAddressController.IP}:3001/otp/update-password');
                    var response = await http.put(url, body: {
                      'email': email,
                      'password': controllers['password'].text,
                      'confirmPassword': controllers['password'].text
                    });

                    if (response.statusCode == 200) {
                      CustomSnackbar.showSuccessSnackbar(
                          context, "Success!", "Password Updated Successfully");
                      controllers['password'].clear();
                      controllers['confirmPassword'].clear();
                      SecureStorage().deleteItem("${widget.id}otpEmail");
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    } else {
                      CustomSnackbar.showFailureSnackbar(context, "Oops!",
                          jsonDecode(response.body)["message"]);
                    }
                  }
                } catch (e) {
                  CustomSnackbar.showFailureSnackbar(
                      context, "Oops!", "Sorry, couldn't request to server");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
