import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/views/login_view.dart';
import 'package:test_app/views/register_view.dart';
import 'package:test_app/views/verify_email_view.dart';


//Learning asynchronous operation (stream and future)
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/' : (context) => const RegisterView(),
      },
    ),);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState){
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;

            if (user != null){
              if(user.emailVerified){
                print('Email is verified!');
              }else{
                return const VerifyEmailView();
              }
            }else{
              return const LoginView();
            }
            return const Text('Done');
          default:
            return const CircularProgressIndicator();
          }
        },
    );
  }
}






// void test() async{
//   // final result = await futureFunction(10);
//   // print(result);

//   // await for ( final value in getName()){
//   //   print(value);
//   // }

//   for (final value in getOneTwoThree()){
//     print(value);
//   }

//   final names = Pair('foo',20);
//   print(names);
// }

// Future<int> futureFunction(int a){
//   return Future.delayed(const Duration(seconds: 3),()=>a*2);
// }

// Stream<String> getName() {
//   // return Stream.value('Ali');
//   return Stream.periodic(const Duration(seconds: 1),(value)=>'Foo');
// }

// //Generators function
// Iterable<int> getOneTwoThree() sync* {
//   yield 1;
//   yield 2;
// }

// // Generics - to avoid re-writting similar code
// class Pair<A,B>{
//   final A value1;
//   final B value2;
//   Pair(this.value1,  this.value2);
// }


