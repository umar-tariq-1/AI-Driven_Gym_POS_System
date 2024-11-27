import 'package:flutter/material.dart';
import 'package:frontend/widgets/pages/sign/register_page.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';

import '../../../theme/theme.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  Map controllers = {
    'phone': TextEditingController(),
    'password': TextEditingController(),
  };
  bool _obscureText = true;
  bool rememberPassword = true;
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
              'Welcome back',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
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
              height: 17.0,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberPassword,
                      onChanged: (bool? value) {
                        setState(() {
                          rememberPassword = value!;
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
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(
              height: 25.0,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  var url = Uri.parse('http://localhost:3001/signin');
                  var response = await http.post(url, body: {
                    'phone': controllers['phone'].text.trim(),
                    'password': controllers['password'].text,
                  });

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('SignedIn Successfully'),
                      ),
                    );
                    controllers['phone'].clear();
                    controllers['password'].clear();
                    // print(response.body);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to LogIn'),
                      ),
                    );
                    // print(response.body);
                  }
                },
                child: const Text('Sign in'),
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
                    'Sign in with',
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
      ),
    );
  }
}
