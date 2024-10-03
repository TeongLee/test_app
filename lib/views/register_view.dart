// import 'dart:developer' as devtools show log;
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:test_app/constants/routes.dart';
import 'package:test_app/services/auth/auth_exceptions.dart';
import 'package:test_app/services/auth/auth_service.dart';
import 'package:test_app/utilities/show_error_dialog.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {

  //late data type - a variable that promise to assign value later
  late final TextEditingController _email;
  late final TextEditingController _password;  //lalalala

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register'),),
      body: Column(
                children: [
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter email'
                  ),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter password'
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      await AuthService.firebase().createUser(email: email, password: password);
                      // devtools.log(userCredential.toString());
                      // final user = AuthService.firebase().currentUser;
                      AuthService.firebase().sendEmailVerification();
                      Navigator.pushNamed(context, verifyEmailRoutes);
                    } on WeakPasswordAuthException{
                      showErrorDialog(context, 'Weak password');
                    } on EmailAlreadyInUseAuthException{
                      showErrorDialog(context, 'Email already in use');
                    } on InvalidEmailAuthException{
                      showErrorDialog(context, 'Invalid email address');
                    } on GenericAuthException{
                      await showErrorDialog(context, 'Failed to register',);
                    }
                  },
                  child: const Text('Register'),
                  ),
                  TextButton(onPressed: (){
                     Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute, 
                      (route) => false,  // Removes all previous routes
                    );
                  }, child: const Text('Already registred? Log in here!!'))
                ],
            ),
    );
  }
}