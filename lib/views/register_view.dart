import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;
import 'package:flutter/material.dart';
import 'package:test_app/constants/routes.dart';


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
                      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
                      devtools.log(userCredential.toString());
                    } on FirebaseAuthException catch (e){
                      if (e.code == "weak-password"){
                        devtools.log('Weak password..');
                      } else if (e.code == "email-already-used"){
                        devtools.log("Email is already taken...");
                      }
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