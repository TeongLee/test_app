import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {

  //create the variables needed for login with class "TextEditingController"
  //late data type - a variable that promise to assign value later
  late final TextEditingController _email;
  late final TextEditingController _password;

  // 2. Initializion - creating two instance of TextEditingController
  @override
  void initState() { 
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  //4. Dispose - dispose when the widget is removed from the widget tree (no longer in use)
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        //3. Using the controller in text field widgets
      children: [
        TextField(
          controller: _email, //here 
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'Enter email'
          ),
        ),
        TextField(
          controller: _password, //here
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
              await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email, 
                password: password,
              );
              Navigator.of(context).pushNamedAndRemoveUntil('/notes/', (route) => false);
            } on FirebaseAuthException catch (e){
              if (e.code == 'user-not-found') {
                devtools.log('No user found for that email.');
                // You can show a message to the user or handle the error as needed
              } else if (e.code == 'wrong-password') {
                devtools.log('Wrong password provided for that user.');
                // Show error message or handle the error
              } else if (e.code == 'invalid-email') {
                devtools.log('The email address is badly formatted.');
                // Handle the invalid email format
              } else if (e.code == 'user-disabled') {
                devtools.log('The user has been disabled.');
                // Handle the disabled user case
              } else {
                // Generic error message
                devtools.log('Something went wrong: ${e.message}');
              }
            }
          },
          child: const Text('Login'),
        ),
        TextButton(onPressed: (){
          Navigator.of(context).pushNamedAndRemoveUntil(
        '/register/', 
        (route) => false,  // Removes all previous routes
        );
        }, child: const Text('Not registered yet? Registered here!')),
      ],
      
      
      
        
        ),
    );
}
}