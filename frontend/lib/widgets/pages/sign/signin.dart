import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/data/local_storage.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/pages/home_page.dart';
import 'package:frontend/widgets/pages/sign/forget_passsword_page.dart';
import 'package:frontend/widgets/pages/sign/register_page.dart';
import 'package:http/http.dart' as http;

import '../../../theme/theme.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  Map controllers = {
    'email': TextEditingController(),
    'password': TextEditingController(),
  };
  String IP = '10.7.241.86';
  bool _obscureText = true;
  bool _rememberPassword = true;
  final _formKey = GlobalKey<FormState>();
  final _forgetPasswordFormKey = GlobalKey<FormState>();
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
                // Text(
                //   'Welcome back',
                //   style: TextStyle(
                //     fontSize: 30.0,
                //     fontWeight: FontWeight.w900,
                //     color: colorScheme.primary,
                //   ),
                // ),
                // const SizedBox(
                //   height: 40.0,
                // ),
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
                const SizedBox(height: 16.0),
                TextFormField(
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
                    if (value.length < 6 ||
                        !RegExp(r'[A-Z]').hasMatch(value) ||
                        !RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Invalid Password';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 25.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberPassword,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberPassword = value!;
                            });
                          },
                          activeColor: colorScheme.primary,
                        ),
                        const Text(
                          'Remember me',
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      child: Text(
                        'Forget password?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: backgroundColor,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                padding:
                                    const EdgeInsets.fromLTRB(15, 25, 15, 17.5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text(
                                      'Enter Email for OTP Verification',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 30),
                                    Form(
                                      key: _forgetPasswordFormKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            keyboardType:
                                                TextInputType.emailAddress,
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.email_rounded,
                                                color: Colors.black54,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 16),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  value.trim() == "") {
                                                return 'Email is required';
                                              }
                                              if (!RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                  .hasMatch(value.trim())) {
                                                return 'Enter a valid email address';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    TextButton(
                                      child: const Text('Request OTP',
                                          style: TextStyle(fontSize: 18)),
                                      onPressed: () {
                                        if (_forgetPasswordFormKey.currentState
                                                ?.validate() ??
                                            false) {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (e) =>
                                                  ForgetPasswordPage(
                                                      email:
                                                          controllers['email']
                                                              .text),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 25.0,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    buttonText: "Sign In",
                    onClick: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        var url = Uri.parse('http://$IP:3001/signin');
                        var response = await http.post(url, body: {
                          'email': controllers['email'].text.trim(),
                          'password': controllers['password'].text,
                        });

                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.white,
                              content: Text(
                                'Signed In Successfully',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                          controllers['email'].clear();
                          controllers['password'].clear();

                          Map responseBody = json.decode(response.body);
                          await SecureStorage()
                              .setItem("authToken", responseBody["authToken"]);
                          await LocalStorage().setItems([
                            "isLoggedIn",
                            "tokenExpirationTime",
                            "userData"
                          ], [
                            true,
                            responseBody["tokenExpirationTime"],
                            responseBody["data"]
                          ]);
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              HomePage.routePath, (route) => false);
                          // print(json.decode(response.body));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.white,
                              content: Text(
                                json.decode(response.body)['message'],
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                          // print(json.decode(response.body)['message']);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                // don't have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        color: Colors.black45,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (e) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ))),
    );
  }
}
