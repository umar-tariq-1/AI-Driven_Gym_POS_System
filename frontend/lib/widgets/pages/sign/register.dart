import 'package:flutter/material.dart';
import 'package:frontend/widgets/pages/sign/signin_page.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';

import 'signin.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
      ),
      child: SingleChildScrollView(
        // get started form
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Get Started',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w900,
                color: lightColorScheme.primary,
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
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
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 1,
                  child: TextFormField(
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
            // email
            TextFormField(
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
                prefixIcon: const Icon(
                  Icons.phone,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            // password
            TextFormField(
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
            ),
            const SizedBox(
              height: 25.0,
            ),
            // i agree to the processing
            Row(
              children: [
                Checkbox(
                  value: _agreePersonalData,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreePersonalData = value!;
                    });
                  },
                  activeColor: lightColorScheme.primary,
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
                    color: lightColorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25.0,
            ),
            // signup button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_agreePersonalData) {
                    var url = Uri.parse('http://localhost:3001/register');
                    var response = await http.post(url, body: {
                      'firstName':
                          controllers['name'].text.trim().split(' ')[0],
                      'lastName': controllers['name'].text.trim().split(' ')[1],
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
                      // print(response.body);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to Register'),
                        ),
                      );
                      // print(response.body);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please agree to the processing of personal data'),
                      ),
                    );
                  }
                },
                child: const Text('Register'),
              ),
            ),
            const SizedBox(
              height: 30.0,
            ),
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
                  padding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
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
            const SizedBox(
              height: 30.0,
            ),
            // sign up social media logo
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(BoxIcons.bxl_facebook),
                Icon(BoxIcons.bxl_twitter),
                Icon(BoxIcons.bxl_google),
                Icon(BoxIcons.bxl_apple),
              ],
            ),
            const SizedBox(
              height: 25.0,
            ),
            // already have an account
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
                      color: lightColorScheme.primary,
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
      ),
    );
  }
}
