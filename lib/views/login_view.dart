import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app/constants/routes.dart';
import 'package:test_app/utilities/show_error_dialog.dart';

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
              Navigator.of(context).pushNamedAndRemoveUntil(notesRoutes, (route) => false);
            } on FirebaseAuthException catch (e){
              if (e.code == 'user-not-found') {
                await showErrorDialog(context, 'User not found',);
                // You can show a message to the user or handle the error as needed
              } else if (e.code == 'wrong-password') {
                await showErrorDialog(context, 'Wrong credentials',);
                // Show error message or handle the error
              } else if (e.code == 'invalid-email') {
                await showErrorDialog(context, 'Invalid email',);
                // Handle the invalid email format
              }else {
                // Generic error message
                await showErrorDialog(context, 'Error: ${e.code}',);
              }
            } catch (e){
              await showErrorDialog(context, e.toString(),);
            }
          },
          child: const Text('Login'),
        ),
        TextButton(onPressed: (){
          Navigator.of(context).pushNamedAndRemoveUntil(
        registerRoute, 
        (route) => false,  // Removes all previous routes
        );
        }, child: const Text('Not registered yet? Registered here!')),
      ],
      
        
        ),
    );
}
}