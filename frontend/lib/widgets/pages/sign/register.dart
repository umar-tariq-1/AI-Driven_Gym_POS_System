import 'package:flutter/material.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/states/server_address.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/snackbar.dart';
import 'package:frontend/widgets/pages/client/home_page.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';
import 'package:frontend/widgets/pages/trainer/dashboard_page.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './verify_email.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/services.dart';

import '../../../theme/theme.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Map controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController()
  };
  bool _agreePersonalData = false;
  bool isLoading = false;
  String? _gender = '';
  String? _accType = '';
  bool _obscureText = true;
  CountryCode _countryCode =
      const CountryCode(name: "Pakistan", code: "PK", dialCode: "+92");
  final FocusNode _focusNode = FocusNode();
  bool _passwordHasFocus = false;
  final countryPicker = FlCountryCodePicker(
      showSearchBar: true,
      title: Container(
        height: 10,
      ));
  final _formKey = GlobalKey<FormState>();
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
    return Container(
      padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: controllers['firstName'],
                        decoration: InputDecoration(
                          label: const Text('First Name'),
                          labelStyle: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                          hintText: 'First Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                            overflow: TextOverflow.ellipsis,
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
                            Icons.person,
                            color: Colors.black54,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim() == "") {
                            return 'First Name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: controllers['lastName'],
                        decoration: InputDecoration(
                          label: const Text('Last Name'),
                          labelStyle: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                          hintText: 'Last Name',
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
                            Icons.person,
                            color: Colors.black54,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim() == "") {
                            return 'Last Name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        items: ['Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          _gender = value;
                        },
                        hint: const Text(
                          'Gender',
                          style:
                              TextStyle(color: Color.fromARGB(255, 88, 88, 88)),
                        ),
                        decoration: InputDecoration(
                          label: const Text('Gender'),
                          labelStyle: const TextStyle(
                            overflow: TextOverflow.ellipsis,
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
                            Icons.wc_rounded,
                            color: Colors.black54,
                          ),
                          contentPadding: const EdgeInsets.only(
                              top: 16, bottom: 16, left: 16, right: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gender is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        items: ['Client', 'Trainer', 'Manager', 'Owner']
                            .map((account) => DropdownMenuItem(
                                  value: account,
                                  child: Text('Gym $account'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          _accType = value;
                        },
                        hint: const Text(
                          'Role',
                          style:
                              TextStyle(color: Color.fromARGB(255, 88, 88, 88)),
                        ),
                        decoration: InputDecoration(
                          label: const Text('Role'),
                          labelStyle: const TextStyle(
                            overflow: TextOverflow.ellipsis,
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
                            Icons.account_circle_outlined,
                            color: Colors.black54,
                          ),
                          contentPadding: const EdgeInsets.only(
                              top: 16, bottom: 16, left: 16, right: 8),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Account is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: controllers['email'],
                    decoration: InputDecoration(
                      label: const Text('Email'),
                      labelStyle: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                      hintText: 'Email',
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
                        Icons.email_rounded,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim() == "") {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    }),
                const SizedBox(height: 15.0),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: controllers['phone'],
                  onChanged: (_) {
                    HapticFeedback.lightImpact();
                  },
                  decoration: InputDecoration(
                    label: const Text('Phone (optional)'),
                    labelStyle: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                    hintText: 'Enter Phone (optional)',
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
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    prefixIcon: GestureDetector(
                        onTap: () async {
                          final picked =
                              await countryPicker.showPicker(context: context);
                          if (picked != null) {
                            setState(() {
                              _countryCode = picked;
                            });
                          }
                        },
                        child: IntrinsicWidth(
                          child: Container(
                            margin: const EdgeInsets.only(left: 13),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: Colors.black54,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 12),
                                  child: Text(
                                    "${_countryCode.dialCode} | ",
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                  validator: (value) {
                    // Regex to validate phone number with country code
                    final phoneRegex = RegExp(r'^\+(\d{1,3})\s?\d{10,15}$');
                    if (value != null &&
                        value.isNotEmpty &&
                        value.trim() != "") {
                      if (!phoneRegex.hasMatch(_countryCode.dialCode + value)) {
                        return 'Enter valid phone number with country code';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
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
                        _obscureText ? Icons.visibility : Icons.visibility_off,
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
                const SizedBox(height: 13.0),
                Row(
                  children: [
                    Checkbox(
                      value: _agreePersonalData,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreePersonalData = value!;
                        });
                      },
                      activeColor: colorScheme.primary,
                    ),
                    const Text(
                      'I agree to the processing of ',
                      style: TextStyle(
                        color: Colors.black45,
                      ),
                    ),
                    Text(
                      'Personal data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                        buttonText: "Register",
                        disabled: isLoading,
                        onClick: () {
                          HapticFeedback.lightImpact();
                          if (_formKey.currentState?.validate() ?? false) {
                            if (_agreePersonalData) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VerifyEmailPage(
                                          email:
                                              controllers['email'].text.trim(),
                                          onSuccess: () async {
                                            try {
                                              if (_formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                if (_agreePersonalData) {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  var url = Uri.parse(
                                                      'http://${serverAddressController.IP}:3001/register');
                                                  var response = await http
                                                      .post(url, body: {
                                                    'firstName':
                                                        controllers['firstName']
                                                            .text
                                                            .trim(),
                                                    'lastName':
                                                        controllers['lastName']
                                                            .text
                                                            .trim(),
                                                    'email':
                                                        controllers['email']
                                                            .text
                                                            .trim(),
                                                    'phone': controllers[
                                                                    'phone']
                                                                .text
                                                                .trim() !=
                                                            ""
                                                        ? _countryCode
                                                                .dialCode +
                                                            controllers['phone']
                                                                .text
                                                                .trim()
                                                        : controllers['phone']
                                                            .text
                                                            .trim(),
                                                    'gender': _gender,
                                                    'accType': _accType,
                                                    'password':
                                                        controllers['password']
                                                            .text,
                                                    'confirmPassword':
                                                        controllers['password']
                                                            .text
                                                  });

                                                  if (response.statusCode ==
                                                      200) {
                                                    CustomSnackbar
                                                        .showSuccessSnackbar(
                                                            context,
                                                            "Success!",
                                                            "Registered Successfully");
                                                    Map responseBody = json
                                                        .decode(response.body);
                                                    await SecureStorage()
                                                        .setItem(
                                                            "authToken",
                                                            responseBody[
                                                                "authToken"]);
                                                    await SecureStorage()
                                                        .setItems([
                                                      "isLoggedIn",
                                                      "tokenExpirationTime",
                                                      "userData"
                                                    ], [
                                                      true,
                                                      responseBody[
                                                          "tokenExpirationTime"],
                                                      responseBody["data"]
                                                    ]);
                                                    controllers['firstName']
                                                        .clear();
                                                    controllers['lastName']
                                                        .clear();
                                                    controllers['email']
                                                        .clear();
                                                    controllers['phone']
                                                        .clear();
                                                    controllers['password']
                                                        .clear();
                                                    controllers[
                                                            'confirmPassword']
                                                        .clear();
                                                    Navigator.of(context)
                                                        .pushNamedAndRemoveUntil(
                                                            responseBody["data"]
                                                                        [
                                                                        'accType'] ==
                                                                    'Trainer'
                                                                ? TrainerDashboardPage
                                                                    .routePath
                                                                : ClientHomePage
                                                                    .routePath,
                                                            (route) => false);
                                                  } else {
                                                    CustomSnackbar
                                                        .showFailureSnackbar(
                                                            context,
                                                            "Oops!",
                                                            json.decode(response
                                                                    .body)[
                                                                'message']);
                                                  }
                                                } else {
                                                  CustomSnackbar
                                                      .showWarningSnackbar(
                                                          context,
                                                          "Attention!",
                                                          'Please agree to the processing of personal data');
                                                }
                                              }
                                            } catch (e) {
                                              CustomSnackbar.showFailureSnackbar(
                                                  context,
                                                  "Oops!",
                                                  "Sorry, couldn't request to server");
                                            }
                                            setState(() {
                                              isLoading = false;
                                            });
                                          },
                                        )),
                              );
                            } else {
                              CustomSnackbar.showWarningSnackbar(
                                  context,
                                  "Attention!",
                                  'Please agree to the processing of personal data');
                            }
                          }
                        })),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Colors.black45,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (e) => const SigninPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 5.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordRequirementsDialog extends StatelessWidget {
  const PasswordRequirementsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
      backgroundColor: backgroundColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Password must contain:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              '• 6-20 characters,\n• At least 1 number,\n• 1 lowercase letter,\n• 1 uppercase letter',
              style: TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 20),
            TextButton(
              child: const Text('OK', style: TextStyle(fontSize: 18)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
