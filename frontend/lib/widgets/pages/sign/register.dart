import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';
import 'dart:convert';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

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
    'phone': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController()
  };
  bool _agreePersonalData = true;
  bool _obscureText = true;
  String IP = '10.7.241.101';
  CountryCode selectedCountryCode =
      const CountryCode(name: "Pakistan", code: "PK", dialCode: "+92");
  final countryPicker = FlCountryCodePicker(
      showSearchBar: true,
      title: Container(
        height: 10,
      ));
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25.0, 40.0, 25.0, 20.0),
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
                Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 40.0),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: controllers['firstName'],
                        decoration: InputDecoration(
                          label: const Text('First Name'),
                          hintText: 'First Name',
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
                const SizedBox(height: 16.0),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: controllers['phone'],
                  decoration: InputDecoration(
                    label: const Text('Phone'),
                    hintText: 'Enter Phone',
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
                          // Show the country code picker when tapped.
                          final picked =
                              await countryPicker.showPicker(context: context);
                          // Update the state with the selected country code.
                          if (picked != null) {
                            setState(() {
                              selectedCountryCode = picked;
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
                                    // ignore: prefer_interpolation_to_compose_strings
                                    (selectedCountryCode.dialCode) + " | ",
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
                    if (value == null || value.isEmpty || value.trim() == "") {
                      return 'Phone number is required';
                    }
                    // Regex to validate phone number with country code
                    final phoneRegex = RegExp(r'^\+(\d{1,3})\s?\d{10,15}$');
                    if (!phoneRegex
                        .hasMatch(selectedCountryCode.dialCode + value)) {
                      return 'Enter valid phone number with country code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  controller: controllers['password'],
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    label: const Text('Password'),
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: backgroundColor,
                          child: Container(
                            width: MediaQuery.of(context).size.width *
                                1, // Set custom width for the dialog
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text(
                                  'Password must contain:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  '• 6-20 characters,\n• At least 1 number,\n• 1 lowercase letter,\n• 1 uppercase letter',
                                  style: TextStyle(fontSize: 17),
                                ),
                                const SizedBox(height: 20),
                                TextButton(
                                  child: const Text('OK',
                                      style: TextStyle(fontSize: 17)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
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
                const SizedBox(height: 25.0),
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
                const SizedBox(height: 25.0),
                SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      buttonText: "Register",
                      onClick: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_agreePersonalData) {
                            var url = Uri.parse('http://$IP:3001/register');
                            var response = await http.post(url, body: {
                              'firstName': controllers['firstName'].text.trim(),
                              'lastName': controllers['lastName'].text.trim(),
                              'phone': controllers['phone'].text.trim(),
                              'password': controllers['password'].text,
                              'confirmPassword': controllers['password'].text
                            });

                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Registered Successfully'),
                                ),
                              );
                              controllers['firstName'].clear();
                              controllers['lastName'].clear();
                              controllers['phone'].clear();
                              controllers['password'].clear();
                            } else {
                              print(json.decode(response.body)['message']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      json.decode(response.body)['message']),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please agree to the processing of personal data'),
                              ),
                            );
                          }
                        }
                      },
                    )
                    // child: ElevatedButton(
                    //   onPressed: () async {
                    //     if (_formKey.currentState?.validate() ?? false) {
                    //       if (_agreePersonalData) {
                    //         var url = Uri.parse('http://$IP:3001/register');
                    //         var response = await http.post(url, body: {
                    //           'firstName': controllers['firstName'].text.trim(),
                    //           'lastName': controllers['lastName'].text.trim(),
                    //           'phone': controllers['phone'].text.trim(),
                    //           'password': controllers['password'].text,
                    //           'confirmPassword': controllers['password'].text
                    //         });

                    //         if (response.statusCode == 200) {
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             const SnackBar(
                    //               content: Text('Registered Successfully'),
                    //             ),
                    //           );
                    //           controllers['firstName'].clear();
                    //           controllers['lastName'].clear();
                    //           controllers['phone'].clear();
                    //           controllers['password'].clear();
                    //         } else {
                    //           print(json.decode(response.body)['message']);
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             SnackBar(
                    //               content:
                    //                   Text(json.decode(response.body)['message']),
                    //             ),
                    //           );
                    //         }
                    //       } else {
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           const SnackBar(
                    //             content: Text(
                    //                 'Please agree to the processing of personal data'),
                    //           ),
                    //         );
                    //       }
                    //     }
                    //   },
                    //   child: const Text('Register'),
                    // ),
                    ),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.7,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      child: Text(
                        'Register with',
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.7,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30.0),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(BoxIcons.bxl_facebook),
                    Icon(BoxIcons.bxl_twitter),
                    Icon(BoxIcons.bxl_google),
                    Icon(BoxIcons.bxl_apple),
                  ],
                ),
                const SizedBox(height: 25.0),
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
