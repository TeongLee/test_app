import 'package:flutter/material.dart';
import 'package:test_app/constants/routes.dart';
import 'package:test_app/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email'),),
      body: Column(
        children: [
          const Text("We've already sent you an email verification. Please open it to verify your account."),
          const Text("If you havent; received a verification email yet, press the button below"),
          TextButton(onPressed: () async {
            await AuthService.firebase().sendEmailVerification();
          }, child: const Text('Send email verification')),
          TextButton(onPressed: () async {
            await AuthService.firebase().logOut();
            Navigator.pushNamedAndRemoveUntil(context, registerRoute, (_)=> false);
          }, child: const Text('Restart'))
        ],
        ),
    );
  }
}